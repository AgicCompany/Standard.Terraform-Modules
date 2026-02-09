# locals.tf - Local values

locals {
  identity_type = (
    var.enable_system_assigned_identity && length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.enable_system_assigned_identity ? "SystemAssigned" :
    length(var.user_assigned_identity_ids) > 0 ? "UserAssigned" :
    null
  )

  # Sanitize the container name from the module name (lowercase, alphanumeric, hyphens only)
  container_name = replace(lower(var.name), "/[^a-z0-9-]/", "")
}
