# FQDN of the website
variable "site_fqdn" {}

# Route53 hosted zone for the website fqdn
variable "hosted_zone_name" {}

# Value for the tag key Project
variable "project" {}

# Value for tag key Environment
variable "environment" {}

# Region where site resources should be created
variable "region" {
  default = "us-west-2"
}

# Role to assume in the site account
variable "site_account_role_arn" {}

# ARN for CI user
variable "ci_user_arn" {}

variable "master_account_number" {}

variable "site_account_number" {}