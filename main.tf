provider "aws" {
  region = "${var.region}"
}

# custom provider for cloudfront ACM certificate - must be in us-east-1
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

# bucket where logs for the website go
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.site-name}-site-logs"
  acl           = "log-delivery-write"
  force_destroy = true
}

# the certificate for cloudfront
resource "aws_acm_certificate" "cert" {
  provider          = "aws.us-east-1"
  domain_name       = "${var.site-name}"
  validation_method = "DNS"
}

# hosted zone for the domain used by cloudfront
data "aws_route53_zone" "external" {
  name         = "${var.hosted-zone-name}"
  private_zone = false
}

# validating that we own the domain through route53
resource "aws_route53_record" "validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

# once the certificate is validated, we can use it
resource "aws_acm_certificate_validation" "default" {
  provider        = "aws.us-east-1"
  certificate_arn = "${aws_acm_certificate.cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.validation.fqdn}",
  ]
}

# generate a random string to use as a header between S3 and Cloudfront
resource "random_string" "custom_header_value" {
  length  = 16
  special = false
}

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled          = true
  price_class      = "PriceClass_All"
  http_version     = "http2"
  retain_on_delete = true
  aliases          = ["${var.site-name}"]
  comment          = "Managed by Terraform"

  # custom origin configuration using S3 website
  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.site.id}"
    domain_name = "${aws_s3_bucket.site.website_endpoint}"

    # header that allows only this Cloudfront distribution to access objects in S3
    custom_header = {
      name  = "User-Agent"
      value = "${random_string.custom_header_value.result}"
    }

    custom_origin_config {
      http_port  = "80"
      https_port = "443"

      # S3 websites are http only
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.1", "TLSv1.2"]
    }
  }

  # setting root object otherwise some browsers and cache won't know what file to get
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-bucket-${aws_s3_bucket.site.id}"

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

  # use the certificate from the validation earlier
  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate_validation.default.certificate_arn}"
    ssl_support_method  = "sni-only"
  }
}

# bucket policy template to allow Cloudfront to access objects in S3
data "template_file" "bucket_policy" {
  template = "${file("bucket_policy.json")}"

  vars {
    bucket_arn          = "${aws_s3_bucket.site.arn}"
    custom_header_value = "${random_string.custom_header_value.result}"
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = "${aws_s3_bucket.site.id}"
  policy = "${data.template_file.bucket_policy.rendered}"
}

# where the website data goes
resource "aws_s3_bucket" "site" {
  bucket        = "${var.site-name}"
  force_destroy = true

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "${var.site-name}/"
  }

  website {
    index_document = "index.html"
  }
}

# zone apex record corresponding to our cloudfront distribution
resource "aws_route53_record" "site" {
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "${var.site-name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}
