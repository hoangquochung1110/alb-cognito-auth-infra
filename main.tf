# provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

locals {
  ami           = "ami-0b5a4445ada4a59b1"
  instance_type = "t2.micro"
  tags = {
    Name = var.project_name
  }
}