variable "api_name" {
  type        = string
  description = "Name of the HTTP API"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "Lambda function invoke ARN for the default integration"
}

variable "stage_name" {
  type        = string
  description = "Deployment stage name"
  default     = "$default"
}

variable "tags" {
  type    = map(string)
  default = {}
}
