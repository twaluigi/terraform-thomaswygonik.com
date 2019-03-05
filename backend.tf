terraform {
  backend "s3" {
    bucket = "tomwygonik-tfstate"

    # Can't set anything in here as a variable, backend needs to be initialized before variables
    key            = "terraform/thomaswygonik.com/terraform-thomaswygonik-site.tfstate"
    region         = "us-east-2"
    dynamodb_table = "tomwygonik-tfstate-lock"
    encrypt        = true
  }
}
