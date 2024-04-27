# AWS Terraform Infrastructure Deployment

This repository contains Terraform code to provision a basic infrastructure on AWS including a VPC (Virtual Private Cloud), public and private subnets, internet gateway, NAT gateway, route tables, security groups, key pairs, and instances.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Architecture Overview](#architecture-overview)
- [Folder Structure](#folder-structure)
- [Variables](#variables)
- [Outputs](#outputs)
- [Notes](#notes)

## Introduction

This Terraform project is designed to automate the setup of a simple AWS infrastructure with both public and private subnets. It creates the following resources:

- VPC with CIDR block `10.0.0.0/16`
- Public and private subnets with CIDR blocks `10.0.0.0/24` and `10.0.1.0/24` respectively
- Internet Gateway attached to the VPC
- NAT Gateway for the private subnet to access the internet
- Public and private route tables
- Security groups allowing SSH, HTTP, HTTPS inbound traffic, and all outbound traffic
- Key pair for SSH access
- Public and private EC2 instances

## Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

You will also need an AWS account with appropriate permissions and configured AWS CLI with access keys.

## Usage

1. Clone this repository:

   ```bash
   git clone https://github.com/your-username/terraform-aws-infrastructure.git
   ```

2. Navigate to the project directory:

   ```bash
   cd terraform-aws-infrastructure
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Review and modify `variables.tf` file to adjust any configuration parameters if needed.

5. Execute Terraform plan to see the execution plan:

   ```bash
   terraform plan
   ```

6. If the plan looks good, apply the Terraform configuration:

   ```bash
   terraform apply
   ```

7. After the provisioning is complete, Terraform will output the public IP address of the public instance.

8. To clean up and destroy the resources created, run:

   ```bash
   terraform destroy
   ```

## Architecture Overview

The infrastructure deployed by this Terraform script consists of:

- **VPC**: A virtual network in AWS with CIDR block `10.0.0.0/16`.
- **Subnets**: One public and one private subnet, each in a different availability zone.
- **Internet Gateway**: Attached to the VPC to allow public internet access to instances in the public subnet.
- **NAT Gateway**: Provides outbound internet access to instances in the private subnet.
- **Route Tables**: One for the public subnet and one for the private subnet, controlling traffic flow.
- **Security Groups**: For controlling inbound and outbound traffic to instances.
- **Key Pair**: Used for SSH access to EC2 instances.
- **EC2 Instances**: One public instance accessible from the internet and one private instance accessible only from within the VPC.

## Folder Structure

- **main.tf**: Main Terraform configuration file defining AWS resources.
- **variables.tf**: Contains variable definitions used in the Terraform configuration.
- **outputs.tf**: Contains outputs that are displayed after Terraform applies the configuration.

## Variables

- **vpc_name**: Name of the VPC.
- **instance_type**: Instance type for EC2 instances.
- **public_instance_name**: Name tag for the public EC2 instance.
- **private_instance_name**: Name tag for the private EC2 instance.

## Outputs

- **public_instance_public_ip**: Public IP address of the public EC2 instance.

## Notes

- Ensure that you have appropriate permissions and AWS credentials configured.
- Review the Terraform plan before applying to avoid any unintended changes.
- It's recommended to store sensitive information such as AWS access keys securely, preferably using environment variables or AWS CLI profiles.
- Make sure to destroy resources after use to avoid unnecessary costs.
