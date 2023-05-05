# S3 bucket for redirecting non-www to www.
resource "aws_s3_bucket" "redirect_bucket" {
  bucket = var.bucket_name
  force_destroy = true
  tags = var.common_tags
}

resource "aws_s3_bucket_website_configuration" "redirect_bucket" {
  bucket = aws_s3_bucket.redirect_bucket.id
  redirect_all_requests_to {
    host_name = "www.${var.domain_name}"
    protocol  = "https"
  }
}

resource "aws_s3_bucket_policy" "give_read_access_to_redirect_bucket" {
  bucket = aws_s3_bucket.redirect_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.redirect_bucket.arn}/*"
        Principal = "*"
        Condition = {
          StringEquals = {
            "aws:Referer" = "X-CloudFront-Access"
          }
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

resource "aws_s3_bucket_ownership_controls" "redirect_bucket" {
  bucket = aws_s3_bucket.redirect_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "redirect_bucket" {
  bucket = aws_s3_bucket.redirect_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



# resource "aws_s3_bucket_acl" "redirect_bucket" {
#   depends_on = [
#     aws_s3_bucket_ownership_controls.redirect_bucket,
#     aws_s3_bucket_public_access_block.redirect_bucket,
#   ]

#   bucket = aws_s3_bucket.redirect_bucket.id
#   acl    = "public-read"
# }