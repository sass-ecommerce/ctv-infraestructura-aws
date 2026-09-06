variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}


variable "project" {
  type        = string
  description = "Short project identifier"
}

variable "project_name" {
  type        = string
  description = "Full project name"
}

variable "google_client_id" {
  type        = string
  description = "OAuth Client ID for the Google Cognito identity provider (from GitHub secret GOOGLE_CLIENT_ID, injected as TF_VAR_google_client_id)"
}

variable "google_client_secret" {
  type        = string
  description = "OAuth Client Secret for the Google Cognito identity provider (from GitHub secret GOOGLE_SECRET_CLIENT, injected as TF_VAR_google_client_secret)"
  sensitive   = true
}
