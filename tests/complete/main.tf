# Basic test configuration for Atlantis module
locals {
  environment = "test"
  name        = "atlantis-${local.environment}"
  domain      = "example.com"
}

module "atlantis_complete" {
  source = "../../"
  
  providers = {
    aws    = aws
    aws.r53 = aws.r53
  }

  # Basic Settings
  name          = local.name
  region        = "us-east-1"
  domain        = var.domain
  instance_type = "t3.small"
  ami           = data.aws_ami.ubuntu.id

  # Network Configuration
  vpc_id             = data.aws_vpc.main.id
  subnet_id          = data.aws_subnet.private.id
  mgmt_subnets       = [data.aws_vpc.main.cidr_block]
  lb_frontend_subnets = data.aws_subnet.public[*].id

  # DNS Configuration
  r53_zone_id = var.r53_zone_id

  # Feature Flags
  create_alb                 = true
  create_dns_records        = true
  enable_web_authentication = true
  eip                      = false

  # Authentication
  atlantis_username = "admin"
  atlantis_password = "your-secure-password"

  # GitHub Configuration (Replace with valid values)
  github_app_private_key     = "base64-encoded-private-key"
  atlantis_gh_webhook_secret = "your-webhook-secret"
  atlantis_gh_app_id        = "123456"
  repo_allowlist            = "github.com/yourorg/*"

  # AWS Credentials (Replace with valid credentials)
  aws_credentials_base64 = "base64-encoded-aws-credentials"

  # Additional Security Group Rules
  alb_security_group_rules = [
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS from specific CIDR"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]

  atlantis_security_group_rules = [
    {
      type                     = "ingress"
      from_port               = 8080
      to_port                 = 8080
      protocol                = "tcp"
      description             = "Custom application access"
      source_security_group_id = "sg-1234567890" # Replace with valid SG ID
    }
  ]

  # Tags
  additional_tags = {
    Environment = local.environment
    Terraform   = "true"
  }
}
