remote_state {
    backend = "s3" 
    config = {
        bucket = "thomaswygonik-root-state-store"
        key = "tomwygonik.com/terraform.tfstate"
        region = "us-west-2"
        encrypt = true
        dynamodb_table = "terraform-state-lock"
        skip_bucket_accesslogging      = true
    }
}