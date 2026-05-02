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
infisical run --env=prod -- terraform -chdir=infra/cloudflare plan
```

## Apply

```sh
infisical run --env=prod -- terraform -chdir=infra/cloudflare apply
```
