#ATLANTIS ALB
module "alb" {
  count  = var.create_alb ? 1 : 0
  source = "terraform-aws-modules/alb/aws"
  version = "8.7.0"
  
  providers = {
    aws = aws
  }
  name = "${var.name}-alb"

  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  subnets         = var.lb_frontend_subnets
  create_security_group = false
  security_groups = [module.alb-sg[0].security_group_id]


  target_groups = [
    {
      name_prefix      = "tg-"
      backend_protocol = "HTTP"
      backend_port     = 4141
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = {
        my_target = {
          target_id = aws_instance.instance.id
          port      = 4141
        }
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "${aws_acm_certificate_validation.atlantis-acm.certificate_arn}"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = local.tags
}


resource "aws_route53_record" "atlantis" {
  count = var.create_dns_records ? 1 : 0
  provider = aws.r53
  zone_id  = var.r53_zone_id
  name     = local.atlantis_domain
  type     = "A"
  alias {
    name                   = module.alb[0].lb_dns_name
    zone_id                = module.alb[0].lb_zone_id
    evaluate_target_health = true
  }
}
