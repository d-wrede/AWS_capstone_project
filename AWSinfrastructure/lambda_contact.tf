#############################################
#  Contact Form Forwarding Lambda Function  #
#############################################

resource "aws_lambda_function" "contact_forwarder" {
  function_name = "ContactForwarder"
  handler       = "contact_forwarder.lambda_handler"
  runtime       = "python3.10"

  role = aws_iam_role.lambda_contact_role.arn

  # Replace the file path with the actual path to your Lambda function code
  filename = "lambda_functions/contact_forwarder.zip"

  timeout = 30
}

# CloudWatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "contact_forwarder_logs" {
  name              = "/aws/lambda/${aws_lambda_function.contact_forwarder.function_name}"
  retention_in_days = 14
}

# Lambda permission to allow CloudWatch
# resource "aws_lambda_permission" "allow_cloudwatch_contact_forwarder" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.contact_forwarder.function_name
#   principal     = "events.amazonaws.com"
# }

# Lambda permission to allow API Gateway
resource "aws_lambda_permission" "apigw_contact_forwarder" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_forwarder.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.portfo_gw.id}/*/*"

  depends_on = [aws_lambda_function.contact_forwarder]
}