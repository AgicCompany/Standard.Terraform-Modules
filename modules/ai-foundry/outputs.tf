# === Standard Outputs ===
output "id" {
  value       = azurerm_ai_foundry.this.id
  description = "AI Foundry hub resource ID"
}

output "name" {
  value       = var.name
  description = "AI Foundry hub name (echo of var.name; resource does not export it)"
}

# === Resource-Specific Outputs ===
output "workspace_id" {
  value       = azurerm_ai_foundry.this.workspace_id
  description = "Immutable workspace ID of the hub"
}

output "discovery_url" {
  value       = azurerm_ai_foundry.this.discovery_url
  description = "Discovery URL for regional service endpoints"
}

output "principal_id" {
  value       = try(azurerm_ai_foundry.this.identity[0].principal_id, null)
  description = "System-assigned identity principal ID (null when not enabled)"
}

output "tenant_id" {
  value       = try(azurerm_ai_foundry.this.identity[0].tenant_id, null)
  description = "System-assigned identity tenant ID (null when not enabled)"
}

# === Project Outputs ===
output "project_id" {
  value       = azurerm_ai_foundry_project.this.id
  description = "Default project resource ID"
}

output "project_name" {
  value       = azurerm_ai_foundry_project.this.name
  description = "Default project name"
}

output "project_workspace_id" {
  value       = azurerm_ai_foundry_project.this.project_id
  description = "Default project immutable workspace ID"
}

# === Private Endpoint Outputs ===
output "private_endpoint_id" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
  description = "Private endpoint resource ID (null when disabled)"
}

output "private_endpoint_ip_address" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address : null
  description = "Private endpoint NIC primary IP (null when disabled)"
}
