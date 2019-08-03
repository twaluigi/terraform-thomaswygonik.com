
# Master account for Route 53 records and state store
provider "aws" {
  version = "~>2.0"
  region  = "${var.region}"
}


# Site account for ACM certificates
provider "aws" {
  version = "~>2.0"
  region  = "us-east-1"
  alias   = "site_account_us-east-1"
  assume_role {
    role_arn = "${var.site_account_role_arn}"
  }
}

# Site account for all other resources
provider "aws" {
  version = "~>2.0"
  region  = "${var.region}"
  alias   = "site_account"
  assume_role {
    role_arn = "${var.site_account_role_arn}"
  }
}

terraform {
  backend "s3" {}
  required_version = ">=0.12.0"
}

data "aws_caller_identity" "current" {}