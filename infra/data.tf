data "aws_lambda_function" "products_upload" {
  function_name = "${var.project}-lambda-s3-products-upload-${var.environment}-01"
}

data "aws_lambda_function" "pre_token" {
  function_name = "${var.project}-lambda-pre-token-${var.environment}-01"
}

data "aws_lambda_function" "post_confirmation" {
  function_name = "${var.project}-lambda-user-post-confirmation-${var.environment}-01"
}
