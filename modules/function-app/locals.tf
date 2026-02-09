# locals.tf - Local values

locals {
  # Determine identity type based on configuration
  identity_type = (
    var.enable_system_assigned_identity && length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.enable_system_assigned_identity ? "SystemAssigned" :
    length(var.user_assigned_identity_ids) > 0 ? "UserAssigned" :
    null
  )

  # Merge Application Insights connection string into app settings
  app_settings = merge(
    var.app_settings,
    var.enable_application_insights && var.application_insights_connection_string != null ? {
      APPLICATIONINSIGHTS_CONNECTION_STRING = var.application_insights_connection_string
    } : {}
  )
}
