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

# === Public Outputs (Cross-Project Consumption) ===
output "public_app_insights_id" {
  value       = azurerm_application_insights.this.id
  description = "Application Insights resource ID (for cross-project consumption)"
}
