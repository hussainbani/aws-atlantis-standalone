terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = local.environment
      Terraform   = "true"
      Module      = "atlantis"
    }
  }
}

# Provider configuration for Route53 operations
provider "aws" {
  alias  = "r53"
  region = "us-east-1"
}
