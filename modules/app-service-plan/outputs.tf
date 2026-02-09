# === Standard Outputs ===
output "id" {
  value       = azurerm_service_plan.this.id
  description = "App Service Plan resource ID"
}

output "name" {
  value       = azurerm_service_plan.this.name
  description = "App Service Plan name"
}

# === Resource-Specific Outputs ===
output "kind" {
  value       = azurerm_service_plan.this.kind
  description = "The kind value of the service plan"
}

output "reserved" {
  value       = azurerm_service_plan.this.reserved
  description = "Whether this is a Linux plan"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_service_plan_id" {
  value       = azurerm_service_plan.this.id
  description = "App Service Plan resource ID (for cross-project consumption)"
}
