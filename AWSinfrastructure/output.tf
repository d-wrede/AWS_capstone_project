output "website_url" {
  description = "The URL of the S3 website"
  value       = "http://${aws_s3_bucket.www_bucket.bucket}.s3-website-${var.region}.amazonaws.com"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.www_s3_distribution.id
}

output "lambda_function_arn" {
  value = aws_lambda_function.email_forwarder.arn
  description = "The ARN of the Lambda function for email forwarding"
}


output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.chat_api.id}.execute-api.${var.region}.amazonaws.com/${var.stage_name}"
}

# output "api_key_value" {
#   value = aws_api_gateway_api_key.example.value
#   sensitive = true
# }

# to get the api_key_value
# terraform output -raw api_key_value


# AWS CLI commands
# aws s3 website s3://portfolio-page-bucket-danielwrede/ --index-document index.html
# aws s3 cp /Users/danielwrede/Documents/AWS_CloudDev/capstone_project/homepage_content/mark/ s3://portfolio-page-bucket-danielwrede/ --recursive --acl public-read
# remove all files from bucket
# aws s3 rm s3://portfolio-page-bucket-danielwrede/ --recursive