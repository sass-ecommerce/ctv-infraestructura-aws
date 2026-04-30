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

variable "tags" {
  type    = map(string)
  default = {}
}
