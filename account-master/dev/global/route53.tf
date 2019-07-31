data "aws_route53_zone" "external" {
  provider = "aws.root-account"
  name         = "${var.hosted-zone-name}"
  private_zone = false
}

# zone apex record corresponding to our cloudfront distribution
resource "aws_route53_record" "A_site" {
    provider = "aws.root-account"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "${var.site-name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# zone apex for ipv6 
resource "aws_route53_record" "AAAA_site" {
    provider = "aws.root-account"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "${var.site-name}"
  type    = "AAAA"

  alias {
    name                   = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# validating that we own the domain through route53
resource "aws_route53_record" "validation" {
    provider = "aws.root-account"
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

# validating that we own the domain through route53
resource "aws_route53_record" "www_validation" {
    provider = "aws.root-account"
  name = "${aws_acm_certificate.www_cert.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.www_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.www_cert.domain_validation_options.0.resource_record_value}"]
  ttl = "60"
}

resource "aws_route53_record" "A_www" {
    provider = "aws.root-account"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name = "www.${var.site-name}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.redirect_www_distribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.redirect_www_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "AAAA_www" {
    provider = "aws.root-account"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name = "www.${var.site-name}"
  type = "AAAA"

  alias {
    name = "${aws_cloudfront_distribution.redirect_www_distribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.redirect_www_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# validating that we own the domain through route53
resource "aws_route53_record" "blog_validation" {
    provider = "aws.root-account"
  name    = "${aws_acm_certificate.blog_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.blog_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.blog_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}



resource "aws_route53_record" "A_blog" {
    provider = "aws.root-account"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "blog.${var.site-name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect_blog_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect_blog_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "AAAA_blog" {
    provider = "aws.root-account"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "blog.${var.site-name}"
  type    = "AAAA"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect_blog_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect_blog_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}