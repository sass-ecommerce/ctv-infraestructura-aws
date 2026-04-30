variable "environment" {
  type        = string
  description = "Deployment environment — used as path prefix (e.g., dev, prod)"
}

variable "app_name" {
  type        = string
  description = "Application name — used as path prefix (e.g., ctv)"
}

variable "secrets" {
  type        = map(string)
  description = "Map of secret key → initial value for Secrets Manager. Path: /<env>/<app>/<key>"
  default     = {}
  sensitive   = true
}

variable "parameters" {
  type        = map(string)
  description = "Map of parameter key → value for SSM Parameter Store (SecureString). Path: /<env>/<app>/<key>"
  default     = {}
  sensitive   = true
}

variable "string_parameters" {
  type        = map(string)
  description = "Map of parameter key → value for SSM Parameter Store (String). Path: /<env>/<app>/<key>"
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
