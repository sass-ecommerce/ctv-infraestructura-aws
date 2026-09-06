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

module "dynamodb_products" {
  source     = "sass-ecommerce/ctv-infraestructura-terraform-modules-01/modules/dynamodb"
  table_name = "${var.project}-tbl-products-${var.environment}"
  hash_key   = "tenantId"
  range_key  = "productId"
  tags       = local.common_tags
}

# ---- Cognito ----
module "cognito" {
  source                   = "../modules/cognito"
  name                     = "${var.project}-user-pool-${var.environment}"
  app_client_name          = "${var.project}-app-client-${var.environment}"
  oauth_callback_urls      = ["app-chapa-tu-venta://"]
  oauth_identity_providers = ["COGNITO", "Google"]
  tags                     = local.common_tags
}

# Hosted UI (classic) domain, used for federated login (e.g. Google) via OAuth2 authorize/token endpoints.
resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.project}-${var.environment}"
  user_pool_id = module.cognito.user_pool_id
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = module.cognito.user_pool_id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "openid email profile"
  }

  attribute_mapping = {
    email       = "email"
    given_name  = "given_name"
    family_name = "family_name"
    username    = "sub"
  }
}

# NOTE: module.cognito's app client references the "Google" identity provider by
# literal name (via oauth_identity_providers), not by resource attribute, to avoid
# a dependency cycle (the identity provider itself depends on module.cognito's
# user_pool_id output). This is safe today because the Google identity provider
# already exists; a from-scratch environment recreation would need it applied first
# (e.g. via `terraform apply -target=aws_cognito_identity_provider.google` once).

# ---- EventBridge ----
resource "aws_cloudwatch_event_bus" "main" {
  name = "${var.project}-event-bus-${var.environment}"
  tags = local.common_tags
}

resource "aws_cloudwatch_event_rule" "products" {
  name           = "${var.project}-rule-products-${var.environment}"
  event_bus_name = aws_cloudwatch_event_bus.main.name
  state          = "ENABLED"

  event_pattern = jsonencode({
    source = ["${var.project}.products"]
  })

  tags = local.common_tags
}

module "secrets" {
  source      = "sass-ecommerce/ctv-infraestructura-terraform-modules-01/modules/secrets"
  environment = var.environment
  app_name    = var.project
  tags        = local.common_tags

  string_parameters = {
    "iam/lambda-role-arn"           = module.iam_lambda.role_arn
    "cognito/user-pool-id"          = module.cognito.user_pool_id
    "cognito/app-client-id"         = module.cognito.client_id
    "cognito/domain"                = aws_cognito_user_pool_domain.this.domain
    "s3/products-bucket-arn"        = module.s3_products.bucket_arn
    "eventbridge/event-bus-arn"     = aws_cloudwatch_event_bus.main.arn
    "eventbridge/rule-products-arn" = aws_cloudwatch_event_rule.products.arn
  }
}

