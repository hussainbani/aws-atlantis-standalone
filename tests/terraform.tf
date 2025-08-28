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
  region = "us-east-1"
}

# Example values for testing - replace with your own secure values
locals {
  test_values = {
    github_app_key  = "base64_encoded_key_here"
    github_app_id   = "123456"
    webhook_secret  = "webhook_secret_here"
    aws_credentials = "base64_encoded_credentials_here"
    domain          = "example.com"
    github_org      = "your-org"
  }
}
