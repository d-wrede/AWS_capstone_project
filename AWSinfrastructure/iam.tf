##############################################
# IAM policy for Lambda to access S3 and SES #
##############################################


data "aws_iam_policy_document" "lambda_log_permissions" {
  statement {
    sid       = "VisualEditor0"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:CreateLogGroup", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "lambda_s3_permissions" {
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

data "aws_iam_policy_document" "lambda_ses_permissions" {
  statement {
    sid     = "VisualEditor2"
    effect  = "Allow"
    actions = ["ses:SendRawEmail"]
    resources = [
      "arn:aws:ses:${var.region}:${data.aws_caller_identity.current.account_id}:identity/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_log_policy" {
  name        = "LambdaLogsPolicy"
  description = "Policy to allow Lambda to create CloudWatch logs."
  policy      = data.aws_iam_policy_document.lambda_log_permissions.json
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "LambdaS3Policy"
  description = "Policy to allow Lambda to access S3 for reading objects."
  policy      = data.aws_iam_policy_document.lambda_s3_permissions.json
}

resource "aws_iam_policy" "lambda_ses_policy" {
  name        = "LambdaSESPolicy"
  description = "Policy to allow Lambda to access SES for sending emails."
  policy      = data.aws_iam_policy_document.lambda_ses_permissions.json
}

resource "aws_iam_role" "lambda_forward_role" {
  name     = "LambdaForwardRole"
  provider = aws.ses_provider

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

resource "aws_iam_role_policy_attachment" "lambda_forward_log_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_log_policy.arn
  role       = aws_iam_role.lambda_forward_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_forward_s3_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
  role       = aws_iam_role.lambda_forward_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_forward_ses_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
  role       = aws_iam_role.lambda_forward_role.name
}



##########################################
#  contact form Lambda mail permission   #
##########################################


resource "aws_iam_role" "lambda_contact_role" {
  name     = "LambdaContactRole"
  #provider = aws.ses_provider

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

resource "aws_iam_role_policy_attachment" "lambda_contact_log_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_log_policy.arn
  role       = aws_iam_role.lambda_contact_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_contact_ses_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
  role       = aws_iam_role.lambda_contact_role.name
}

############################################
# chat Lambda Integration  #
############################################

# IAM role for the Lambda function
resource "aws_iam_role" "chat_lambda_role" {
  name = "chat_lambda_role"

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

# IAM policy to enable Lambda function to write logs
resource "aws_iam_role_policy" "chat_lambda_logs_policy" {
  name = "chat_lambda_logs_policy"
  # description = "Allow Lambda function to write logs to CloudWatch"
  role = aws_iam_role.chat_lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# IAM policy to enable Lambda function to get secrets from Secrets Manager
resource "aws_iam_role_policy" "secrets_manager_access" {
  name = "secrets_manager_access"
  role = aws_iam_role.chat_lambda_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : "arn:aws:secretsmanager:eu-central-1:792277894863:secret:chatGPT_key-LUoLnu"
      }
    ]
  })
}

# IAM policy to enable Lambda function to access S3
resource "aws_iam_role_policy" "s3_chat_access" {
  name = "s3_chat_access"
  role = aws_iam_role.chat_lambda_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource" : "${aws_s3_bucket.chat_bucket.arn}/*"
      }
    ]
  })
}


#################################
#  API Gateway CloudWatch Logs  #
#################################

resource "aws_iam_role" "api_gateway_cloudwatch_logs" {
  name = "api_gateway_cloudwatch_logs_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy" "api_gateway_cloudwatch_logs_policy" {
  name = "api_gateway_cloudwatch_logs_policy"
  role = aws_iam_role.api_gateway_cloudwatch_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
