resource "aws_lambda_function" "chatgpt_lambda" {
  function_name = "ChatGPTFunction"
  handler       = "your_lambda_handler"
  runtime       = "python3.8"

  role = aws_iam_role.lambda_exec_role.arn

  filename = "path_to_your_lambda_package.zip"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

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
