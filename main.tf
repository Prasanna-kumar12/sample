provider "aws" {

}

resource "aws_instance" "new-instance" {
  ami = 
  availability_zone = 
  security_groups = 
  key_name = 
  instance_type = 
}

resource "aws_internet_gateway" "aws-igw" {
  vpc_id =
}

resource "aws_subnet" "private" {
  cidr_block = 
  vpc_id = 
}

resource "aws_subnet" "public" {
  cidr_block = 
  vpc_id = 
}