############################################
# API GATEWAY - Sets up & configure api gw
############################################

# URL to example roger welin:
# https://rogerwelin.github.io/aws/serverless/terraform/lambda/2019/03/18/build-a-serverless-website-from-scratch-with-lambda-and-terraform.html
# ids and method are by roger welin defined via "${}" syntax.

# according to example roger welin
# only regional endpoint configuration added
resource "aws_api_gateway_rest_api" "chat_api" {
  name        = "ChatAPI"
  description = "API for chat application"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# according to example roger welin
resource "aws_api_gateway_resource" "message_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_api.id
  parent_id   = aws_api_gateway_rest_api.chat_api.root_resource_id
  path_part   = var.gw_resource_path_part
}

# not defined in example roger welin
resource "aws_api_gateway_method" "post_message" {
  rest_api_id   = aws_api_gateway_rest_api.chat_api.id
  resource_id   = aws_api_gateway_resource.message_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# not defined in example roger welin
resource "aws_api_gateway_integration" "post_message" {
  rest_api_id = aws_api_gateway_rest_api.chat_api.id
  resource_id = aws_api_gateway_resource.message_resource.id
  http_method = aws_api_gateway_method.post_message.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.chat.arn}/invocations"
}


resource "aws_api_gateway_deployment" "chat_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.chat_api.id
  stage_name  = var.stage_name

  # access_log_settings {
  #   destination_arn = aws_cloudwatch_log_group.chat_log_group.arn
  #   format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  # }

  # redeploy when any of the following resources are changed
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.chat_api.id,
      aws_api_gateway_resource.message_resource.id,
      aws_api_gateway_method.post_message.id,
      aws_api_gateway_integration.post_message.id,
      #aws_api_gateway_method.options_message.id,
      #aws_api_gateway_integration.options_message.id,
    ]))
  }

  # depends_on = [aws_cloudwatch_log_group.chat_log_group]
}

########
# enable logging
#######
resource "aws_api_gateway_account" "chat_api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_logs.arn
}
# resource "aws_cloudwatch_log_group" "chat_log_group" {
#   name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.chat_api.id}/${var.stage_name}"
#   retention_in_days = 7
# }

#######
# for preflight CORS requests
#######

# according to example roger welin
# resource "aws_api_gateway_method" "options_message" {
#   rest_api_id   = aws_api_gateway_rest_api.chat_api.id
#   resource_id   = aws_api_gateway_resource.message_resource.id
#   http_method   = "OPTIONS"
#   authorization = "NONE"
# }

# comparable to example roger welin
# resource "aws_api_gateway_integration" "options_message" {
#   rest_api_id = aws_api_gateway_rest_api.chat_api.id
#   resource_id = aws_api_gateway_resource.message_resource.id
#   http_method = aws_api_gateway_method.options_message.http_method

#   # defining 'options' method may not be necessary
#   integration_http_method = "OPTIONS"
#   type                    = "MOCK"
#   request_templates = {
#     "application/json" = jsonencode({ "statusCode" : 200 })
#   }
#   # syntax used in example roger welin:
#   # request_templates {"application/json" = "{ \"statusCode\": 200 }"}
# }

# comparable to example roger welin
# resource "aws_api_gateway_method_response" "options_200_response" {
#   rest_api_id = aws_api_gateway_rest_api.chat_api.id
#   resource_id = aws_api_gateway_resource.message_resource.id
#   http_method = aws_api_gateway_method.options_message.http_method
#   status_code = "200"

#   response_models = {
#     "application/json" = "Empty"
#   }

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = true
#     "method.response.header.Access-Control-Allow-Methods" = true
#     "method.response.header.Access-Control-Allow-Origin"  = true
#   }

#   #depends_on = aws_api_gateway_method.options_message
# }

# comparable to example roger welin
# resource "aws_api_gateway_integration_response" "options_200_response" {
#   rest_api_id = aws_api_gateway_rest_api.chat_api.id
#   resource_id = aws_api_gateway_resource.message_resource.id
#   http_method = aws_api_gateway_method.options_message.http_method
#   status_code = aws_api_gateway_method_response.options_200_response.status_code

#   # not defined in example roger welin
#   response_templates = {
#     "application/json" = ""
#   }

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
#     "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
#     "method.response.header.Access-Control-Allow-Origin"  = "'*'"
#   }

#   #depends_on = [ aws_api_gateway_method_response.options_200_response ]
# }

# # not defined in example roger welin
# resource "aws_api_gateway_method_response" "post_200_response" {
#   rest_api_id = aws_api_gateway_rest_api.chat_api.id
#   resource_id = aws_api_gateway_resource.message_resource.id
#   http_method = aws_api_gateway_method.post_message.http_method
#   status_code = "200"

#   response_models = {
#     "application/json" = "Empty"
#   }
#   # in example roger welin, only Access-Control-Allow-Origin is defined
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = true
#     "method.response.header.Access-Control-Allow-Methods" = true
#     "method.response.header.Access-Control-Allow-Origin"  = true
#   }
# }

# # not defined in example roger welin
# resource "aws_api_gateway_integration_response" "post_200_response" {
#   rest_api_id = aws_api_gateway_rest_api.chat_api.id
#   resource_id = aws_api_gateway_resource.message_resource.id
#   http_method = aws_api_gateway_method.post_message.http_method
#   status_code = aws_api_gateway_method_response.post_200_response.status_code

#   response_templates = {
#     "application/json" = ""
#   }

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
#     "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
#     "method.response.header.Access-Control-Allow-Origin"  = "'*'"
#   }
# }