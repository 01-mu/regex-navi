resource "cloudflare_pages_project" "regex_navi" {
  account_id        = var.cloudflare_account_id
  name              = "regex-navi"
  production_branch = "main"

  build_config = {
    build_command   = "bun install --frozen-lockfile && bun run build"
    destination_dir = "dist"
    root_dir        = ""
  }

  deployment_configs = {
    production = {
      env_vars = {
        SKIP_DEPENDENCY_INSTALL = {
          type  = "plain_text"
          value = "true"
        }
      }
    }

    preview = {
      env_vars = {
        SKIP_DEPENDENCY_INSTALL = {
          type  = "plain_text"
          value = "true"
        }
      }
    }
  }

  source = {
    type = "github"

    config = {
      owner                          = "01-mu"
      repo_name                      = "regex-navi"
      production_branch              = "main"

      production_deployments_enabled = true

      preview_deployment_setting = "all"
      preview_branch_includes    = ["*"]
      path_includes              = ["*"]

      pr_comments_enabled = true
    }
  }
}
