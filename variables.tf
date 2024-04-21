variable "public_instance_name" {
  description = "Name of the instance"
  default = "public_instance"
}

variable "private_instance_name" {
  description = "Name of the public instance"
  default = "private_instance"
}

variable "instance_type" {
  description = "Type of the instance"
  default = "t2.micro"
}

variable "vpc_name" {
  description = "Name of the VPC"
  default = "terraform_vpc"
}