# === Standard Outputs ===
output "id" {
  value       = azurerm_monitor_diagnostic_setting.this.id
  description = "Diagnostic setting resource ID"
}

output "name" {
  value       = azurerm_monitor_diagnostic_setting.this.name
  description = "Diagnostic setting name"
}
