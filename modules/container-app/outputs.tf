# === Standard Outputs ===
output "id" {
  value       = azurerm_container_app.this.id
  description = "Container App resource ID"
}

output "name" {
  value       = azurerm_container_app.this.name
  description = "Container App name"
}

# === Resource-Specific Outputs ===
output "latest_revision_fqdn" {
  value       = azurerm_container_app.this.latest_revision_fqdn
  description = "FQDN of the latest revision"
}

output "latest_revision_name" {
  value       = azurerm_container_app.this.latest_revision_name
  description = "Name of the latest revision"
}

output "outbound_ip_addresses" {
  value       = azurerm_container_app.this.outbound_ip_addresses
  description = "Outbound IP addresses"
}

output "principal_id" {
  value       = try(azurerm_container_app.this.identity[0].principal_id, null)
  description = "System-assigned managed identity principal ID (when enabled)"
}

output "tenant_id" {
  value       = try(azurerm_container_app.this.identity[0].tenant_id, null)
  description = "System-assigned managed identity tenant ID (when enabled)"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_container_app_id" {
  value       = azurerm_container_app.this.id
  description = "Container App resource ID (for cross-project consumption)"
}

output "public_container_app_name" {
  value       = azurerm_container_app.this.name
  description = "Container App name (for cross-project consumption)"
}

output "public_container_app_fqdn" {
  value       = azurerm_container_app.this.latest_revision_fqdn
  description = "Latest revision FQDN (for cross-project consumption)"
}
