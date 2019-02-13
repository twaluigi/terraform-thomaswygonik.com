variable "site-name" {} # the FQDN of the website

variable "hosted-zone-name" {} # hosted zone for the website

variable "project" {} # tag for project name

variable "environment" {} # tag for the environment

variable "region" {
  default = "us-east-2"
}

variable "github-owner" {}

variable "github-repo" {}

variable "github-branch" {}

variable "poll-source-changes" {}

variable "github-oauth-token" {}

variable "short-site-name" {}
