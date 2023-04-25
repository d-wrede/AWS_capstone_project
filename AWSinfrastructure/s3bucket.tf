resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website_bucket,
    aws_s3_bucket_public_access_block.website_bucket,
  ]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
}

resource "null_resource" "upload_content" {
  triggers = {
    # Change the value of this variable when you want to force re-upload
    force_upload = "some-value"
  }

  provisioner "local-exec" {
    command = "aws s3 cp /Users/danielwrede/Documents/AWS_CloudDev/capstone_project/homepage_content/mark/ s3://${aws_s3_bucket.website_bucket.id}/ --recursive --acl public-read"
  }
}

