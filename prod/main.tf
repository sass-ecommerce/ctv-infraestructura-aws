locals {
  common_tags = {
    Project     = "chapa-tu-venta"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ---- IAM (Lambda execution role) ----
module "iam_lambda" {
  source              = "../modules/iam"
  role_name           = "${var.app_name}-lambda-role-${var.environment}"
  assume_role_service = "lambda.amazonaws.com"
  policy_name         = "${var.app_name}-lambda-policy-${var.environment}"
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
  tags = local.common_tags
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.iam_lambda.role_arn
}
