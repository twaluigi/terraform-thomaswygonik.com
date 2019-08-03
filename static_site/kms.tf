resource "aws_s3_bucket" "codepipeline_artifacts" {
  provider      = "aws.site_account"
  bucket        = "${var.site_fqdn}-codepipeline-artifacts"
  acl           = "private"
  force_destroy = true
}

data "aws_kms_alias" "s3kmskey" {
  provider = "aws.site_account"
  name     = "alias/aws/s3"
}