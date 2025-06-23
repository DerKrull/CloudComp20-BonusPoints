terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_s3_bucket" "backend_bucket" {
  bucket = "cloudcomp20-terraform-state-bucket"

  tags = {
    Name        = "Terraform state bucket"
  }
}