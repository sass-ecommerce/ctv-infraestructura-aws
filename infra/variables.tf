variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "app_name" {
  type        = string
  description = "Application name used as prefix for resource names"
  default     = "ctv"
}

variable "project" {
  type        = string
  description = "Short project identifier"
}

variable "project_name" {
  type        = string
  description = "Full project name"
}
