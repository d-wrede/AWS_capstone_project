##############################################
# IAM policy for Lambda to access S3 and SES #
##############################################


data "aws_iam_policy_document" "lambda_email_permissions" {
  statement {
    sid       = "VisualEditor0"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:CreateLogGroup", "logs:PutLogEvents"]
    resources = ["*"]
  }

  statement {
    sid     = "VisualEditor1"
    effect  = "Allow"
    actions = ["s3:GetObject", "ses:SendRawEmail"]
    resources = [
      "${aws_s3_bucket.email_bucket.arn}/*",
      "arn:aws:ses:${var.region}:${data.aws_caller_identity.current.account_id}:identity/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_email_policy" {
  name        = "LambdaEmailPolicy"
  description = "Policy to allow Lambda to access S3 and SES for sending emails."
  policy      = data.aws_iam_policy_document.lambda_email_permissions.json
}

resource "aws_iam_role" "lambda_email_role" {
  name          = "LambdaEmailRole"
  provider      = aws.ses_provider

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_email_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_email_policy.arn
  role       = aws_iam_role.lambda_email_role.name
}
