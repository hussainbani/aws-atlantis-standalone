#atlantis-acm SSL certificate
resource "aws_route53_record" "atlantis-acm" {
  provider = aws.r53
  for_each = {
    for dvo in aws_acm_certificate.atlantis-acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = var.r53_zone_id
}
resource "aws_acm_certificate_validation" "atlantis-acm" {
  certificate_arn         = aws_acm_certificate.atlantis-acm.arn
  validation_record_fqdns = [for record in aws_route53_record.atlantis-acm : record.fqdn]
}
resource "aws_acm_certificate" "atlantis-acm" {
  domain_name       = local.atlantis_domain
  validation_method = "DNS"
}
