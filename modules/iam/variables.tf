variable "role_name" {
  type        = string
  description = "IAM role name"
}

variable "assume_role_service" {
  type        = string
  description = "AWS service principal that can assume this role (e.g., lambda.amazonaws.com)"
}

variable "policy_name" {
  type        = string
  description = "IAM policy name"
}

variable "policy_json" {
  type        = string
  description = "IAM policy document in JSON"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to IAM resources"
}
