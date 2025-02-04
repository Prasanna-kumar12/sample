resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

output "vpc_id" {
  value = aws_vpc.devops_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}
