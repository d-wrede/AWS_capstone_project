######################
# s3 bucket for logs #
######################
resource "aws_s3_bucket" "log_bucket" {
  bucket        = var.log_bucket_name
  tags          = var.common_tags
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.log_bucket]

  bucket = aws_s3_bucket.log_bucket.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

#######################
# s3 bucket for email #
#######################

resource "aws_s3_bucket" "email_bucket" {
  provider      = aws.ses_provider
  bucket        = var.email_bucket_name
  tags          = var.common_tags
  force_destroy = true
}

resource "aws_s3_bucket_policy" "s3_forward_policy" {
  bucket = aws_s3_bucket.email_bucket.id
  provider = aws.ses_provider

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSESPuts"
        Effect    = "Allow"
        Principal = { "Service" : "ses.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.email_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:Referer" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid       = "AllowLambdaGetObject"
        Effect    = "Allow"
        Principal = { "AWS" : aws_iam_role.lambda_forward_role.arn }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.email_bucket.arn}/*"
      }
    ]
  })
}

#############################
# s3 bucket for lambda chat #
#############################

resource "aws_s3_bucket" "chat_bucket" {
  bucket        = var.chat_bucket_name
  tags          = var.common_tags
  #force_destroy = true
}