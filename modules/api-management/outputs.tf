# === Standard Outputs ===
output "id" {
  value       = azurerm_api_management.this.id
  description = "API Management service resource ID"
}

output "name" {
  value       = azurerm_api_management.this.name
  description = "API Management service name"
}

# === Resource-Specific Outputs ===
output "gateway_url" {
  value       = azurerm_api_management.this.gateway_url
  description = "Gateway URL of the API Management service"
}

output "management_api_url" {
  value       = azurerm_api_management.this.management_api_url
  description = "Management API URL of the API Management service"
}

output "developer_portal_url" {
  value       = azurerm_api_management.this.developer_portal_url
  description = "Developer portal URL of the API Management service"
}

output "principal_id" {
  value       = try(azurerm_api_management.this.identity[0].principal_id, null)
  description = "System-assigned managed identity principal ID (when enabled)"
}

output "tenant_id" {
  value       = try(azurerm_api_management.this.identity[0].tenant_id, null)
  description = "System-assigned managed identity tenant ID (when enabled)"
}

output "public_ip_addresses" {
  value       = azurerm_api_management.this.public_ip_addresses
  description = "Public IP addresses of the API Management service"
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
output "public_apim_id" {
  value       = azurerm_api_management.this.id
  description = "API Management service ID (for cross-project consumption)"
}

output "public_apim_name" {
  value       = azurerm_api_management.this.name
  description = "API Management service name (for cross-project consumption)"
}

output "public_apim_gateway_url" {
  value       = azurerm_api_management.this.gateway_url
  description = "Gateway URL (for cross-project consumption)"
}
