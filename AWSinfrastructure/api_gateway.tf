########################
# chat bot API Gateway #
########################

# API Gateway REST API for the chat Lambda function
resource "aws_api_gateway_rest_api" "chat_api" {
  name = "ChatAPI"

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
              headers = {
                "Access-Control-Allow-Origin" = {
                  schema = {
                    type = "string"
            }
          }
          security = [
            {api_key = []}
          ]
        }
        options = {
          responses = {
            "200" = {
              description = "200 response"
              headers = {
                "Access-Control-Allow-Headers" = {
                  schema = {
                    type = "string"
                  }
                }
                "Access-Control-Allow-Methods" = {
                  schema = {
                    type = "string"
                  }
                }
                "Access-Control-Allow-Origin" = {
                  schema = {
                    type = "string"
                  }
                }
              }
            }
          }
          x-amazon-apigateway-integration = {
            httpMethod           = "OPTIONS"
            payloadFormatVersion = "1.0"
            type                 = "MOCK"
            passthroughBehavior  = "WHEN_NO_MATCH"
            requestTemplates = {
              "application/json" = '{"statusCode": 200}'
            }
            responses = {
              "default" = {
                statusCode = "200"
                responseParameters = {
                  "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
                  "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
                  "method.response.header.Access-Control-Allow-Origin"  = "'*'"
                }
                responseTemplates = {
                  "application/json" = ""
                }
              }
            }
          }
        }
      }
    }
  })

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
  stage_name    = var.stage_name

  access_log_settings {
  destination_arn = aws_cloudwatch_log_group.chat_log_group.arn
  format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
}


  xray_tracing_enabled = true

  tags = {
    "aws_api_gateway_account" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.api_gateway_cloudwatch_logs.name}"
  }
  
  depends_on = [aws_cloudwatch_log_group.chat_log_group]
}

# enable logging for 'Full Request and Response Logs'
resource "aws_api_gateway_method_settings" "example" {
  rest_api_id = aws_api_gateway_rest_api.chat_api.id
  stage_name  = aws_api_gateway_stage.chat_api_stage.stage_name
  method_path = "*/*"

  settings {
    logging_level  = "INFO"
    metrics_enabled = true
    throttling_burst_limit = 5
    throttling_rate_limit = 10

    api_key_required = true
  }
}


resource "aws_api_gateway_account" "chat_api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_logs.arn
}


resource "aws_cloudwatch_log_group" "chat_log_group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.chat_api.id}/${var.stage_name}"
  retention_in_days = 7
}

# secure API Gateway access with an API key
resource "aws_api_gateway_api_key" "example" {
  name = "example-api-key"
}

resource "aws_api_gateway_usage_plan" "example" {
  name        = "example-usage-plan"
  description = "Example usage plan for the ChatAPI"

  api_stages {
    api_id = aws_api_gateway_rest_api.chat_api.id
    stage  = aws_api_gateway_stage.chat_api_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "example" {
  key_id        = aws_api_gateway_api_key.example.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.example.id
}
