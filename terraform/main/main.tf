terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.53.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

module "terraform_lovers_unite" {
    source = "../modules"

    name_prefix = "prod-ci"
}