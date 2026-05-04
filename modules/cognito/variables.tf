variable "name" {
  type        = string
  description = "User pool name"
}

variable "password_min_length" {
  type        = number
  description = "Minimum password length"
  default     = 8
}

variable "app_client_name" {
  type        = string
  description = "App client name"
}

variable "pre_token_generation_lambda_arn" {
  type        = string
  description = "ARN of the Lambda function for pre token generation trigger"
  default     = null
}

variable "post_confirmation_lambda_arn" {
  type        = string
  description = "ARN of the Lambda function for post confirmation trigger"
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
