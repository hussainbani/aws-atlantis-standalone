module "atlantis-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  
  create  = true
  name    = var.name
  use_name_prefix = false
  description     = "Security group for ${var.name} instance"
  vpc_id          = var.vpc_id
  tags            = local.tags
  
  # Base ingress rules with CIDR blocks
  ingress_with_cidr_blocks = concat([
    {
      from_port   = 0
      to_port     = 8
      protocol    = "icmp"
      description = "Allow echo request from all mgmt and VPC addresses"
      cidr_blocks = join(",", concat([data.aws_vpc.vpc.cidr_block], var.mgmt_subnets))
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH from all mgmt and VPC addresses"
      cidr_blocks = join(",", concat([data.aws_vpc.vpc.cidr_block], var.mgmt_subnets))
    },
    {
      from_port   = 4141
      to_port     = 4141
      protocol    = "tcp"
      description = "Allow atlantis from all mgmt and VPC addresses"
      cidr_blocks =join(",", concat([data.aws_vpc.vpc.cidr_block], var.mgmt_subnets))
    }
  ], [
    # Additional CIDR-based ingress rules
    for rule in var.atlantis_security_group_rules :
    {
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      description = rule.description
      cidr_blocks = join(",", rule.cidr_blocks)
    } if rule.type == "ingress" && rule.cidr_blocks != null
  ])

  # Base ingress rules with source security groups
  ingress_with_source_security_group_id = concat(
    var.create_alb ? [
      {
        from_port                = 4141
        to_port                  = 4141
        protocol                = "tcp"
        description             = "atlantis default port"
        source_security_group_id = module.alb-sg[0].security_group_id
      }
    ] : [],
    [
      # Additional source security group based ingress rules
      for rule in var.atlantis_security_group_rules :
      {
        from_port                = rule.from_port
        to_port                  = rule.to_port
        protocol                 = rule.protocol
        description             = rule.description
        source_security_group_id = rule.source_security_group_id
      } if rule.type == "ingress" && rule.source_security_group_id != null
    ]
  )

  # Base egress rules with CIDR blocks
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "ALLOW ALL"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "alb-sg" {
  count = var.create_alb ? 1 : 0
  
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  
  name            = "${var.name}-alb"
  use_name_prefix = false
  vpc_id          = var.vpc_id
  description     = "ALB security group"
  tags            = local.tags
  
  # Base ingress rules with CIDR blocks
  ingress_with_cidr_blocks = [
    # Additional CIDR-based ingress rules
    for rule in var.alb_security_group_rules :
    {
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      description = rule.description
      cidr_blocks = join(",", rule.cidr_blocks)
    } if rule.type == "ingress" && rule.cidr_blocks != null
  ]

  # Source security group based ingress rules
  ingress_with_source_security_group_id = [
    for rule in var.alb_security_group_rules :
    {
      from_port                = rule.from_port
      to_port                  = rule.to_port
      protocol                 = rule.protocol
      description             = rule.description
      source_security_group_id = rule.source_security_group_id
    } if rule.type == "ingress" && rule.source_security_group_id != null
  ]
  
  # Base egress rules with CIDR blocks
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "ALLOW ALL"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}