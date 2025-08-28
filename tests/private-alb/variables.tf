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

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}
