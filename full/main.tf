provider "aws" {
  region = "us-east-1" # Change as per your requirement
}

resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "DevOpsVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    Name = "DevOpsIGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.devops_igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "devops_sg" {
  vpc_id      = aws_vpc.devops_vpc.id
  name        = "devops-security-group"
  description = "Security group for Jenkins, SonarQube, and Nexus"

  dynamic "ingress" {
    for_each = [
      25, 80, 443, 22, 6443, 465
    ]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = [
      { from = 30000, to = 32768 },
      { from = 3000, to = 10000 }
    ]
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.medium"
  key_name      = "your-key-pair"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.devops_sg.name]

  root_block_device {
    volume_size = 20
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y java-11-openjdk
              sudo yum install -y wget
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              sudo yum install -y jenkins
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              EOF

  tags = {
    Name = "Jenkins"
  }
}

resource "aws_instance" "sonarqube" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.medium"
  key_name      = "your-key-pair"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.devops_sg.name]

  root_block_device {
    volume_size = 20
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              docker run -d --name sonarqube -p 9000:9000 sonarqube
              EOF

  tags = {
    Name = "SonarQube"
  }
}

resource "aws_instance" "nexus" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.medium"
  key_name      = "your-key-pair"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.devops_sg.name]

  root_block_device {
    volume_size = 20
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              docker run -d -p 8081:8081 --name nexus sonatype/nexus3
              EOF

  tags = {
    Name = "Nexus Artifactory"
  }
}
