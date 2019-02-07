output "cert_arn" {
  value = "${aws_acm_certificate_validation.validate_cert.certificate_arn}"
}

output "website_url" {
  value = "https://${var.site-name}"
}
