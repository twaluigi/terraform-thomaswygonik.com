output "cert_arn" {
  value = "${aws_acm_certificate_validation.default.certificate_arn}"
}

output "website_url" {
  value = "https://${var.site-name}"
}
