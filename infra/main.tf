locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ---- IAM (Lambda execution role) ----
module "iam_lambda" {
  source              = "git::ssh://git@github.com/sass-ecommerce/ctv-infraestructura-terraform-modules-01.git//modules/iam?ref=main"
  role_name           = "${var.project}-lambda-role-${var.environment}"
  assume_role_service = "lambda.amazonaws.com"
  policy_name         = "${var.project}-lambda-policy-${var.environment}"
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
        Resource = "arn:aws:dynamodb:*:*:table/${var.project}-*-${var.environment}"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::${var.project}-*-${var.environment}/*"
      }
    ]
  })
  tags = local.common_tags
}

# ---- DynamoDB ----
module "dynamodb_users" {
  source     = "git::ssh://git@github.com/sass-ecommerce/ctv-infraestructura-terraform-modules-01.git//modules/dynamodb?ref=main"
  table_name = "${var.project}-tbl-users-${var.environment}"
  hash_key   = "id"
  range_key  = "sub"
  tags       = local.common_tags
}

# ---- Cognito ----
data "aws_lambda_function" "pre_token" {
  function_name = "${var.project}-lambda-pre-token-${var.environment}"
}

data "aws_lambda_function" "post_confirmation" {
  function_name = "${var.project}-lambda-user-post-confirmation-${var.environment}"
}

module "cognito" {
  source          = "git::ssh://git@github.com/sass-ecommerce/ctv-infraestructura-terraform-modules-01.git//modules/cognito?ref=main"
  name            = "${var.project}-user-pool-${var.environment}"
  app_client_name = "${var.project}-app-client-${var.environment}"
  tags            = local.common_tags

  pre_token_generation_lambda_arn = data.aws_lambda_function.pre_token.arn
  post_confirmation_lambda_arn    = data.aws_lambda_function.post_confirmation.arn
}

module "secrets" {
  source      = "git::ssh://git@github.com/sass-ecommerce/ctv-infraestructura-terraform-modules-01.git//modules/secrets?ref=main"
  environment = var.environment
  app_name    = var.project
  tags        = local.common_tags

  string_parameters = {
    "iam/lambda-role-arn"   = module.iam_lambda.role_arn
    "cognito/user-pool-id"  = module.cognito.user_pool_id
    "cognito/app-client-id" = module.cognito.client_id
  }
}

