terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = local.region

  # Example provider configuration - for actual use, configure through environment variables
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"

  default_tags {
    tags = {
      Environment = local.environment
      Terraform   = "true"
      Module      = "atlantis"
    }
  }
}

# Provider configuration for Route53 operations (potentially in a different region/account)
provider "aws" {
  alias  = "r53"
  region = local.region

  # Example provider configuration - for actual use, configure through environment variables
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}
