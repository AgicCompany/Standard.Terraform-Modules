# locals.tf - Local values

locals {
  default_server_configurations = {
    "require_secure_transport" = "on"
  }

  merged_server_configurations = merge(local.default_server_configurations, var.server_configurations)
}
