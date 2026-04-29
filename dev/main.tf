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
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.app_name}-*-${var.environment}"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.app_name}-*-${var.environment}"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::${var.app_name}-*-${var.environment}/*"
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_ssm_parameter" "lambda_role_arn" {
  name  = "/${var.environment}/${var.app_name}/iam/lambda-role-arn"
  type  = "String"
  value = module.iam_lambda.role_arn
  tags  = local.common_tags
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.iam_lambda.role_arn
}
