variable "site_fqdn" {} # the FQDN of the website

variable "hosted_zone_name" {} # hosted zone for the website

variable "project" {} # tag for project name

variable "environment" {} # tag for the environment

variable "region" {
  default = "us-west-2"
}

variable "short_site_fqdn" {}


variable "site_account_role_arn" {}

variable "ci_user_arn" {}