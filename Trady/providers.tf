# Terraform 구성 및 Provider 설정
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  backend "s3" {
    bucket         = "amss3-terraform-state"
    key            = "trady/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    acl            = "bucket-owner-full-control"

    profile = "amosa"
  }
}

# AWS Provider 설정 - 서울 리전 (ap-northeast-2)
provider "aws" {
  region  = var.aws_region
  profile = "amosa"

  default_tags {
    tags = {
      Environment = "all"
      Project     = "trady"
      ManagedBy   = "terraform"
    }
  }
} 