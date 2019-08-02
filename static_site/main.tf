
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
    role_arn = "arn:aws:iam::635034909178:role/dev_terraform_role"
  }
}

# Site account for all other resources
provider "aws" {
  version = "~>2.0"
  region  = "${var.region}"
  alias   = "site_account"
  assume_role {
    role_arn = "arn:aws:iam::635034909178:role/dev_terraform_role"
  }
}

terraform {
  backend "s3" {}
  required_version = ">=0.12.0"
}

data "aws_caller_identity" "current" {}