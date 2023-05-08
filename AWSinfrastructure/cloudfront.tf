# Cloudfront distribution for main s3 site.
resource "aws_cloudfront_distribution" "www_s3_distribution" {
  origin {
    # for s3 website hosting it is important to use the website_endpoint of
    # the website_configuration instead of the bucket itself.
    domain_name = aws_s3_bucket.www_bucket.bucket_regional_domain_name
    # aws_s3_bucket.www_bucket.bucket_regional_domain_name
    # aws_s3_bucket_website_configuration.www_bucket.website_endpoint
    origin_id   = "S3-www.${var.bucket_name}"

    # The custom_origin_config block is not required, when using the s3_origin_config
    # with the origin_access_identity to allow access to the s3 bucket.
    # custom_origin_config {
    #   http_port              = 80
    #   https_port             = 443
    #   origin_protocol_policy = "http-only"
    #   origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    # }
    
    # used for s3 bucket access via origin_access_identity (then comment custom_origin_config block)
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.example.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["www.${var.domain_name}"]

#   custom_error_response {
#     error_caching_min_ttl = 0
#     error_code            = 404
#     response_code         = 200
#     response_page_path    = "/404.html"
#   }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-www.${var.bucket_name}"

    forwarded_values {
      query_string = false
      headers = ["Origin", "X-CloudFront-Access"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 31536000
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.ssl_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  # Logging configuration
  logging_config {
    bucket          = "${aws_s3_bucket.log_bucket.bucket_domain_name}"
    prefix          = "cloudfront_www_logs/"
    include_cookies = false
  }

  tags = var.common_tags
}

resource "aws_cloudfront_origin_access_identity" "example" {
  comment = "OAI for accessing S3 bucket content"
}


# Cloudfront S3 for redirect to www.
resource "aws_cloudfront_distribution" "redirect_s3_distribution" {
  origin {
    # for s3 website hosting it is important to use the website_endpoint of
    # the website_configuration instead of the bucket itself.
    domain_name = aws_s3_bucket_website_configuration.redirect_bucket.website_endpoint
    origin_id   = "S3-${var.bucket_name}"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 Bucket Redirect Distribution"
  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    

    forwarded_values {
      query_string = false
      headers = ["Origin", "X-CloudFront-Access"]
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  viewer_certificate {
    acm_certificate_arn      = var.ssl_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  # Logging configuration
  logging_config {
    bucket          = "${aws_s3_bucket.log_bucket.bucket_domain_name}"
    prefix          = "cloudfront_redirect_logs/"
    include_cookies = false
  }

  tags = var.common_tags
}

