
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = "portfolio_bucket_DanielWrede"
}

resource "aws_acm_certificate" "portfolio_cert" {
  domain_name       = "example.com"
  validation_method = "DNS"
}

# resource "aws_cloudfront_distribution" "portfolio_distribution" {
#   # ... (configuration for CloudFront distribution)
# }

