# ctv-infraestructura-aws

Infraestructura AWS para **chapa-tu-venta** gestionada con Terraform.

---

## Requisitos previos

### 1. Terraform

```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verificar
terraform -version
# Terraform v1.8.0 o superior
```

### 2. AWS CLI

```bash
# macOS
brew install awscli

# Verificar
aws --version
```

### 3. Credenciales AWS

Necesitás configurar credenciales con permisos suficientes para crear recursos IAM, S3 y DynamoDB.

```bash
aws configure
# AWS Access Key ID:     <tu-access-key>
# AWS Secret Access Key: <tu-secret-key>
# Default region name:   us-east-1
# Default output format: json
```

> Si usás roles o SSO, asegurate de que `aws sts get-caller-identity` devuelva tu cuenta antes de correr Terraform.

---

## Estructura del proyecto

```
ctv-infraestructura-aws/
├── bootstrap/          # Paso 1: crea el backend remoto (S3 + DynamoDB)
├── modules/            # Módulos reutilizables
│   ├── iam/
│   ├── s3/
│   ├── lambda/
│   ├── api_gateway/
│   ├── dynamodb/
│   └── secrets/
├── dev/                # Ambiente de desarrollo
└── prod/               # Ambiente de producción
```

---

## Despliegue paso a paso

### Paso 1 — Bootstrap (una sola vez)

Crea el bucket S3 y la tabla DynamoDB que guardarán el estado remoto de Terraform.

```bash
cd bootstrap
terraform init
terraform apply -auto-approve
```

Al finalizar, el output muestra el Account ID:

```
Outputs:

account_id      = "123456789012"
state_bucket_name = "ctv-terraform-state-123456789012"
lock_table_name   = "ctv-terraform-locks"
```

### Paso 2 — Configurar el backend en cada ambiente

Reemplazá `REPLACE_WITH_ACCOUNT_ID` con el valor del output anterior en:

- `dev/backend.tf`
- `prod/backend.tf`

```hcl
# Ejemplo: dev/backend.tf
terraform {
  backend "s3" {
    bucket         = "ctv-terraform-state-123456789012"  # ← tu account ID
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ctv-terraform-locks"
    encrypt        = true
  }
}
```

### Paso 3 — Desplegar dev

```bash
cd ../dev
terraform init
terraform plan     # revisar qué se va a crear
terraform apply  -auto-approve
```

### Paso 4 — Desplegar prod

```bash
cd ../prod
terraform init
terraform plan
terraform apply
```

---

## Comandos útiles del día a día

```bash
# Ver qué recursos administra Terraform
terraform state list

# Ver el valor de un output
terraform output lambda_role_arn

# Destruir todos los recursos de un ambiente (con cuidado en prod)
terraform destroy

# Reformatear archivos .tf
terraform fmt -recursive

# Validar sintaxis sin conectarse a AWS
terraform validate
```

---

## Agregar un nuevo recurso

1. El módulo ya existe en `modules/` — revisá qué variables acepta en `modules/<nombre>/variables.tf`
2. Agregá el bloque `module` en `dev/main.tf` (y luego en `prod/main.tf`)
3. Corré `terraform plan` para verificar y `terraform apply` para aplicar

---

## Recursos creados actualmente

| Recurso    | Nombre en dev           | Nombre en prod           |
| ---------- | ----------------------- | ------------------------ |
| IAM Role   | `ctv-lambda-role-dev`   | `ctv-lambda-role-prod`   |
| IAM Policy | `ctv-lambda-policy-dev` | `ctv-lambda-policy-prod` |
