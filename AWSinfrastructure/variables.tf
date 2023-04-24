variable "region" {
  description = "The AWS region to use"
  default     = "us-west-2"
}

####################
# S3 variables
####################

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
  default     = "portfolio-bucket-danielwrede456"
}


