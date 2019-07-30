provider "aws" {
  region = "${var.region}"
  version = "~>2.0"
  profile = "site-account"
}

# custom provider for Cloudfront ACM certificate - must be in us-east-1
provider "aws" {
  region  = "us-east-1"
  alias   = "us-east-1"
  version = "~>2.0"
  profile = "site-account"
}

# Route53 records are in the root account
provider "aws" { 
  region = "${var.region}"
  alias = "root-account"
  version = "~>2.0"
  profile = "root-account"
  
}

terraform {
  backend "s3" {}
  required_version = ">= 0.12"
}

data "aws_caller_identity" "current" {}