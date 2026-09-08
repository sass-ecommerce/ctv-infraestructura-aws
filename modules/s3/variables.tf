variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, prod)"
}

variable "enable_versioning" {
  type        = bool
  default     = true
  description = "Whether to enable versioning on the bucket"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to the bucket"
}
