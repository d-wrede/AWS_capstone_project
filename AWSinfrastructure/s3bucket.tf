# S3 bucket for website.
resource "aws_s3_bucket" "www_bucket" {
  bucket = "www.${var.bucket_name}"
  force_destroy = true
  tags = var.common_tags
}

resource "aws_s3_bucket_website_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "give_read_access_to_www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = templatefile("templates/s3-policy.json", { bucket = "www.${var.bucket_name}" })
}

resource "aws_s3_bucket_ownership_controls" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "www_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.www_bucket,
    aws_s3_bucket_public_access_block.www_bucket,
  ]

  bucket = aws_s3_bucket.www_bucket.id
  acl    = "public-read"
}

resource "null_resource" "upload_content" {
  triggers = {
    # Change the value of this variable when you want to force re-upload
    force_upload = "some-value"
  }

  provisioner "local-exec" {
    command = "aws s3 cp /Users/danielwrede/Documents/AWS_CloudDev/portfolio_website/ s3://${aws_s3_bucket.www_bucket.id}/ --recursive --acl public-read"
  }
}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.www_bucket.id

  # cors_rule {
  #   allowed_headers = ["*"]
  #   allowed_methods = ["PUT", "POST"]
  #   allowed_origins = ["https://www.${var.domain_name}"]
  #   expose_headers  = ["ETag"]
  #   max_age_seconds = 3000
  # }
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${var.domain_name}"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

# module "url_redirects" {
#   source  = "operatehappy/s3-object-url-redirects/aws"
#   version = "1.0.0"

#   bucket = var.www_bucket.id
#   urls = [
#     var.urls,
#     {
#       source = "/"
#       destination = "/index.html"
#     }
#   ]
# }


  # redirects = [
  #   {
  #     source_key = ""
  #     target_url = "https://www.daniel-wrede.de"
  #     http_redirect_code = "301"
  #   }
  # ]

# module "static_website" {
#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-static-website.git"

#   domain_name = "example.com"
#   acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
#   hosted_zone_name = "example.com."
#   index_document = "index.html"
#   error_document = "error.html"
#   enable_logs = true
# }
