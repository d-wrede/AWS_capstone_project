########################
# chat bot API Gateway #
########################

# API Gateway REST API for the chat Lambda function
resource "aws_api_gateway_rest_api" "chat_api" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "ChatAPI"
      version = "1.0"
    }
    paths = {
      "/message" = {
        post = {
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.chat.arn}/invocations"
          }
          responses = {
            "200" = {
              description = "200 response"
            }
          }
        }
      }
    }
  })

  name = "ChatAPI"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway deployment for the chat Lambda function
resource "aws_api_gateway_deployment" "chat_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.chat_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.chat_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage for the chat Lambda function
resource "aws_api_gateway_stage" "chat_api_stage" {
  deployment_id = aws_api_gateway_deployment.chat_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.chat_api.id
  stage_name    = "chat_api_stage"
}
