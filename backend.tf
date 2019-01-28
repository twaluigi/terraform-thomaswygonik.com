terraform {
  backend "s3" {
    bucket = "tomwygonik-tfstate"
    key    = "terraform/dns/terraform-thomaswygonik-site.tfstate"
    region = "us-east-2"
  }
}
