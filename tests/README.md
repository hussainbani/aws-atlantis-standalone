# Atlantis Module Tests

This directory contains test configurations for the Atlantis module.

## Test Configurations

### 1. Minimal Configuration (`minimal/`)
Demonstrates the minimal required configuration to deploy Atlantis:
- No ALB (direct instance access)
- No DNS records
- Basic GitHub App integration
- Minimal security group rules

### 2. Private ALB Configuration (`private-alb/`)
Demonstrates a private Atlantis deployment:
- ALB in private subnets
- DNS records
- Web authentication enabled
- VPC-restricted access
- Enhanced security group rules

## Running Tests

### Prerequisites
1. AWS credentials configured
2. GitHub App credentials:
   - Private key
   - App ID
   - Webhook secret
3. Terraform >= 1.0.0

### Test Variables
Create a `terraform.tfvars` file in each test directory with the following variables:
```hcl
github_app_key    = "your-base64-encoded-private-key"
github_app_id     = "your-app-id"
webhook_secret    = "your-webhook-secret"
aws_credentials   = "your-base64-encoded-aws-credentials"
domain           = "your-domain.com"
github_org       = "your-github-org"
```

### Running Tests Locally
1. Initialize Terraform:
   ```bash
   cd tests/minimal # or tests/private-alb
   terraform init
   ```

2. Validate configuration:
   ```bash
   terraform validate
   ```

3. Plan deployment:
   ```bash
   terraform plan
   ```

### Automated Tests
The module includes GitHub Actions workflows that automatically run:
- Terraform validation
- Format checking
- TFLint

## Test Cases Coverage

The test configurations verify:

1. Basic Functionality
   - Instance deployment
   - Security group creation
   - IAM role setup

2. ALB Features
   - ALB creation/configuration
   - HTTPS listener setup
   - Target group configuration

3. Security
   - Security group rules
   - Web authentication
   - IAM permissions

4. DNS and SSL
   - Route53 record creation
   - ACM certificate provisioning

5. GitHub Integration
   - GitHub App configuration
   - Webhook setup

## Adding New Tests

To add new test configurations:

1. Create a new directory under `tests/`
2. Add `main.tf` with your test configuration
3. Update the GitHub Actions workflow to include your new test
4. Document the new test case in this README
