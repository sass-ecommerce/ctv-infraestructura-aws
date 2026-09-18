variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to use as origin (also used to name the OAC and origin id)"
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "Regional domain name of the S3 bucket origin"
}

variable "price_class" {
  type        = string
  default     = "PriceClass_100"
  description = "CloudFront price class (PriceClass_100, PriceClass_200, PriceClass_All)"
}

variable "comment" {
  type        = string
  default     = ""
  description = "Comment for the CloudFront distribution"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to the distribution"
}
