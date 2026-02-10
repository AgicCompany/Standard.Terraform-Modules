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

output "instrumentation_key" {
  value       = azurerm_application_insights.this.instrumentation_key
  description = "Application Insights instrumentation key"
  sensitive   = true
}

output "connection_string" {
  value       = azurerm_application_insights.this.connection_string
  description = "Application Insights connection string"
  sensitive   = true
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_app_insights_id" {
  value       = azurerm_application_insights.this.id
  description = "Application Insights resource ID (for cross-project consumption)"
}

output "public_connection_string" {
  value       = azurerm_application_insights.this.connection_string
  description = "Application Insights connection string (for cross-project consumption)"
  sensitive   = true
}
