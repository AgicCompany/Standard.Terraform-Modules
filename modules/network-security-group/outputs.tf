# === Standard Outputs ===
output "id" {
  value       = azurerm_network_security_group.this.id
  description = "Network security group resource ID"
}

output "name" {
  value       = azurerm_network_security_group.this.name
  description = "Network security group name"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_nsg_id" {
  value       = azurerm_network_security_group.this.id
  description = "Network security group resource ID (for cross-project consumption)"
}
