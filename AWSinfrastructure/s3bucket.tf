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
  # use the following policy, to enable access via custom header
  # and in the cloudfront distribution as domain name:
  # aws_s3_bucket_website_configuration.www_bucket.website_endpoint
  # policy = jsonencode({
  #   Version = "2012-10-17"
  #   Statement = [
  #     {
  #       Action   = "s3:GetObject"
  #       Effect   = "Allow"
  #       Resource = "${aws_s3_bucket.www_bucket.arn}/*"
  #       Principal = "*"
  #       Condition = {
  #         StringEquals = {
  #           "aws:Referer" = "X-CloudFront-Access"
  #         }
  #       }
  #     }
  #   ]
  # })

  # use this policy, to enable access via origin_access_identity
  # but using the bucket_regional_domain_name in the cloudfront distribution
  # aws_s3_bucket.www_bucket.bucket_regional_domain_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.www_bucket.arn}/*"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.example.iam_arn
        }
      }
    ]
  })

  # avoid "Error putting S3 policy: AccessDenied: Access Denied"
  depends_on = [
    aws_s3_bucket.redirect_bucket,
    aws_s3_bucket_website_configuration.redirect_bucket,
    aws_s3_bucket_ownership_controls.redirect_bucket,
    aws_s3_bucket_public_access_block.redirect_bucket
  ]
}

resource "aws_s3_bucket_ownership_controls" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "null_resource" "upload_content" {
  triggers = {
    # Change the value of this variable when you want to force re-upload
    force_upload = "some-value"
  }

  depends_on = [aws_s3_bucket.www_bucket]

  provisioner "local-exec" {
    # aws sts get-caller-identity; aws s3api get-bucket-acl --bucket ${aws_s3_bucket.www_bucket.id};
    command = "aws s3 cp /Users/danielwrede/Documents/AWS_CloudDev/portfolio_website/ s3://${aws_s3_bucket.www_bucket.id}/ --no-progress --recursive"
  }
}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.www_bucket.id

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