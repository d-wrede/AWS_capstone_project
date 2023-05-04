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
