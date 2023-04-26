variable "region" {
  description = "The AWS region to use"
  default     = "eu-central-1"
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
