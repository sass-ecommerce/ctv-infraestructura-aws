output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.iam_lambda.role_arn
}

output "ssm_parameter_names" {
  description = "Map of parameter key → full SSM path"
  value       = module.secrets.parameter_names
}

