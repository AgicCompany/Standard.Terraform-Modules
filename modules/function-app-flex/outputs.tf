# === Standard Outputs ===
output "id" {
  value       = azurerm_function_app_flex_consumption.this.id
  description = "Function App resource ID."
}

output "name" {
  value       = azurerm_function_app_flex_consumption.this.name
  description = "Function App name."
}

# === Resource-Specific Outputs ===
output "default_hostname" {
  value       = azurerm_function_app_flex_consumption.this.default_hostname
  description = "Default hostname of the Function App."
}

output "identity" {
  value       = azurerm_function_app_flex_consumption.this.identity
  description = "Managed identity block (principal_id, tenant_id)."
}

output "private_endpoint_id" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
  description = "Private endpoint resource ID."
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_function_app_flex_id" {
  value       = azurerm_function_app_flex_consumption.this.id
  description = "Function App resource ID (for cross-project consumption)."
}

output "public_function_app_flex_name" {
  value       = azurerm_function_app_flex_consumption.this.name
  description = "Function App name (for cross-project consumption)."
}
