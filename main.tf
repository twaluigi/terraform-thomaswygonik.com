# generate a random string to use as a header between S3 and Cloudfront
resource "random_string" "custom_header_value" {
  length  = 16
  special = false
}

# hosted zone for the domain used by cloudfront
data "aws_route53_zone" "external" {
  name         = "${var.hosted-zone-name}"
  private_zone = false
}

# zone apex record corresponding to our cloudfront distribution
resource "aws_route53_record" "A_site" {
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
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  name    = "${var.site-name}"
  type    = "AAAA"

  alias {
    name                   = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = false
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

  tags {
    Name        = "S3_website_${var.site-name}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }

  website {
    index_document = "index.html"
  }
}

# bucket where logs for the website go
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.site-name}-site-logs"
  acl           = "log-delivery-write"
  force_destroy = true

  tags {
    Name        = "S3_logs_${var.site-name}"
    Project     = "${var.project}"
    Environemtn = "${var.environment}"
  }
}

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled          = true
  is_ipv6_enabled  = true
  price_class      = "PriceClass_All"
  http_version     = "http2"
  retain_on_delete = false
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
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # setting root object otherwise some browsers and cache won't know what file to get
  default_root_object = "index.html"

  tags {
    Name        = "cloudfront_${var.site-name}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

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

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.logs.bucket_domain_name}"
    prefix          = "cloudfront_${var.site-name}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # use the certificate from the validation earlier
  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate_validation.validate_cert.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}
