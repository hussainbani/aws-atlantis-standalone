# Minimal test configuration with only required settings
provider "aws" {
  region = local.region
  
  # Use alias for Route53 operations
  alias = "r53"
}

locals {
  region      = "us-east-1"
  environment = "test"
  name        = "atlantis-minimal"
}

module "atlantis_minimal" {
  source = "../../"
  
  providers = {
    aws    = aws
    aws.r53 = aws.r53
  }

  # Required variables
  name              = local.name
  region            = local.region
  domain            = var.domain
  instance_type     = "t3.small"
  ami               = data.aws_ami.ubuntu.id
  vpc_id            = data.aws_vpc.main.id
  subnet_id         = data.aws_subnet.private.id
  mgmt_subnets      = [data.aws_vpc.main.cidr_block]
  r53_zone_id       = var.r53_zone_id
  lb_frontend_subnets = var.lb_frontend_subnets
  
  # ALB configuration
  create_alb          = false
  create_dns_records = false
  
  # GitHub configuration
  github_app_private_key     = var.github_app_key
  atlantis_gh_webhook_secret = var.webhook_secret
  atlantis_gh_app_id        = var.github_app_id
  
  # AWS credentials
  aws_credentials_base64 = var.aws_credentials
}

# Data sources for AMI and network resources
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

