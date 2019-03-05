provider "aws" {
  region  = "${var.region}"
  version = "~>2.0"
}

# custom provider for Cloudfront ACM certificate - must be in us-east-1
provider "aws" {
  region  = "us-east-1"
  alias   = "us-east-1"
  version = "~>2.0"
}
