resource "aws_s3_bucket" "redirect_blog_bucket" {
  provider = "aws.site_account"
  bucket   = "blog.${var.site_fqdn}"
  acl      = "private"

  logging {
    target_bucket = "${aws_s3_bucket.log_bucket.bucket}"
    target_prefix = "blog.${var.site_fqdn}/"
  }

  tags = {
    Name        = "S3_blog_redirect_${var.site_fqdn}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
    [{
    "Redirect": {
		"HostName" : "${var.site_fqdn}",
		"HttpRedirectCode" : "301",
		"Protocol" : "https"}
		}]
		EOF
  }
}

resource "aws_s3_bucket" "redirect_www_bucket" {
  provider = "aws.site_account"
  bucket = "www.${var.site_fqdn}"
  acl = "private"

  logging {
    target_bucket = "${aws_s3_bucket.log_bucket.bucket}"
    target_prefix = "www.${var.site_fqdn}/"
  }

  tags = {
    Name = "S3_www_redirect_${var.site_fqdn}"
    Project = "${var.project}"
    Environment = "${var.environment}"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
    [{
    "Redirect": {
		"HostName" : "${var.site_fqdn}",
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
    bucket_arn          = "${aws_s3_bucket.site_bucket.arn}"
    custom_header_value = "${random_string.custom_header_value.result}"
  }
}

resource "aws_s3_bucket_policy" "site_bucket_policy" {
  provider = "aws.site_account"
  bucket   = "${aws_s3_bucket.site_bucket.id}"
  policy   = "${data.template_file.bucket_policy.rendered}"
}

# where the website data goes
resource "aws_s3_bucket" "site_bucket" {
  provider      = "aws.site_account"
  bucket        = "${var.site_fqdn}"
  force_destroy = true

  logging {
    target_bucket = "${aws_s3_bucket.log_bucket.bucket}"
    target_prefix = "${var.site_fqdn}/"
  }

  tags = {
    Name        = "S3_website_${var.site_fqdn}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }

  website {
    index_document = "index.html"
  }
}

# bucket where logs for the website go
resource "aws_s3_bucket" "log_bucket" {
  provider      = "aws.site_account"
  bucket        = "${var.site_fqdn}-site-logs"
  acl           = "log-delivery-write"
  force_destroy = true

  tags = {
    Name        = "S3_logs_${var.site_fqdn}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}
