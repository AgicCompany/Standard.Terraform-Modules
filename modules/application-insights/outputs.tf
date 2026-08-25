# === Standard Outputs ===
output "id" {
  value       = azurerm_application_insights.this.id
  description = "Application Insights resource ID"
}

output "name" {
  value       = azurerm_application_insights.this.name
  description = "Application Insights name"
}

# === Resource-Specific Outputs ===
output "app_id" {
  value       = azurerm_application_insights.this.app_id
  description = "Application Insights application ID"
}

output "connection_string" {
  value       = azurerm_application_insights.this.connection_string
  description = "Application Insights connection string (telemetry destination). Not a credential while local_authentication_disabled = true (the default); treat as a secret if you enable local authentication."
  sensitive   = true
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_app_insights_id" {
  value       = azurerm_application_insights.this.id
  description = "Application Insights resource ID (for cross-project consumption)"
}
