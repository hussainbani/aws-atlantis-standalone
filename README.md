# Terraform Atlantis Module

This module deploys a self-hosted Atlantis server on AWS with optional load balancer and authentication features.

> **Note**: This module is specifically designed for AWS and uses AWS GitHub App integration for authentication.

## Prerequisites

### AWS Setup
- An AWS account with necessary permissions
- A VPC with appropriate subnets
- Route53 hosted zone for DNS management

### GitHub App Setup
This module uses GitHub App for authentication. You need to create a GitHub App with the following settings:

1. Go to your organization settings -> GitHub Apps -> New GitHub App
2. Configure the following settings:
   - GitHub App name: `atlantis-{your-org-name}`
   - Homepage URL: `https://your-atlantis-domain`
   - Webhook URL: `https://your-atlantis-domain/events`
   - Webhook secret: Generate a secure secret
   - Permissions needed:
     - Repository permissions:
       - Actions: Read-only
       - Administration: Read-only
       - Checks: Read & write
       - Contents: Read & write
       - Issues: Read & write
       - Metadata: Read-only
       - Pull requests: Read & write
     - Organization permissions:
       - Members: Read-only
       - Plan: Read-only
   - Where can this GitHub App be installed?: Only on this account

3. After creating the app:
   - Note down the App ID
   - Generate a private key and base64 encode it
   - Install the app in your organization/repositories

For detailed instructions on setting up GitHub App for Atlantis, refer to:
[Atlantis GitHub App Documentation](https://www.runatlantis.io/docs/access-credentials.html#github-app)

## Features

- Deploys Atlantis on an EC2 instance
- Optional Application Load Balancer with HTTPS support
- Optional web authentication
- Configurable security group rules
- DNS management with Route53
- Support for EBS volumes
- Customizable IAM roles and policies
- EIP support for direct instance access

## Usage

```hcl
module "atlantis" {
  source = "path/to/module"

  name          = "atlantis"
  ami           = "ami-1234567890"
  instance_type = "t3.small"
  region        = "us-east-1"
  domain        = "example.com"
  vpc_id        = "vpc-1234567890"
  subnet_id     = "subnet-1234567890"
  mgmt_subnets  = ["10.0.0.0/8"]

  # Optional features
  create_alb                 = true
  create_dns_records        = true
  enable_web_authentication = true
  eip                      = false

  # Authentication (required if enable_web_authentication = true)
  atlantis_username = "admin"
  atlantis_password = "your-secure-password"

  # Load balancer configuration (required if create_alb = true)
  lb_frontend_subnets = ["subnet-1234567890", "subnet-0987654321"]

  # GitHub configuration
  github_app_private_key = "base64-encoded-private-key"
  atlantis_gh_app_id    = "123456"
  repo_allowlist        = "github.com/yourorg/*"

  # Additional security group rules
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
      source_security_group_id = "sg-1234567890"
    }
  ]

  # Additional tags
  additional_tags = {
    Environment = "prod"
    Team        = "devops"
  }
}
```

## Requirements

### Terraform and Providers

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

### AWS Requirements

This module is exclusively designed for AWS and requires:

1. AWS Provider Configuration:
   - Region where Atlantis will be deployed
   - Appropriate IAM permissions to create:
     - EC2 instances
     - Security Groups
     - IAM roles and policies
     - Load Balancers
     - ACM certificates
     - Route53 records

2. Network Prerequisites:
   - A VPC with private and public subnets
   - Internet Gateway for public subnets
   - NAT Gateway for private subnets (if using private subnets)
   - Route53 Hosted Zone for DNS management

3. IAM Permissions:
   The AWS account deploying this module needs permissions to create and manage:
   ```
   - ec2:*
   - elasticloadbalancing:*
   - iam:*
   - acm:*
   - route53:*
   ```

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

> **Important**: This module only supports AWS and does not provide implementations for other cloud providers.

## Input Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| ami | AMI ID for the Atlantis instance | string |
| region | AWS region | string |
| domain | Base domain for Atlantis | string |
| vpc_id | VPC ID where resources will be created | string |
| subnet_id | Subnet ID for the instance | string |
| mgmt_subnets | List of management CIDR blocks for SSH access | list(string) |
| instance_type | EC2 instance type | string |
| name | Name identifier for the Atlantis deployment | string |
| r53_zone_id | Route53 zone ID for DNS records | string |
| aws_credentials_base64 | Base64-encoded AWS credentials file content | string |
| github_app_private_key | Base64 encoded GitHub App private key | string |
| atlantis_gh_app_id | GitHub App ID for Atlantis | string |
| atlantis_gh_webhook_secret | GitHub webhook secret for Atlantis | string |
| lb_frontend_subnets | List of subnet IDs for the load balancer frontend | list(string) |

### Feature Flags

| Name | Description | Type | Default |
|------|-------------|------|---------|
| create_alb | Whether to create Application Load Balancer | bool | true |
| create_dns_records | Whether to create Route53 DNS records | bool | true |
| enable_web_authentication | Whether to enable basic authentication | bool | false |
| eip | Toggle to assign an EIP to the instance | bool | false |
| encrypted_volume | Whether to encrypt the root volume | bool | false |

### Instance Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| mahi_region | MahiFX region for hiera classification | string | |
| availability_zone | AZ for the instance | string | "" |
| key_name | SSH key name | string | "deploy" |
| root_volume_type | EBS root volume type | string | "gp3" |
| root_volume_size | EBS root volume size in GB | number | 15 |
| volumes | Additional EBS volumes configuration | list(any) | [] |

### Security Groups and IAM

| Name | Description | Type | Default |
|------|-------------|------|---------|
| instance_iam_role | Override default IAM Instance Role | string | null |
| additional_security_groups | Additional security groups for the instance | list(string) | [] |
| additional_policies_arn | ARNs of Additional IAM policies | list(string) | [] |
| additional_policies | Additional IAM policies configuration | list(object) | [] |
| alb_security_group_rules | Additional security group rules for ALB | list(object) | [] |
| atlantis_security_group_rules | Additional security group rules for Atlantis | list(object) | [] |

### Authentication

| Name | Description | Type | Default |
|------|-------------|------|---------|
| atlantis_username | Username for basic authentication | string | null |
| atlantis_password | Password for basic authentication | string | null |

### Version Control

| Name | Description | Type | Default |
|------|-------------|------|---------|
| atlantis_version | Version of Atlantis to install | string | "0.35.1" |
| conftest_version | Version of Conftest to install | string | "0.59.0" |
| git_lfs_version | Version of Git LFS to install | string | "3.6.1" |
| terraform_version | Version of Terraform to install | string | "1.6.0" |
| go_version | Version of Go to install | string | "1.24.4" |

### Repository Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| repo_allowlist | List of repositories Atlantis can access | string | "github.com/MahiFX/*" |

### Additional Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| additional_tags | Additional tags for all resources | map(any) | {} |

### Security Group Rules Configuration

Both `alb_security_group_rules` and `atlantis_security_group_rules` accept lists of objects with the following structure:

```hcl
{
  type                     = string       # "ingress" or "egress"
  from_port               = number
  to_port                 = number
  protocol                = string
  description             = string
  cidr_blocks             = optional(list(string))
  source_security_group_id = optional(string)
  self                    = optional(bool)
}
```

### Additional IAM Policies Configuration

The `additional_policies` variable accepts a list of objects with the following structure:

```hcl
{
  name        = string
  name_prefix = optional(string)
  description = optional(string)
  policy      = string
}
```

### EBS Volumes Configuration

The `volumes` variable accepts a list of objects defining additional EBS volumes:

```hcl
{
  device       = string
  lv_name      = string
  size         = number
  dlm_snapshot = bool
  type         = optional(string, "gp3")
  mount_point  = string
}
```

### Security Group Rules Variables

Both `alb_security_group_rules` and `atlantis_security_group_rules` accept lists of objects with the following structure:

```hcl
{
  type                     = string       # "ingress" or "egress"
  from_port               = number
  to_port                 = number
  protocol                = string
  description             = string
  cidr_blocks             = list(string) # Optional
  source_security_group_id = string      # Optional
  prefix_list_ids         = list(string) # Optional
  self                    = bool         # Optional
}
```

## Outputs

### Instance Outputs
- `instance_id`: ID of the EC2 instance
- `instance_arn`: ARN of the EC2 instance
- `instance_private_ip`: Private IP address
- `public_ip`: Public IP address (if EIP enabled)

### Load Balancer Outputs
- `alb_id`: ID of the Application Load Balancer
- `alb_arn`: ARN of the Application Load Balancer
- `alb_dns_name`: DNS name of the ALB
- `target_group_arns`: ARNs of the target groups
- `target_group_names`: Names of the target groups

### Security Group Outputs
- `atlantis_security_group_id`: ID of the Atlantis instance security group
- `alb_security_group_id`: ID of the ALB security group

### Other Outputs
- `acm_certificate_arn`: ARN of the ACM certificate
- `atlantis_domain`: Domain name for the Atlantis server
- `instance_role_name`: Name of the IAM role
- `instance_role_arn`: ARN of the IAM role

## License

This module is released under the MIT License.
