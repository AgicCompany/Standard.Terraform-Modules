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
  value       = var.local_authentication_disabled ? azurerm_application_insights.this.connection_string : null
  description = "Application Insights connection string (telemetry destination). Null when local authentication is enabled, so the module never exports a credential. Sensitive: redacted from normal plan/apply output, but still stored in state and revealed by 'terraform output -raw'."
  sensitive   = true
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_app_insights_id" {
  value       = azurerm_application_insights.this.id
  description = "Application Insights resource ID (for cross-project consumption)"
}
