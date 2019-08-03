# generate a random string to use as a header between S3 and Cloudfront
resource "random_string" "custom_header_value" {
  length  = 16
  special = false
}

# hosted zone for the domain used by cloudfront
resource "aws_cloudfront_distribution" "website_cdn" {
  provider         = "aws.site_account"
  enabled          = true
  is_ipv6_enabled  = true
  price_class      = "PriceClass_All"
  http_version     = "http2"
  retain_on_delete = false
  aliases          = ["${var.site_fqdn}"]
  comment          = "Managed by Terraform"

  # custom origin configuration using S3 website
  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.site_bucket.id}"
    domain_name = "${aws_s3_bucket.site_bucket.website_endpoint}"

    # header that allows only this Cloudfront distribution to access objects in S3

    custom_header {
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

  tags = {
    Name        = "cloudfront_${var.site_fqdn}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-bucket-${aws_s3_bucket.site_bucket.id}"
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
    bucket          = "${aws_s3_bucket.log_bucket.bucket_domain_name}"
    prefix          = "cloudfront_${var.site_fqdn}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # use the certificate from the validation earlier
  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate_validation.validate_website_cert.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}


resource "aws_cloudfront_distribution" "redirect_www_distribution" {
  provider = "aws.site_account"
  origin {
    domain_name = "${aws_s3_bucket.redirect_www_bucket.website_endpoint}"
    origin_id   = "origin-bucket-${aws_s3_bucket.redirect_www_bucket.id}"

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
  aliases          = ["www.${var.site_fqdn}"]
  comment          = "Managed by Terraform"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-bucket-${aws_s3_bucket.redirect_www_bucket.id}"
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
    bucket          = "${aws_s3_bucket.log_bucket.bucket_domain_name}"
    prefix          = "cloudfront_www.${var.site_fqdn}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "cloudfront_www_redirect_${var.site_fqdn}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  # use the certificate from the validation earlier
  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate_validation.validate_www_redirect_cert.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

resource "aws_cloudfront_distribution" "redirect_blog_distribution" {
  provider = "aws.site_account"
  origin {
    domain_name = "${aws_s3_bucket.redirect_blog_bucket.website_endpoint}"
    origin_id   = "origin-bucket-${aws_s3_bucket.redirect_blog_bucket.id}"

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
  aliases          = ["blog.${var.site_fqdn}"]
  comment          = "Managed by Terraform"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-bucket-${aws_s3_bucket.redirect_blog_bucket.id}"
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
    bucket          = "${aws_s3_bucket.log_bucket.bucket_domain_name}"
    prefix          = "cloudfront_blog.${var.site_fqdn}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "cloudfront_blog_redirect_${var.site_fqdn}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  # use the certificate from the validation earlier
  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate_validation.validate_blog_redirect_cert.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}


