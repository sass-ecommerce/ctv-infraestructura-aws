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

variable "oauth_callback_urls" {
  type        = list(string)
  description = "Allowed OAuth callback URLs for the Hosted UI (e.g. federated Google sign-in). Leave empty to keep OAuth/Hosted UI disabled for the app client."
  default     = []
}

variable "oauth_identity_providers" {
  type        = list(string)
  description = "Identity providers allowed for the OAuth (Hosted UI) flow."
  default     = ["COGNITO"]
}
