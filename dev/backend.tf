# Run `cd bootstrap && terraform apply` first to create this bucket and table.
# Then replace REPLACE_WITH_ACCOUNT_ID with the value from the bootstrap output.
terraform {
  backend "s3" {
    bucket       = "ctv-terraform-state-005602595686"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
