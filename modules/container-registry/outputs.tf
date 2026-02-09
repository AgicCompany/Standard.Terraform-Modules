# === Standard Outputs ===
output "id" {
  value       = azurerm_container_registry.this.id
  description = "Container Registry resource ID"
}

output "name" {
  value       = azurerm_container_registry.this.name
  description = "Container Registry name"
}

# === Resource-Specific Outputs ===
output "login_server" {
  value       = azurerm_container_registry.this.login_server
  description = "Login server URL (e.g., myregistry.azurecr.io)"
}

output "principal_id" {
  value       = azurerm_container_registry.this.identity[0].principal_id
  description = "System-assigned managed identity principal ID"
}

output "tenant_id" {
  value       = azurerm_container_registry.this.identity[0].tenant_id
  description = "System-assigned managed identity tenant ID"
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
output "public_acr_id" {
  value       = azurerm_container_registry.this.id
  description = "Container Registry resource ID (for cross-project consumption)"
}

output "public_acr_name" {
  value       = azurerm_container_registry.this.name
  description = "Container Registry name (for cross-project consumption)"
}

output "public_acr_login_server" {
  value       = azurerm_container_registry.this.login_server
  description = "Login server URL (for cross-project consumption)"
}
