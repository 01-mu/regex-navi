# Cloudflare Infrastructure

This directory manages Cloudflare resources with Terraform.

Secrets are managed by Infisical.

## Required Infisical secrets

| Name                           | Description           |
| ------------------------------ | --------------------- |
| `CLOUDFLARE_API_TOKEN`         | Cloudflare API token  |
| `TF_VAR_cloudflare_account_id` | Cloudflare account ID |

## Setup

```sh
infisical login
infisical init
```

## Commands

```sh
infisical run --env=prod -- terraform -chdir=infra/cloudflare init
infisical run --env=prod -- terraform -chdir=infra/cloudflare fmt
infisical run --env=prod -- terraform -chdir=infra/cloudflare validate
infisical run --env=prod -- terraform -chdir=infra/cloudflare plan -out=tfplan
```

## Command notes

- `infisical run --env=prod --` loads the production secrets into the command
  environment without writing them to local files.
- `terraform -chdir=infra/cloudflare` runs Terraform from this repository root
  while using `infra/cloudflare` as the Terraform working directory.
- `terraform init` installs the configured Terraform providers and prepares the
  working directory.
- `terraform fmt` formats Terraform files in the standard style.
- `terraform validate` checks that the Terraform configuration is syntactically
  valid and internally consistent.
- `terraform plan -out=tfplan` shows the changes Terraform would make and saves
  that exact plan to the local `tfplan` file.

## Apply

```sh
infisical run --env=prod -- terraform -chdir=infra/cloudflare apply tfplan
```

`terraform apply tfplan` applies the reviewed saved plan instead of creating a
new plan at apply time. `tfplan` is a local saved plan file. Review the plan
output before applying it, and recreate it whenever Terraform configuration or
variables change.
