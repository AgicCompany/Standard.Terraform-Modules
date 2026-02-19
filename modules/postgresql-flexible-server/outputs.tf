# === Standard Outputs ===
output "id" {
  value       = azurerm_postgresql_flexible_server.this.id
  description = "PostgreSQL Flexible Server resource ID"
}

output "name" {
  value       = azurerm_postgresql_flexible_server.this.name
  description = "PostgreSQL Flexible Server name"
}

# === Resource-Specific Outputs ===
output "fqdn" {
  value       = azurerm_postgresql_flexible_server.this.fqdn
  description = "Fully qualified domain name of the PostgreSQL server"
}

output "database_ids" {
  value       = { for k, v in azurerm_postgresql_flexible_server_database.this : k => v.id }
  description = "Map of database names to database resource IDs"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_postgresql_server_id" {
  value       = azurerm_postgresql_flexible_server.this.id
  description = "PostgreSQL Flexible Server resource ID (for cross-project consumption)"
}

output "public_postgresql_server_name" {
  value       = azurerm_postgresql_flexible_server.this.name
  description = "PostgreSQL Flexible Server name (for cross-project consumption)"
}

output "public_postgresql_server_fqdn" {
  value       = azurerm_postgresql_flexible_server.this.fqdn
  description = "PostgreSQL Flexible Server FQDN (for cross-project consumption)"
}

# === Private Endpoint Outputs ===
output "private_endpoint_id" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
  description = "Private endpoint resource ID (when enabled)"
}

output "private_ip_address" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address : null
  description = "Private IP address of the private endpoint (when enabled)"
}
