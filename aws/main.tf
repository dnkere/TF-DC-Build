terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = ">=2.55.0"
  }
  experiments = [variable_validation]
}

provider "aws" {
  region      = var.region
  access_key  = var.access_key
  secret_key  = var.secret_key
}

data "aws_caller_identity" "current" {}