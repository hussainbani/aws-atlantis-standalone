# Instance outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.instance.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.instance.arn
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.instance.private_ip
}

output "public_ip" {
  description = "Public IP address (from EIP if enabled)"
  value       = var.eip ? aws_eip.eip[0].public_ip : ""
}

# Security Group outputs
output "atlantis_security_group_id" {
  description = "ID of the Atlantis instance security group"
  value       = module.atlantis-sg.security_group_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = var.create_alb ? module.alb-sg[0].security_group_id : null
}

# Load Balancer outputs
output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = var.create_alb ? module.alb[0].lb_id : null
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = var.create_alb ? module.alb[0].lb_arn : null
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = var.create_alb ? module.alb[0].lb_dns_name : null
}

output "target_group_arns" {
  description = "ARNs of the target groups"
  value       = var.create_alb ? module.alb[0].target_group_arns : null
}

output "target_group_names" {
  description = "Names of the target groups"
  value       = var.create_alb ? module.alb[0].target_group_names : null
}

# DNS and Certificate outputs
output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = var.create_alb ? aws_acm_certificate.atlantis-acm.arn : null
}

output "atlantis_domain" {
  description = "Domain name for the Atlantis server"
  value       = local.atlantis_domain
}

# IAM outputs
output "instance_role_name" {
  description = "Name of the IAM role attached to the Atlantis instance"
  value       = var.instance_iam_role == null ? aws_iam_role.role["iam-instance-profile"].name : var.instance_iam_role
}

output "instance_role_arn" {
  description = "ARN of the IAM role attached to the Atlantis instance"
  value       = var.instance_iam_role == null ? aws_iam_role.role["iam-instance-profile"].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.instance_iam_role}"
}

# Additional identifiers
output "name" {
  description = "Name identifier of the Atlantis deployment"
  value       = var.name
}

output "tags" {
  description = "Tags applied to the Atlantis resources"
  value       = local.tags
}
