terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  shared_config_files     = ["~/.aws/config"]
  shared_credentials_file = "~/.aws/credentials"
  region                  = var.AWS_REGION
}