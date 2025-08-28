variable "ami" {}
variable "region" {}
variable "mahi_region" {
  description = "MahiFX region, used for hiera clasification"
  type        = string
}
variable "domain" {}

variable "create_alb" {
  description = "Whether to create Application Load Balancer"
  type        = bool
  default     = true
}

variable "create_dns_records" {
  description = "Whether to create Route53 DNS records"
  type        = bool
  default     = true
}

variable "enable_web_authentication" {
  description = "Whether to enable basic authentication for Atlantis web interface"
  type        = bool
  default     = false
}

variable "eip" {
  description = "Toggle to assign an EIP to the instance"
  type        = bool
  default     = false
}

variable "availability_zone" {
  type    = string
  default = ""
}

variable "mgmt_subnets" {
  type = list(string)
}

variable "key_name" {
  type    = string
  default = "deploy"
}

variable "r53_zone_id" {}

variable "name" {
  type = string
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "root_volume_size" {
  type    = number
  default = 15
}
variable "encrypted_volume" {
  description = "encrypted volume"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID to create the EC2 instance in"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to place ENI in"
  type        = string
}

variable "volumes" {
  description = "EBS volumes configuration for user data volumes setup script"
  type        = list(any)
  default     = []
}

variable "instance_iam_role" {
  description = "Override default IAM Instance Role"
  type        = string
  default     = null
}

variable "additional_security_groups" {
  description = "Additional security groups for the instance"
  type        = list(string)
  default     = []
}

variable "additional_policies_arn" {
  description = "ARNs of Additional IAM policies for the instance"
  type        = list(string)
  default     = []
}

variable "additional_policies" {
  description = "Additional IAM policies for the instance"
  type = list(object({
    name        = string
    name_prefix = optional(string)
    description = optional(string)
    policy      = string
  }))
  default = []
}

variable "instance_type" {
  description = "Instance type to launch"
  type        = string
}

variable "additional_tags" {
  type    = map(any)
  default = {}
}

locals {
  location = replace(var.region, "-", "")

  tags = {
    Name       = var.name
    managed_by = "terraform"
  }

  # Prepare a suitable map for for_each, used by aws_ebs_volume and
  # aws_volume_attachment.
  volumes = {
    for volume in var.volumes :
    volume.device => {
      lv_name      = volume.lv_name
      size         = volume.size
      dlm_snapshot = volume.dlm_snapshot
      type         = lookup(volume, "type", "gp3")
    }
  }

  # Prepare a cut down volumes map suitable for the EC2 user-data.
  user_data_volumes = [
    for volume in var.volumes : {
      device      = volume.device
      lv_name     = volume.lv_name
      mount_point = volume.mount_point
    }
  ]

  atlantis_domain = "${var.name}.${var.domain}"
}

# System versions
variable "atlantis_version" {
  description = "Version of Atlantis to install"
  type        = string
  default     = "0.35.1"
}

variable "conftest_version" {
  description = "Version of Conftest to install"
  type        = string
  default     = "0.59.0"
}

variable "git_lfs_version" {
  description = "Version of Git LFS to install"
  type        = string
  default     = "3.6.1"
}

variable "terraform_version" {
  description = "Version of Terraform to install"
  type        = string
  default     = "1.6.0"
}

variable "go_version" {
  description = "Version of Go to install"
  type        = string
  default     = "1.24.4"
}

# AWS credentials
variable "aws_credentials_base64" {
  description = "Base64-encoded AWS credentials file content"
  type        = string
  sensitive   = true
}

# GitHub configuration
variable "github_app_private_key" {
  description = "Base64 encoded GitHub App private key"
  type        = string
  sensitive   = true
}

variable "repo_allowlist" {
  description = "List of repositories Atlantis can access"
  type        = string
  default     = "github.com/MahiFX/*"
}


variable "atlantis_username" {
  description = "Username for Atlantis basic authentication"
  type        = string
  default     = null
  sensitive   = true
}

variable "atlantis_password" {
  description = "Password for Atlantis basic authentication"
  type        = string
  default     = null
  sensitive   = true
}

variable "lb_frontend_subnets" {
  description = "List of subnet IDs for the load balancer frontend"
  type        = list(string)
}

variable "atlantis_gh_webhook_secret" {
  description = "GitHub webhook secret for Atlantis"
  type        = string
  sensitive   = true
}

variable "atlantis_gh_app_id" {
  description = "GitHub App ID for Atlantis"
  type        = string
}

# Security Group Rules
variable "alb_security_group_rules" {
  description = "Additional security group rules for ALB. Each rule can specify either cidr_blocks, source_security_group_id, or prefix_list_ids"
  type = list(object({
    type                     = string
    from_port               = number
    to_port                 = number
    protocol                = string
    description             = string
    cidr_blocks             = optional(list(string))
    source_security_group_id = optional(string)
    self                    = optional(bool)
  }))
  default = []
}

variable "atlantis_security_group_rules" {
  description = "Additional security group rules for Atlantis instance. Each rule can specify either cidr_blocks, source_security_group_id, or prefix_list_ids"
  type = list(object({
    type                     = string
    from_port               = number
    to_port                 = number
    protocol                = string
    description             = string
    cidr_blocks             = optional(list(string))
    source_security_group_id = optional(string)
    self                    = optional(bool)
  }))
  default = []
}

