provider "aws" {
  region = "${var.region}"
}

# custom provider for Cloudfront ACM certificate - must be in us-east-1
provider "aws" {
  region  = "us-east-1"
  alias   = "us-east-1"
  version = "~>2.0"
}

terraform {
  backend "s3" {}
  required_version = ">= 0.12"
}

data "aws_caller_identity" "current" {}