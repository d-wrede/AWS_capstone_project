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

resource "aws_s3_bucket_acl" "redirect_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.redirect_bucket,
    aws_s3_bucket_public_access_block.redirect_bucket,
  ]

  bucket = aws_s3_bucket.redirect_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_ownership_controls" "redirect_bucket" {
  bucket = aws_s3_bucket.redirect_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "redirect_bucket" {
  bucket = aws_s3_bucket.redirect_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "give_read_access_to_redirect_bucket" {
  bucket = aws_s3_bucket.redirect_bucket.id
  policy = templatefile("templates/s3-policy.json", { bucket = var.bucket_name })
  # avoid "Error putting S3 policy: AccessDenied: Access Denied"
  depends_on = [
    aws_s3_bucket.redirect_bucket,
    aws_s3_bucket_website_configuration.redirect_bucket,
    aws_s3_bucket_acl.redirect_bucket,
    aws_s3_bucket_ownership_controls.redirect_bucket,
    aws_s3_bucket_public_access_block.redirect_bucket
  ]
}