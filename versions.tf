terraform {
  # >= 1.11: lock nativo do S3 (`use_lockfile`), que dispensa DynamoDB.
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Config parcial: o bucket depende da conta do lab.
  backend "s3" {}
}
