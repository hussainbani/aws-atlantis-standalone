locals {
  region      = "us-east-1"
  environment = "test"
  name        = "atlantis-private"
  domain      = var.domain
}

module "atlantis_private" {
  source = "../../"
  
  providers = {
    aws    = aws
    aws.r53 = aws.r53
  }

  # Basic Settings
  name          = local.name
  region        = local.region
  domain        = local.domain
  instance_type = "t3.small"
  ami           = data.aws_ami.ubuntu.id

  # Network Configuration
  vpc_id             = data.aws_vpc.main.id
  subnet_id          = data.aws_subnet.private.id
  mgmt_subnets       = [data.aws_vpc.main.cidr_block]
  lb_frontend_subnets = [data.aws_subnet.private_a.id, data.aws_subnet.private_b.id]

  # DNS Configuration
  r53_zone_id = data.aws_route53_zone.main.zone_id

  # Feature Flags - Private ALB setup
  create_alb                 = true
  create_dns_records        = true
  enable_web_authentication = true
  eip                      = false

  # Authentication
  atlantis_username = "admin"
  atlantis_password = random_password.atlantis.result

  # GitHub Configuration
  github_app_private_key     = var.github_app_key
  atlantis_gh_webhook_secret = var.webhook_secret
  atlantis_gh_app_id        = var.github_app_id
  repo_allowlist            = "github.com/${var.github_org}/*"

  # AWS Credentials
  aws_credentials_base64 = var.aws_credentials

  # Security Group Rules for private setup
  alb_security_group_rules = [
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS from VPC"
      cidr_blocks = [data.aws_vpc.main.cidr_block]
    }
  ]

  # Tags
  additional_tags = {
    Environment = local.environment
    Terraform   = "true"
    Private     = "true"
  }
}

# Generate random password for Atlantis web auth
resource "random_password" "atlantis" {
  length  = 16
  special = true
}

# Data sources
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_vpc" "main" {
  tags = {
    Environment = local.environment
  }
}

data "aws_subnet" "private" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Environment = local.environment
    Type        = "private"
  }
}

data "aws_subnet" "private_a" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Environment = local.environment
    Type        = "private"
    AZ          = "${local.region}a"
  }
}

data "aws_subnet" "private_b" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Environment = local.environment
    Type        = "private"
    AZ          = "${local.region}b"
  }
}

data "aws_route53_zone" "main" {
  name = var.domain
}
