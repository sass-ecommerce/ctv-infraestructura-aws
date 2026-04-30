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
          "dynamodb:Scan",
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

# ---- DynamoDB ----
module "dynamodb_users" {
  source     = "../modules/dynamodb"
  table_name = "${var.app_name}-tbl-users-${var.environment}"
  hash_key   = "userId"
  tags       = local.common_tags
}

module "secrets" {
  source      = "../modules/secrets"
  environment = var.environment
  app_name    = var.app_name
  tags        = local.common_tags

  string_parameters = {
    "iam/lambda-role-arn" = module.iam_lambda.role_arn
  }
}

