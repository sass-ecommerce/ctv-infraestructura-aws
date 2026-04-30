output "secret_arns" {
  description = "Map of secret key → ARN in Secrets Manager"
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}

output "parameter_arns" {
  description = "Map of parameter key → ARN in SSM Parameter Store"
  value = merge(
    { for k, v in aws_ssm_parameter.this : k => v.arn },
    { for k, v in aws_ssm_parameter.string : k => v.arn }
  )
}

output "parameter_names" {
  description = "Map of parameter key → full SSM path"
  value = merge(
    { for k, v in aws_ssm_parameter.this : k => v.name },
    { for k, v in aws_ssm_parameter.string : k => v.name }
  )
}
