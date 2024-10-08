resource "aws_route53_zone" "prod" {
  name = var.prod_domain
}

resource "aws_acm_certificate" "prod_backend" {
  domain_name       = var.prod_domain
  validation_method = "DNS"
}

resource "aws_route53_record" "prod_backend_certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.prod_backend.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.prod.zone_id
}

resource "aws_acm_certificate_validation" "prod_backend" {
  certificate_arn         = aws_acm_certificate.prod_backend.arn
  validation_record_fqdns = [for record in aws_route53_record.prod_backend_certificate_validation : record.fqdn]
}

resource "aws_route53_record" "prod_backend_a" {
  zone_id = aws_route53_zone.prod.zone_id
  name    = var.prod_domain
  type    = "A"

  alias {
    name                   = aws_lb.prod.dns_name
    zone_id                = aws_lb.prod.zone_id
    evaluate_target_health = true
  }
}
