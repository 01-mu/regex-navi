resource "cloudflare_pages_project" "regex_navi" {
  account_id        = var.cloudflare_account_id
  name              = "regex-navi"
  production_branch = "main"

  build_config = {
    build_command       = "bun install --frozen-lockfile && bun run build"
    destination_dir     = "dist"
    root_dir            = ""
    web_analytics_tag   = null
    web_analytics_token = null
  }

  deployment_configs = {
    production = {
      environment_variables = {
        SKIP_DEPENDENCY_INSTALL = {
          value = "true"
        }
      }
    }

    preview = {
      environment_variables = {
        SKIP_DEPENDENCY_INSTALL = {
          value = "true"
        }
      }
    }
  }
}
