#!/bin/bash
set -e

# Change into the terraform directory to retrieve outputs
cd terraform || { echo "terraform directory not found"; exit 1; }

# Retrieve the public IP and key name from Terraform outputs (using -raw to strip quotes)
APP_PUBLIC_IP=$(terraform output -raw app_public_ip)
KEY_NAME=$(terraform output -raw key_name)

# Return to the project root
cd ..

if [ -z "$APP_PUBLIC_IP" ]; then
  echo "Error: Could not retrieve app_public_ip from Terraform output." >&2
  exit 1
fi

# Assume the key file is stored at $HOME/.ssh/<key_name>.pem
SSH_KEY_PATH="$HOME/.ssh/${KEY_NAME}.pem"

# Write a clean inventory file for Ansible in the ansible/inventory folder.
cat > ansible/inventory/hosts <<EOF
[app]
${APP_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_KEY_PATH}
EOF

echo "Ansible inventory file created with public IP: ${APP_PUBLIC_IP} and SSH key: ${SSH_KEY_PATH}"
