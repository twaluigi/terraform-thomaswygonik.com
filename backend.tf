terraform {
  backend "s3" {
    bucket = "tomwygonik-tfstate"
    key    = "terraform/thomaswygonik.com/terraform-thomaswygonik-site.tfstate"
    region = "us-east-2"
  }
}
