remote_state {
    backend = "s3" 
    config = {
        bucket = "${get_env("STATE_BUCKET", "")}"
        key = "${get_env("STATE_KEY", "")}"
        region = "${get_env("AWS_REGION", "us-west-2")}"
        dynamodb_table = "${get_env("STATE_TABLE", "")}"
        encrypt = true
        skip_bucket_accesslogging      = true
    }
}