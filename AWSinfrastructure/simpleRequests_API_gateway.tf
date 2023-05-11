############################################
# API GATEWAY - Sets up & configure api gw
############################################

resource "aws_api_gateway_rest_api" "portfo_gw" {
  name        = "portfolio_gateway"
  description = "API REST Gateway for portfolio page"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#######################
#   chat messaging    #
#######################

resource "aws_api_gateway_resource" "message_resource" {
  rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
  parent_id   = aws_api_gateway_rest_api.portfo_gw.root_resource_id
  path_part   = var.gw_resource_path_part
}

resource "aws_api_gateway_method" "post_message" {
  rest_api_id   = aws_api_gateway_rest_api.portfo_gw.id
  resource_id   = aws_api_gateway_resource.message_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_message" {
  rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
  resource_id = aws_api_gateway_resource.message_resource.id
  http_method = aws_api_gateway_method.post_message.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.chat.arn}/invocations"
}


resource "aws_api_gateway_deployment" "chat_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
  stage_name  = var.stage_name

  # redeploy when any of the following resources are changed
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.portfo_gw.id,
      aws_api_gateway_resource.message_resource.id,
      aws_api_gateway_method.post_message.id,
      aws_api_gateway_integration.post_message.id,
      #aws_api_gateway_method.options_message.id,
      #aws_api_gateway_integration.options_message.id,
    ]))
  }
  # trying this depends_on
  depends_on = [aws_api_gateway_integration.post_message]
}

#############################
#  contact form forwarding  #
#############################

resource "aws_api_gateway_resource" "contact_form_resource" {
  rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
  parent_id   = aws_api_gateway_rest_api.portfo_gw.root_resource_id
  path_part   = var.gw_resource_contact_path_part
}

resource "aws_api_gateway_method" "post_contact_message" {
  rest_api_id   = aws_api_gateway_rest_api.portfo_gw.id
  resource_id   = aws_api_gateway_resource.contact_form_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_contact_message" {
  rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
  resource_id = aws_api_gateway_resource.contact_form_resource.id
  http_method = aws_api_gateway_method.post_contact_message.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.contact_forwarder.arn}/invocations"
}


resource "aws_api_gateway_deployment" "contact_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
  stage_name  = var.stage_name

  # redeploy when any of the following resources are changed
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.portfo_gw.id,
      aws_api_gateway_resource.contact_form_resource.id,
      aws_api_gateway_method.post_contact_message.id,
      aws_api_gateway_integration.post_contact_message.id,
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
#   name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.portfo_gw.id}/${var.stage_name}"
#   retention_in_days = 7
# }

#######
# for preflight CORS requests
#######

# according to example roger welin
# resource "aws_api_gateway_method" "options_message" {
#   rest_api_id   = aws_api_gateway_rest_api.portfo_gw.id
#   resource_id   = aws_api_gateway_resource.message_resource.id
#   http_method   = "OPTIONS"
#   authorization = "NONE"
# }

# comparable to example roger welin
# resource "aws_api_gateway_integration" "options_message" {
#   rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
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
#   rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
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
#   rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
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
#   rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
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
#   rest_api_id = aws_api_gateway_rest_api.portfo_gw.id
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
