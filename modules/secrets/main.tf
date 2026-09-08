resource "aws_secretsmanager_secret" "this" {
  for_each = nonsensitive(toset(keys(var.secrets)))
  name     = "/${var.environment}/${var.app_name}/${each.key}"
  tags     = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each      = nonsensitive(toset(keys(var.secrets)))
  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = var.secrets[each.key]
}

resource "aws_ssm_parameter" "this" {
  for_each = nonsensitive(toset(keys(var.parameters)))
  name     = "/${var.environment}/${var.app_name}/${each.key}"
  type     = "SecureString"
  value    = var.parameters[each.key]
  tags     = var.tags
}

resource "aws_ssm_parameter" "string" {
  for_each = var.string_parameters
  name     = "/${var.environment}/${var.app_name}/${each.key}"
  type     = "String"
  value    = each.value
  tags     = var.tags
}
