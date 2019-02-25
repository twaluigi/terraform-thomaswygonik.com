# website redirects
################### USING CLOUDFRONT ############################
resource "aws_s3_bucket" "redirect_www" {
  bucket = "www.${var.site-name}"
  acl    = "private"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "www.${var.site-name}/"
  }

  tags {
    Name        = "S3_www_redirect_${var.site-name}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
    [{
    "Redirect": {
		"HostName" : "${var.site-name}",
		"HttpRedirectCode" : "301",
		"Protocol" : "https"}
		}]
		EOF
  }
}

# the certificate for cloudfront
resource "aws_acm_certificate" "www_cert" {
  provider          = "aws.us-east-1"
  domain_name       = "www.${var.site-name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# validating that we own the domain through route53
resource "aws_route53_record" "www_validation" {
  name    = "${aws_acm_certificate.www_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.www_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.www_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

# once the domain is validated, we can use it in a cert
resource "aws_acm_certificate_validation" "www_validate_cert" {
  provider        = "aws.us-east-1"
  certificate_arn = "${aws_acm_certificate.www_cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.www_validation.fqdn}",
  ]
}

resource "aws_cloudfront_distribution" "redirect_www_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.redirect_www.website_endpoint}"
    origin_id   = "origin-bucket-${aws_s3_bucket.redirect_www.id}"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled          = true
  is_ipv6_enabled  = true
  price_class      = "PriceClass_All"
  http_version     = "http2"
  retain_on_delete = false
  aliases          = ["www.${var.site-name}"]
  comment          = "Managed by Terraform"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-bucket-${aws_s3_bucket.redirect_www.id}"
    min_ttl                = "0"
    default_ttl            = "300"
    max_ttl                = "1200"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.logs.bucket_domain_name}"
    prefix          = "cloudfront_www.${var.site-name}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Name        = "cloudfront_www_redirect_${var.site-name}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  # use the certificate from the validation earlier
  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate_validation.www_validate_cert.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

resource "aws_route53_record" "A_www" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "www.${var.site-name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect_www_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect_www_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "AAAA_www" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "www.${var.site-name}"
  type    = "AAAA"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect_www_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect_www_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "redirect_blog" {
  bucket = "blog.${var.site-name}"
  acl    = "private"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "blog.${var.site-name}/"
  }

  tags {
    Name        = "S3_blog_redirect_${var.site-name}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
    [{
    "Redirect": {
		"HostName" : "${var.site-name}",
		"HttpRedirectCode" : "301",
		"Protocol" : "https"}
		}]
		EOF
  }
}

# the certificate for cloudfront
resource "aws_acm_certificate" "blog_cert" {
  provider          = "aws.us-east-1"
  domain_name       = "blog.${var.site-name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# validating that we own the domain through route53
resource "aws_route53_record" "blog_validation" {
  name    = "${aws_acm_certificate.blog_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.blog_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.blog_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

# once the domain is validated, we can use it in a cert
resource "aws_acm_certificate_validation" "blog_validate_cert" {
  provider        = "aws.us-east-1"
  certificate_arn = "${aws_acm_certificate.blog_cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.blog_validation.fqdn}",
  ]
}

resource "aws_cloudfront_distribution" "redirect_blog_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.redirect_blog.website_endpoint}"
    origin_id   = "origin-bucket-${aws_s3_bucket.redirect_blog.id}"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled          = true
  is_ipv6_enabled  = true
  price_class      = "PriceClass_All"
  http_version     = "http2"
  retain_on_delete = false
  aliases          = ["blog.${var.site-name}"]
  comment          = "Managed by Terraform"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-bucket-${aws_s3_bucket.redirect_blog.id}"
    min_ttl                = "0"
    default_ttl            = "300"
    max_ttl                = "1200"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.logs.bucket_domain_name}"
    prefix          = "cloudfront_blog.${var.site-name}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Name        = "cloudfront_blog_redirect_${var.site-name}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  # use the certificate from the validation earlier
  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate_validation.blog_validate_cert.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

resource "aws_route53_record" "A_blog" {
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
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "blog.${var.site-name}"
  type    = "AAAA"

  alias {
    name                   = "${aws_cloudfront_distribution.redirect_blog_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.redirect_blog_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
