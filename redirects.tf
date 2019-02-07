# website redirects
# TODO change to include cloudfront and https
resource "aws_s3_bucket" "blog" {
  bucket = "blog.${var.site-name}"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "blog.${var.site-name}/"
  }

  website {
    redirect_all_requests_to = "https://${var.site-name}"
  }
}

resource "aws_route53_record" "A_blog" {
  name    = "blog.${var.site-name}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.blog.website_domain}"
    zone_id                = "${aws_s3_bucket.blog.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "AAAA_blog" {
  name    = "blog.${var.site-name}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  type    = "AAAA"

  alias {
    name                   = "${aws_s3_bucket.blog.website_domain}"
    zone_id                = "${aws_s3_bucket.blog.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket" "www" {
  bucket = "www.${var.site-name}"

  logging {
    target_bucket = "${aws_s3_bucket.logs.bucket}"
    target_prefix = "www.${var.site-name}/"
  }

  website {
    redirect_all_requests_to = "https://${var.site-name}"
  }
}

resource "aws_route53_record" "A_www" {
  name    = "www.${var.site-name}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.www.website_domain}"
    zone_id                = "${aws_s3_bucket.www.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "AAAA_www" {
  name    = "www.${var.site-name}"
  zone_id = "${data.aws_route53_zone.external.zone_id}"
  type    = "AAAA"

  alias {
    name                   = "${aws_s3_bucket.www.website_domain}"
    zone_id                = "${aws_s3_bucket.www.hosted_zone_id}"
    evaluate_target_health = false
  }
}
