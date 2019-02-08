variable "site-name" {} # the FQDN of the website

variable "hosted-zone-name" {} # hosted zone for the website

variable "project" {} # tag for project name

variable "environment" {} # tag for the environment

variable "region" {
  default = "us-east-2"
}
