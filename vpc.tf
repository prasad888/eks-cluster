variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "education-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# vpc creation
resource "aws_vpc" "petclinic" {
  cidr_block       = var.cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = var.envname
  }
}
#subnets
 resource "aws_subnet" "public" {
     count = length(var.azs)
  vpc_id     = aws_vpc.petclinic.id
  cidr_block = element(var.pubsubnet,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.envname}-publicsubnet-${count.index+1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.azs)
  vpc_id     = aws_vpc.petclinic.id
  cidr_block = element(var.privatesubnet,count.index)
  availability_zone = element(var.azs,count.index)

  tags = {
    Name = "${var.envname}-privatesubnet-${count.index+1}"
  }
}

resource "aws_subnet" "data" {
  count = length(var.azs)
  vpc_id     = aws_vpc.petclinic.id
  cidr_block = element(var.datasubnet,count.index)
  availability_zone = element(var.azs,count.index)
