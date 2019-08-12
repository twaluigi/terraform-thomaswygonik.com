# Terraform tomwygonik.com

[![pipeline status](https://gitlab.com/twaluigi/terraform-tomwygonik-website/badges/master/pipeline.svg)](https://gitlab.com/twaluigi/terraform-tomwygonik-website/commits/master)

Terraform infrastructure for a S3 static site, fronted by CloudFront, with HTTPS using ACM. Using [Terragrunt](https://github.com/gruntwork-io/terragrunt) to avoid defining state in code, and to keep code DRY.

## Multi-Account

This is designed to be used in a multi-account structure, with the Terraform state and Route53 records existing in the Master account. All other resources for the static site exist in the Site account.

## Modules

Currently, there is only one module, **static_site**

## Variables

Variables are defined in the variables.tf file, these should be given values in terraform.tfvars or using environment variables.
