# === Standard Outputs ===
output "id" {
  value       = azurerm_linux_web_app.this.id
  description = "Linux Web App resource ID"
}

output "name" {
  value       = azurerm_linux_web_app.this.name
  description = "Linux Web App name"
}

# === Resource-Specific Outputs ===
output "default_hostname" {
  value       = azurerm_linux_web_app.this.default_hostname
  description = "Default hostname of the web app"
}

output "outbound_ip_addresses" {
  value       = azurerm_linux_web_app.this.outbound_ip_addresses
  description = "Outbound IP addresses (comma-separated)"
}

output "principal_id" {
  value       = try(azurerm_linux_web_app.this.identity[0].principal_id, null)
  description = "System-assigned managed identity principal ID (when enabled)"
}

output "tenant_id" {
  value       = try(azurerm_linux_web_app.this.identity[0].tenant_id, null)
  description = "System-assigned managed identity tenant ID (when enabled)"
}

# === Private Endpoint Outputs ===
output "private_endpoint_id" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
  description = "Private endpoint resource ID (when enabled)"
}

output "private_ip_address" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address : null
  description = "Private IP address of the private endpoint (when enabled)"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_web_app_id" {
  value       = azurerm_linux_web_app.this.id
  description = "Web app ID (for cross-project consumption)"
}

output "public_web_app_name" {
  value       = azurerm_linux_web_app.this.name
  description = "Web app name (for cross-project consumption)"
}

output "public_web_app_default_hostname" {
  value       = azurerm_linux_web_app.this.default_hostname
  description = "Default hostname (for cross-project consumption)"
}
