resource "aws_s3_bucket" "redirect_blog" {
  provider = "aws.site_account"
  bucket   = "blog.${var.site-name}"
  acl      = "private"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "blog.${var.site-name}/"
  }

  tags = {
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

resource "aws_s3_bucket" "redirect_www" {
  provider = "aws.site_account"
  bucket = "www.${var.site-name}"
  acl = "private"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "www.${var.site-name}/"
  }

  tags = {
    Name = "S3_www_redirect_${var.site-name}"
    Project = "${var.project}"
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

# bucket policy template to allow Cloudfront to access objects in S3
data "template_file" "bucket_policy" {
  template = "${file("${path.module}/bucket_policies/site_bucket_policy.json")}"
  vars = {
    bucket_arn          = "${aws_s3_bucket.site.arn}"
    custom_header_value = "${random_string.custom_header_value.result}"
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  provider = "aws.site_account"
  bucket   = "${aws_s3_bucket.site.id}"
  policy   = "${data.template_file.bucket_policy.rendered}"
}

# where the website data goes
resource "aws_s3_bucket" "site" {
  provider      = "aws.site_account"
  bucket        = "${var.site-name}"
  force_destroy = true

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "${var.site-name}/"
  }

  tags = {
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
  provider      = "aws.site_account"
  bucket        = "${var.site-name}-site-logs"
  acl           = "log-delivery-write"
  force_destroy = true

  tags = {
    Name        = "S3_logs_${var.site-name}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "codebuild_cache" {
  provider      = "aws.site_account"
  bucket        = "${var.site-name}-codebuild-cache"
  acl           = "private"
  force_destroy = true
}