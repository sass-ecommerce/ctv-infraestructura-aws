output "distribution_id" {
  description = "The CloudFront distribution ID"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "The CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "The CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "oac_id" {
  description = "The CloudFront Origin Access Control ID"
  value       = aws_cloudfront_origin_access_control.this.id
}
