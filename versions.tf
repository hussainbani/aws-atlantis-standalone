terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
      configuration_aliases = [
        aws,
        aws.r53
      ]
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.0"
    }
  }
  required_version = ">= 1.0"
}
