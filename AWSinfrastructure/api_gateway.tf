########################
# chat bot API Gateway #
########################

# API Gateway REST API for the chat Lambda function
resource "aws_api_gateway_rest_api" "chat_api" {
  name              = "ChatAPI"
  put_rest_api_mode = "merge"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

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
              }
            }
          }
          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "AWS_PROXY"
            uri                  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.chat.arn}/invocations"
            responses = {
              "200" = {
                statusCode = "200"
                responseParameters = {
                  "method.response.header.Access-Control-Allow-Headers" = true
                  "method.response.header.Access-Control-Allow-Methods" = true
                  "method.response.header.Access-Control-Allow-Origin"  = true
                }
              }
            }
          }

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
              "application/json" = jsonencode({ "statusCode" : 200 })
            }
            responses = {
              "default" = {
                statusCode = "200"
                responseParameters = {
                  "method.response.header.Access-Control-Allow-Headers" = true
                  "method.response.header.Access-Control-Allow-Methods" = true
                  "method.response.header.Access-Control-Allow-Origin"  = true
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
}


# resource "aws_api_gateway_resource" "message" {
#   rest_api_id = aws_api_gateway_rest_api.chat_api.id
#   parent_id   = aws_api_gateway_rest_api.chat_api.root_resource_id
#   path_part   = "message"
# }

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



# only needed for not-rest-API Gateways
# enable logging for 'Full Request and Response Logs'
# resource "aws_api_gateway_method" "message_post" {
#   rest_api_id   = aws_api_gateway_rest_api.chat_api.id
#   resource_id   = aws_api_gateway_resource.message.id
#   http_method   = "POST"
#   authorization = "NONE"
#   api_key_required = true
# }

# resource "aws_api_gateway_method_settings" "example" {
#   rest_api_id = aws_api_gateway_rest_api.chat_api.id
#   stage_name  = aws_api_gateway_stage.chat_api_stage.stage_name
#   method_path = "*/*"

#   settings {
#     logging_level  = "INFO"
#     metrics_enabled = true
#     throttling_burst_limit = 5
#     throttling_rate_limit = 10
#   }
# }


resource "aws_api_gateway_account" "chat_api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_logs.arn
}


resource "aws_cloudwatch_log_group" "chat_log_group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.chat_api.id}/${var.stage_name}"
  retention_in_days = 7
}

