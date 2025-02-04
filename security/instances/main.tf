resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  security_groups = [var.security_group_id]

  root_block_device {
    volume_size = 20
  }
}

resource "aws_instance" "sonarqube" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  security_groups = [var.security_group_id]

  root_block_device {
    volume_size = 20
  }
}

resource "aws_instance" "nexus" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  security_groups = [var.security_group_id]

  root_block_device {
    volume_size = 20
  }
}
