# locals.tf - Local values

locals {
  # Windows computer name: max 15 characters
  computer_name = var.computer_name != null ? var.computer_name : substr(var.name, 0, 15)

  # Determine identity type based on configuration
  identity_type = (
    var.enable_system_assigned_identity && length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.enable_system_assigned_identity ? "SystemAssigned" :
    length(var.user_assigned_identity_ids) > 0 ? "UserAssigned" :
    null
  )
}
