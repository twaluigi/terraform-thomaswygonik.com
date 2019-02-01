provider "aws" {
  region = "${var.region}"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

resource "aws_s3_bucket" "logs" {
  bucket        = "${var.site-name}-site-logs"
  acl           = "log-delivery-write"
  force_destroy = true
}

resource "aws_acm_certificate" "cert" {
  provider          = "aws.us-east-1"
  domain_name       = "www.${var.site-name}"
  validation_method = "DNS"
}

data "aws_route53_zone" "external" {
  name         = "tomwygonik.com"
  private_zone = false
}

resource "aws_route53_record" "validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "default" {
  provider        = "aws.us-east-1"
  certificate_arn = "${aws_acm_certificate.cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.validation.fqdn}",
  ]
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "cloudfront origin access identity"
}

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled      = true
  price_class  = "PriceClass_All"
  http_version = "http2"
  aliases      = ["www.${var.site-name}"]

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.www_site.id}"
    domain_name = "www.${var.site-name}.s3.${var.region}.amazonaws.com"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-bucket-${aws_s3_bucket.www_site.id}"

    min_ttl     = "0"
    default_ttl = "300"
    max_ttl     = "1200"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.cert.arn}"
    ssl_support_method  = "sni-only"
  }
}

data "template_file" "bucket_policy" {
  template = "${file("bucket_policy.json")}"

  vars {
    origin_access_identity_arn = "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"
    bucket                     = "${aws_s3_bucket.www_site.arn}"
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = "${aws_s3_bucket.www_site.id}"
  policy = "${data.template_file.bucket_policy.rendered}"
}

resource "aws_s3_bucket" "www_site" {
  bucket = "www.${var.site-name}"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "www.${var.site-name}/"
  }

  website {
    index_document = "index.html"
  }
}

resource "aws_route53_record" "www_site" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "www.${var.site-name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}
