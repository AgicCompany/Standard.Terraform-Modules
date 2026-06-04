locals {
  identity_type = (
    var.enable_system_assigned_identity && length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.enable_system_assigned_identity ? "SystemAssigned" :
    length(var.user_assigned_identity_ids) > 0 ? "UserAssigned" :
    null
  )

  container_name = replace(lower(var.name), "/[^a-z0-9-]/", "")

  # Abstracts which resource instance is active based on the lifecycle feature flag.
  # NOTE: toggling enable_secret_ignore_changes will destroy and recreate the job.
  job = var.enable_secret_ignore_changes ? (
    azurerm_container_app_job.with_lifecycle[0]
    ) : (
    azurerm_container_app_job.without_lifecycle[0]
  )
}
