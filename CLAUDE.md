# CLAUDE.md

## Backend de Terraform

`infra/backend.tf` declara un backend `s3` sin `bucket`/`key` hardcodeados a propósito — esos valores se inyectan vía `-backend-config` en el pipeline de CI (`.github/workflows/`), no localmente.

**No intentar `terraform init`/`plan`/`apply` contra el backend real desde el entorno local.** No hay credenciales de AWS ni bucket de state disponibles aquí. Para verificar cambios de Terraform localmente, limitarse a:
- `terraform fmt -recursive`
- `terraform validate` a nivel de módulo individual, con `terraform init -backend=false` dentro del módulo (por ejemplo `modules/cloudfront/`)

`terraform validate` en la raíz de `infra/` va a fallar por el backend incompleto (falta `bucket`/`key`) incluso con `-backend=false` — es un falso negativo esperado de este repo, no un error real de la configuración. No hay que "arreglarlo" agregando bucket/key dummy ni tocando `backend.tf`.

El plan real (`terraform plan`) se ejecuta en CI, donde sí están las credenciales y el `-backend-config` correcto.
