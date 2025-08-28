variable "github_app_key" {
  description = "Base64 encoded GitHub App private key"
  type        = string
  sensitive   = true
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "webhook_secret" {
  description = "GitHub webhook secret"
  type        = string
  sensitive   = true
}

variable "aws_credentials" {
  description = "Base64 encoded AWS credentials"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Base domain for Atlantis"
  type        = string
  default     = "example.com"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}



variable "r53_zone_id" {
  description = "Route53 zone ID"
  type        = string
}

variable "lb_frontend_subnets" {
  description = "List of subnet IDs for the load balancer frontend"
  type        = list(string)
  default     = [] # Empty list since ALB is disabled in minimal setup
}


