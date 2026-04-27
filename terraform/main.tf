terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "taskapp-tfstate-amara"   # ← YOUR BUCKET NAME
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "taskapp-tf-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "taskapp"
      Environment = "production"
      ManagedBy   = "terraform"
      Owner       = "amara"
    }
  }
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  azs          = var.availability_zones
  domain_name  = var.domain_name
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

module "dns" {
  source      = "./modules/dns"
  domain_name = var.domain_name
}