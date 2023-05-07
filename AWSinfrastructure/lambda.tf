######################################
#  Email Forwarding Lambda Function  #
######################################

resource "aws_lambda_function" "email_forwarder" {
  provider      = aws.ses_provider
  function_name = "EmailForwarder"
  handler       = "email_forwarder.lambda_handler"
  runtime       = "python3.7"

  role = aws_iam_role.lambda_email_role.arn

  # Replace the file path with the actual path to your Lambda function code
  filename = "lambda_functions/email_forwarder.zip"

  environment {
    variables = {
      MailS3Bucket  = aws_s3_bucket.email_bucket.bucket
      MailS3Prefix  = "emails"
      MailSender    = "projects@daniel-wrede.de"
      MailRecipient = "daniel.wrede@posteo.de"
      Region        = var.region
    }
  }

  timeout = 30
}


# Lambda function
resource "aws_lambda_function" "chatbot_lambda" {
  function_name = "chatbot-lambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  role = aws_iam_role.lambda_exec.arn

  filename = "lambda_chat.zip" # Make sure to create this .zip file from your lambda_chat.py
}

# Lambda execution role
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec"

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


#############################################
#  chat API Gateway and Lambda Integration  #
#############################################

# Lambda function for chat
resource "aws_lambda_function" "chat" {
  function_name = "chat_function"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.chat_lambda_role.arn
  runtime       = "python3.8"

  filename = "lambda_function.zip"
}

# CloudWatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "chat_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.chat.function_name}"
  retention_in_days = 14
}


# Lambda permission to allow CloudWatch
resource "aws_lambda_permission" "allow_cloudwatch_chat" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chat.function_name
  principal     = "events.amazonaws.com"
}

# Lambda permission to allow API Gateway
resource "aws_lambda_permission" "apigw_chat" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chat.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.chat_api.id}/*/*"
}

