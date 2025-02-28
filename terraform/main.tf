resource "aws_security_group" "app_sg" {
  name        = "todo_app_sg"
  description = "Allow inbound traffic for To-Do app in production"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "todo_app" {
  ami             = "ami-04b4f1a9cf54c11d0"  # Ubuntu 24.04 LTS 
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.app_sg.name]

  tags = {
    Name = "To-Do-App-Instance"
  }
}


# Null resource to set execute permission on generate_inventory.sh
resource "null_resource" "chmod_inventory" {
  provisioner "local-exec" {
    command     = "chmod +x generate_inventory.sh"
    working_dir = "${path.module}/../"
  }
}

# Null resource to generate the Ansible inventory using the script
resource "null_resource" "generate_inventory" {

  provisioner "local-exec" {
    command     = "./generate_inventory.sh"
    working_dir = "${path.module}/../"
  }
  depends_on = [aws_instance.todo_app, null_resource.chmod_inventory]
}

# Trigger Ansible playbook execution automatically
resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command     = "ansible-playbook -i ./ansible/inventory/hosts ./ansible/playbook.yml"
    working_dir = "${path.module}/../"
  }
  depends_on = [null_resource.generate_inventory]
}
