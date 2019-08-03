# certificates 
# the certificate for cloudfront
resource "aws_acm_certificate" "website_cert" {
  provider          = "aws.site_account_us-east-1"
  domain_name       = "${var.site_fqdn}"
  validation_method = "DNS"
}

# once the domain is validated, we can use it in a cert
resource "aws_acm_certificate_validation" "validate_website_cert" {
  provider        = "aws.site_account_us-east-1"
  certificate_arn = "${aws_acm_certificate.website_cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.validation.fqdn}",
  ]
}

# cert for www.$SITE redirect
resource "aws_acm_certificate" "www_redirect_cert" {
  provider          = "aws.site_account_us-east-1"
  domain_name       = "www.${var.site_fqdn}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "validate_www_redirect_cert" {
  provider        = "aws.site_account_us-east-1"
  certificate_arn = "${aws_acm_certificate.www_redirect_cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.www_validation.fqdn}",
  ]
}

# cert for blog.$SITE redirect
resource "aws_acm_certificate" "blog_redirect_cert" {
  provider          = "aws.site_account_us-east-1"
  domain_name       = "blog.${var.site_fqdn}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "validate_blog_redirect_cert" {
  provider        = "aws.site_account_us-east-1"
  certificate_arn = "${aws_acm_certificate.blog_redirect_cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.blog_validation.fqdn}",
  ]
}

