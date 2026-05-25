# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform-managed AWS infrastructure for **chapa-tu-venta** (`ctv`). Terraform >= 1.10.0, AWS provider ~> 6.0, region `us-east-1`.

## Commands

```bash
# Format all .tf files (always run before committing)
terraform fmt -recursive

# Validate syntax without connecting to AWS
terraform validate

# Plan and apply locally (environment passed via -var)
cd infra
terraform init -backend-config="key=dev/terraform.tfstate"
terraform plan -var="environment=dev"
terraform apply -var="environment=dev" -auto-approve

# Bootstrap (one-time, creates the remote state S3 bucket)
cd bootstrap
terraform init
terraform apply -auto-approve
```

## Architecture

### Directory Layout

- `bootstrap/` — Creates the S3 bucket for remote Terraform state. Run once per AWS account.
- `infra/` — Single root module for all environments. The `environment` variable (`dev` or `prod`) is the only differentiator between environments.
- `modules/` — Reusable modules: `iam`, `s3`, `lambda`, `api_gateway`, `dynamodb`, `cognito`, `secrets`.

### Environment Strategy

There is one Terraform root (`infra/`) shared by both environments. The environment is determined by the branch in CI/CD (`develop` → `dev`, `main` → `prod`) and injected via `-var="environment=<env>"`. The S3 backend `key` is also passed dynamically at init time:

```bash
terraform init -backend-config="key=dev/terraform.tfstate"   # or prod/
```

This means there is no `terraform.tfvars` committed. Use `infra/terraform.tfvars.example` as a reference for local development.

### Remote State Backend

S3 with native file locking (`use_lockfile = true`). No DynamoDB lock table — the S3 native locking introduced in Terraform 1.10 is used instead. State files live at `dev/terraform.tfstate` and `prod/terraform.tfstate` in the same bucket.

### Naming Convention

All resources follow `${app_name}-<resource-type>-${environment}`, e.g. `ctv-lambda-role-dev`. SSM parameters are stored at `/${environment}/${app_name}/<path>`.

### Module Behaviors Worth Knowing

- **`modules/lambda`** — Always creates a `/aws/lambda/<function_name>` CloudWatch log group and grants API Gateway invoke permission when `api_gateway_execution_arn` is set.
- **`modules/cognito`** — Uses email as the username attribute with two custom schema attributes (`id`, `tenantId`). Lambda triggers (pre-token generation, post-confirmation) are wired via `data.aws_lambda_function` lookups — those Lambdas must exist before applying.
- **`modules/dynamodb`** — PAY_PER_REQUEST billing, PITR enabled by default, supports optional range key.
- **`modules/secrets`** — Stores values in SSM Parameter Store (String or SecureString) and optionally in Secrets Manager. Currently stores IAM role ARN and Cognito IDs as plain SSM Strings.
- **`modules/api_gateway`** — HTTP API v2, single `$default` route via AWS_PROXY Lambda integration, auto-deploy enabled.

### CI/CD (GitHub Actions)

Single workflow `.github/workflows/terraform.yml`. Authentication uses OIDC. Environment is resolved from the branch in a "Resolve environment" step at the start of each job.

| Event | Branch | Environment | AWS Secret | Action |
|-------|--------|-------------|------------|--------|
| PR | → `develop` | `dev` | `AWS_ROLE_ARN` | plan + PR comment |
| PR | → `main` | `prod` | `AWS_ROLE_ARN_PROD` | plan + PR comment |
| Push | `develop` | `dev` | `AWS_ROLE_ARN` | apply |
| Push | `main` | `prod` | `AWS_ROLE_ARN_PROD` | apply |

Required GitHub secrets: `AWS_ROLE_ARN` (dev) and `AWS_ROLE_ARN_PROD` (prod).

## Adding a New Resource

1. Check `modules/<name>/variables.tf` for accepted inputs.
2. Add the `module` block to `infra/main.tf`.
3. If the module exposes outputs needed elsewhere (e.g., an ARN stored in SSM), wire them through `modules/secrets`.
4. Run `terraform fmt -recursive` then `terraform plan -var="environment=dev"` before committing.
