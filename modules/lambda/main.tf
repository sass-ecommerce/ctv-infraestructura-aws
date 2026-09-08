resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  runtime          = var.runtime
  handler          = var.handler
  role             = var.role_arn
  memory_size      = var.memory_size
  timeout          = var.timeout
  filename         = var.filename
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  source_code_hash = var.source_code_hash

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  tags = var.tags

  depends_on = [aws_cloudwatch_log_group.this]
}

resource "aws_lambda_permission" "api_gateway" {
  count         = var.api_gateway_execution_arn != null ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}
