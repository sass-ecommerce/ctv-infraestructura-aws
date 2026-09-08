variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime (e.g., nodejs20.x, python3.12)"
  default     = "nodejs20.x"
}

variable "handler" {
  type        = string
  description = "Lambda handler entrypoint (e.g., index.handler)"
  default     = "index.handler"
}

variable "filename" {
  type        = string
  description = "Local path to the deployment ZIP file"
  default     = null
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket containing the deployment package"
  default     = null
}

variable "s3_key" {
  type        = string
  description = "S3 key of the deployment package"
  default     = null
}

variable "source_code_hash" {
  type        = string
  description = "Base64-encoded SHA256 hash of the deployment package (triggers updates)"
  default     = null
}

variable "role_arn" {
  type        = string
  description = "ARN of the IAM execution role for Lambda"
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MB allocated to the Lambda function"
  default     = 128
}

variable "timeout" {
  type        = number
  description = "Maximum execution time in seconds"
  default     = 30
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables to inject into the Lambda function"
  default     = {}
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs"
  default     = 14
}

variable "api_gateway_execution_arn" {
  type        = string
  description = "API Gateway execution ARN to grant invoke permission (optional)"
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
