provider "aws" {
  profile = "default"
  region = "eu-central-1"
}

# Create a new instance
resource "aws_instance" "example" {
  ami = "ami-0f673487d7e5f89ca"
  instance_type = var.instance_type
  tags = {
    Name = var.instance_name
  }
}