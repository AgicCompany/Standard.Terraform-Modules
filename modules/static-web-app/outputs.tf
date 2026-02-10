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

output "api_key" {
  value       = azurerm_static_web_app.this.api_key
  description = "API key for deployment (used in CI/CD pipelines)"
  sensitive   = true
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
