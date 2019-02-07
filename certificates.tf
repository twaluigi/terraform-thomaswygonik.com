# certificates 

# the certificate for cloudfront
resource "aws_acm_certificate" "cert" {
  provider          = "aws.us-east-1"
  domain_name       = "${var.site-name}"
  validation_method = "DNS"
}

# validating that we own the domain through route53
resource "aws_route53_record" "validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

# once the domain is validated, we can use it in a cert
resource "aws_acm_certificate_validation" "validate_cert" {
  provider        = "aws.us-east-1"
  certificate_arn = "${aws_acm_certificate.cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.validation.fqdn}",
  ]
}
