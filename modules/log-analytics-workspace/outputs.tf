# === Standard Outputs ===
output "id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "Log Analytics workspace resource ID"
}

output "name" {
  value       = azurerm_log_analytics_workspace.this.name
  description = "Log Analytics workspace name"
}

# === Resource-Specific Outputs ===
output "workspace_id" {
  value       = azurerm_log_analytics_workspace.this.workspace_id
  description = "Log Analytics workspace GUID"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_workspace_id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "Log Analytics workspace resource ID (for cross-project consumption)"
}
