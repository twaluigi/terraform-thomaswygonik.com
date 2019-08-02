# certificates 
# the certificate for cloudfront
resource "aws_acm_certificate" "cert" {
  provider          = "aws.site_account_us-east-1"
  domain_name       = "${var.site-name}"
  validation_method = "DNS"
}

# once the domain is validated, we can use it in a cert
resource "aws_acm_certificate_validation" "validate_cert" {
  provider        = "aws.site_account_us-east-1"
  certificate_arn = "${aws_acm_certificate.cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.validation.fqdn}",
  ]
}

# the certificate for cloudfront
resource "aws_acm_certificate" "www_cert" {
  provider          = "aws.site_account_us-east-1"
  domain_name       = "www.${var.site-name}"
  validation_method = "DNS"
}

# once the domain is validated, we can use it in a cert
resource "aws_acm_certificate_validation" "blog_validate_cert" {
  provider        = "aws.site_account_us-east-1"
  certificate_arn = "${aws_acm_certificate.blog_cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.blog_validation.fqdn}",
  ]
}

# once the domain is validated, we can use it in a cert
resource "aws_acm_certificate_validation" "www_validate_cert" {
  provider        = "aws.site_account_us-east-1"
  certificate_arn = "${aws_acm_certificate.www_cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.www_validation.fqdn}",
  ]
}


# the certificate for cloudfront
resource "aws_acm_certificate" "blog_cert" {
  provider          = "aws.site_account_us-east-1"
  domain_name       = "blog.${var.site-name}"
  validation_method = "DNS"
}