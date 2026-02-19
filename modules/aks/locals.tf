# locals.tf - Local values

locals {
  dns_prefix = coalesce(var.dns_prefix, var.name)

  # Determine identity type based on configuration
  identity_type = (
    var.enable_system_assigned_identity && length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.enable_system_assigned_identity ? "SystemAssigned" :
    length(var.user_assigned_identity_ids) > 0 ? "UserAssigned" :
    null
  )
}
