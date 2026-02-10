# === Standard Outputs ===
output "id" {
  value       = azurerm_route_table.this.id
  description = "Route table resource ID"
}

output "name" {
  value       = azurerm_route_table.this.name
  description = "Route table name"
}

# === Resource-Specific Outputs ===
output "route_ids" {
  value       = { for k, v in azurerm_route.this : k => v.id }
  description = "Map of route names to route resource IDs"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_route_table_id" {
  value       = azurerm_route_table.this.id
  description = "Route table resource ID (for cross-project consumption)"
}
