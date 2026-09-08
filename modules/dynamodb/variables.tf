variable "table_name" {
  type        = string
  description = "DynamoDB table name"
}

variable "hash_key" {
  type        = string
  description = "Partition key attribute name"
}

variable "hash_key_type" {
  type        = string
  description = "Partition key type: S (String), N (Number), B (Binary)"
  default     = "S"
}

variable "range_key" {
  type        = string
  description = "Sort key attribute name (optional)"
  default     = null
}

variable "range_key_type" {
  type        = string
  description = "Sort key type: S (String), N (Number), B (Binary)"
  default     = "S"
}

variable "enable_point_in_time_recovery" {
  type        = bool
  description = "Enable Point-In-Time Recovery (recommended for prod)"
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
