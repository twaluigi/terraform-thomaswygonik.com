# certificates 
# the certificate for cloudfront
resource "aws_acm_certificate" "cert" {
  provider          = "aws.us-east-1"
  domain_name       = "${var.site-name}"
  validation_method = "DNS"
}

# once the domain is validated, we can use it in a cert
resource "aws_acm_certificate_validation" "validate_cert" {
  provider        = "aws.us-east-1"
  certificate_arn = "${aws_acm_certificate.cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.validation.fqdn}",
  ]
}
