locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ---- S3 ----
module "s3_products" {
  source            = "sass-ecommerce/ctv-infraestructura-terraform-modules-01/modules/s3"
  bucket_name       = "${var.project}-bucket-products-${var.environment}-01"
  environment       = var.environment
  enable_versioning = false
  tags              = local.common_tags

  lambda_notifications = [
    {
      lambda_function_arn = module.products_upload.function_arn
      events              = ["s3:ObjectCreated:Put"]
    }
  ]
}

# ---- IAM (Lambda execution role) ----
module "iam_lambda" {
  source              = "sass-ecommerce/ctv-infraestructura-terraform-modules-01/modules/iam"
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
  source     = "sass-ecommerce/ctv-infraestructura-terraform-modules-01/modules/dynamodb"
  table_name = "${var.project}-tbl-users-${var.environment}"
  hash_key   = "id"
  range_key  = "sub"
  tags       = local.common_tags
}

# ---- Cognito ----
module "cognito" {
  source          = "sass-ecommerce/ctv-infraestructura-terraform-modules-01/modules/cognito"
  name            = "${var.project}-user-pool-${var.environment}"
  app_client_name = "${var.project}-app-client-${var.environment}"
  tags            = local.common_tags

  pre_token_generation_lambda_arn = data.aws_lambda_function.pre_token.arn
  post_confirmation_lambda_arn    = data.aws_lambda_function.post_confirmation.arn
}

module "secrets" {
  source      = "sass-ecommerce/ctv-infraestructura-terraform-modules-01/modules/secrets"
  environment = var.environment
  app_name    = var.project
  tags        = local.common_tags

  string_parameters = {
    "iam/lambda-role-arn"    = module.iam_lambda.role_arn
    "cognito/user-pool-id"   = module.cognito.user_pool_id
    "cognito/app-client-id"  = module.cognito.client_id
    "s3/products-bucket-arn" = module.s3_products.bucket_arn
  }
}

