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
terraform init -backend-config="bucket=ctv-terraform-state-dev" -backend-config="key=dev/terraform.tfstate"
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
- `infra/` — Single root module for all environments. `terraform.tfvars` is committed with dev defaults; `environment` is the only variable that differs between envs.
- Reusable modules live in a **separate private GitHub repository**: `sass-ecommerce/ctv-infraestructura-terraform-modules-01` (modules: `iam`, `s3`, `lambda`, `api_gateway`, `dynamodb`, `cognito`, `secrets`).

### Module Sources

Module sources in `main.tf` use a shorthand form (`sass-ecommerce/<repo>/modules/<name>`) that works locally when git credentials are configured. CI rewrites them at runtime via `sed` to explicit git URLs pinned to a branch:

- `develop` branch → modules pinned to `?ref=develop`
- `main` branch → modules pinned to `?ref=main`

This rewrite is transparent locally but must be kept in mind when reading CI logs.

### Environment Strategy

One Terraform root (`infra/`) serves both environments. The environment is determined by the branch in CI/CD (`develop` → `dev`, `main` → `prod`) and injected via `-var="environment=<env>"`. The S3 backend bucket and key are also passed dynamically:

- Dev: `bucket=ctv-terraform-state-dev`, `key=dev/terraform.tfstate`
- Prod: `bucket=ctv-terraform-state-prod`, `key=prod/terraform.tfstate`

`infra/terraform.tfvars` is committed with dev defaults (`environment=dev`, `project=ctv`, `project_name=chapa-tu-venta`).

### Remote State Backend

S3 with native file locking (`use_lockfile = true`). No DynamoDB lock table — S3 native locking (Terraform 1.10) is used instead.

### Naming Convention

All resources follow `${project}-<resource-type>-${environment}`, e.g. `ctv-lambda-role-dev`. SSM parameters are stored at `/${environment}/${project}/<path>`.

### Module Behaviors Worth Knowing

- **`modules/lambda`** — Always creates a `/aws/lambda/<function_name>` CloudWatch log group and grants API Gateway invoke permission when `api_gateway_execution_arn` is set.
- **`modules/cognito`** — Uses email as the username attribute with two custom schema attributes (`id`, `tenantId`). Lambda triggers (pre-token generation, post-confirmation) are wired via `data.aws_lambda_function` lookups — **those Lambdas must exist before applying**. Expected names: `ctv-lambda-pre-token-<env>-01` and `ctv-lambda-user-post-confirmation-<env>-01`.
- **`modules/dynamodb`** — PAY_PER_REQUEST billing, PITR enabled by default, supports optional range key.
- **`modules/secrets`** — Stores values in SSM Parameter Store (String or SecureString). Currently stores IAM role ARN, Cognito IDs, and S3 products bucket ARN as plain SSM Strings.
- **`modules/api_gateway`** — HTTP API v2, single `$default` route via AWS_PROXY Lambda integration, auto-deploy enabled.

### CI/CD (GitHub Actions)

Single workflow `.github/workflows/terraform.yml`. Authentication uses OIDC. Three triggers:

| Event | Branch/Input | Environment | Action |
|-------|-------------|-------------|--------|
| PR | → `develop` | `dev` | plan + PR comment |
| PR | → `main` | `prod` | plan + PR comment |
| Push | `develop` | `dev` | apply |
| Push | `main` | `prod` | apply |
| `workflow_dispatch` | manual input | `dev` or `prod` | plan + apply |

Required GitHub secrets: `AWS_ROLE_ARN` (dev), `AWS_ROLE_ARN_PROD` (prod), `TF_MODULES_TOKEN` (GitHub token for private module repo access).

## Adding a New Resource

1. Check the module's `variables.tf` in `sass-ecommerce/ctv-infraestructura-terraform-modules-01`.
2. Add the `module` block to `infra/main.tf` using the shorthand source format.
3. If the module exposes outputs needed elsewhere (e.g., an ARN stored in SSM), wire them through the `secrets` module in `infra/main.tf`.
4. Run `terraform fmt -recursive` then `terraform plan -var="environment=dev"` before committing.
