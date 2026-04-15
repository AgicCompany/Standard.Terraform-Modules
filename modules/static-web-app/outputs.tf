# === Standard Outputs ===
output "id" {
  value       = azurerm_static_web_app.this.id
  description = "Static Web App resource ID"
}

output "name" {
  value       = azurerm_static_web_app.this.name
  description = "Static Web App name"
}

# === Resource-Specific Outputs ===
output "default_host_name" {
  value       = azurerm_static_web_app.this.default_host_name
  description = "Default hostname of the Static Web App"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_static_web_app_id" {
  value       = azurerm_static_web_app.this.id
  description = "Static Web App resource ID (for cross-project consumption)"
}

output "public_default_host_name" {
  value       = azurerm_static_web_app.this.default_host_name
  description = "Default hostname (for cross-project consumption)"
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
