variable "region" {
  description = "The AWS region to use"
  default     = "eu-central-1"
}

variable "ses_region" {
  description = "The AWS region to use for SES"
  default     = "eu-west-1"
}



####################
# S3 variables
####################

variable "domain_name" {
  type        = string
  description = "The domain name for the website."
  default     = "daniel-wrede.de"
}
variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
  default     = "daniel-wrede.de"
}

variable "log_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for logs."
  default     = "logbucket-daniel-wrede.de"
}

variable "email_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for emails."
  default     = "emails-daniel-wrede.de"
}


variable "common_tags" {
  description = "Common tags you want applied to all components."
  default = {
    "ManagedBy" = "Terraform"
    "Environment" = "Dev"
    "Project" = "Portfolio Website"
    "Owner" = "Daniel Wrede"
  }
}


variable "urls" {
  type        = map(string)
  description = "List of Maps of Strings with Slug-URL key-values"
  default = {
    "home"    = "https://daniel-wrede.de/"
    "console" = "https://www.daniel-wrede.de/"
  }
}

####################
# Route53 variables
####################
variable "hosted_zone_id" {
  description = "value of the hosted zone id"
  default = "Z07599602ZKBWE6AUM2P8"
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate for the CloudFront distribution."
  type        = string
  default = "arn:aws:acm:us-east-1:792277894863:certificate/fa6f889c-1f92-41a8-a849-50587fec57e9"
}


#########################
# API Gateway variables # 
#########################

variable "stage_name" {
  description = "The name of the API Gateway stage"
  default     = "chat_api_stage"
}

variable "gw_resource_path_part" {
  description = "The path part of the API Gateway resource"
  default     = "message"
}

####################
# Lambda variables #
####################

variable "chat_function_name" {
  description = "The name of the Lambda function"
  default     = "chat_function"
}

variable "layer_filename" {
  description = "The filename of the Lambda layer"
  default     = "lambda_layers/python.zip"
}