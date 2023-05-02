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

#   s3_use_path_style = true
#   ignore_tags {
#     key_prefixes = ["aws:"]
#   }
#   # skip_get_ec2_platforms      = true
#   skip_metadata_api_check      = true
#   skip_region_validation       = true
#   skip_credentials_validation  = true
#   skip_requesting_account_id   = true
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}
# resource "aws_acm_certificate" "portfolio_cert" {
#   domain_name       = "example.com"
#   validation_method = "DNS"
# }

# resource "aws_cloudfront_distribution" "portfolio_distribution" {
#   # ... (configuration for CloudFront distribution)
# }

