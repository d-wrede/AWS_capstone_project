terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

provider "aws" {
  # Europe (Ireland)
  alias  = "ses_provider"
  region = "eu-west-1"
}


resource "aws_cloudfront_origin_access_identity" "example" {
  comment = "OAI for accessing S3 bucket content"
}