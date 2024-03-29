#############################################
#  chat API Gateway and Lambda Integration  #
#############################################

# Lambda function for chat
resource "aws_lambda_function" "chat" {
  function_name = var.chat_function_name
  handler       = "lambda_chat.lambda_handler"
  role          = aws_iam_role.chat_lambda_role.arn
  runtime       = "python3.10"

  filename = "lambda_functions/lambda_chat.zip"
  layers   = [aws_lambda_layer_version.openai_layer.arn]

  timeout = 30
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
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chat.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.portfo_gw.id}/*/*"

  depends_on = [aws_lambda_function.chat]
}

# resource "aws_lambda_permission" "secrets_manager_access" {
#   statement_id  = "AllowLambdaToAccessSecretsManager"
#   action       = "lambda:GetSecretValue"
#   function_name = aws_lambda_function.chat.arn
#   principal    = "secretsmanager.amazonaws.com"

#   source_arn = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:chatGPT_key"

#   depends_on = [ aws_lambda_function.chat ]
# }

# Lambda layer for chat
resource "aws_lambda_layer_version" "openai_layer" {
  filename         = var.layer_filename
  layer_name       = "openai-layer"
  source_code_hash = filebase64sha256("${var.layer_filename}")
  # compatible_runtimes = [
  #   "python3.8",
  # ]
  # skip_destroy = true
}
