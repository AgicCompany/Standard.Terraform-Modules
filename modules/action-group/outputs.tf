# === Standard Outputs ===
output "id" {
  value       = azurerm_monitor_action_group.this.id
  description = "Action group resource ID"
}

output "name" {
  value       = azurerm_monitor_action_group.this.name
  description = "Action group name"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_action_group_id" {
  value       = azurerm_monitor_action_group.this.id
  description = "Action group resource ID (for cross-project consumption)"
}
