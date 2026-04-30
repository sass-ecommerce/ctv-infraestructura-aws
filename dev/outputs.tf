output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.iam_lambda.role_arn
}

output "ssm_parameter_names" {
  description = "Map of parameter key → full SSM path"
  value       = module.secrets.parameter_names
}

output "dynamodb_tbl_users" {
  description = "Name of the DynamoDB table for users"
  value       = module.dynamodb_users.table_name
}