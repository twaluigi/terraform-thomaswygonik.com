
data "aws_route53_zone" "external" {
  name         = "${var.hosted_zone_name}"
  private_zone = false
}

# zone apex record corresponding to our cloudfront distribution
resource "aws_route53_record" "A_site" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "${var.site_fqdn}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# zone apex for ipv6 
resource "aws_route53_record" "AAAA_site" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "${var.site_fqdn}"
  type    = "AAAA"

  alias {
    name                   = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# validating that we own the domain through route53
resource "aws_route53_record" "validation" {
  name    = "${aws_acm_certificate.website_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.website_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.website_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

# validating that we own the domain through route53
resource "aws_route53_record" "www_validation" {
  name    = "${aws_acm_certificate.www_redirect_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.www_redirect_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.www_redirect_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_route53_record" "A_www" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "www.${var.site_fqdn}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect_www_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect_www_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "AAAA_www" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "www.${var.site_fqdn}"
  type    = "AAAA"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect_www_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect_www_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# validating that we own the domain through route53
resource "aws_route53_record" "blog_validation" {
  name    = "${aws_acm_certificate.blog_redirect_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.blog_redirect_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.blog_redirect_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}



resource "aws_route53_record" "A_blog" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "blog.${var.site_fqdn}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect_blog_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect_blog_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "AAAA_blog" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "blog.${var.site_fqdn}"
  type    = "AAAA"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect_blog_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect_blog_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}