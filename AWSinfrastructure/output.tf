output "website_url" {
  description = "The URL of the S3 website"
  value       = "http://${aws_s3_bucket.www_bucket.bucket}.s3-website-${var.region}.amazonaws.com"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.www_s3_distribution.id
}


# AWS CLI commands
# aws s3 website s3://portfolio-page-bucket-danielwrede/ --index-document index.html
# aws s3 cp /Users/danielwrede/Documents/AWS_CloudDev/capstone_project/homepage_content/mark/ s3://portfolio-page-bucket-danielwrede/ --recursive --acl public-read
# remove all files from bucket
# aws s3 rm s3://portfolio-page-bucket-danielwrede/ --recursive