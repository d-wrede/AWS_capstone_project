variable "region" {
  description = "The AWS region to use"
  default     = "eu-central-1"
}

####################
# S3 variables
####################

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
  default     = "portfolio-page-bucket-danielwrede"
}


