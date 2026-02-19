# === Standard Outputs ===
output "id" {
  value       = azurerm_mysql_flexible_server.this.id
  description = "MySQL Flexible Server resource ID"
}

output "name" {
  value       = azurerm_mysql_flexible_server.this.name
  description = "MySQL Flexible Server name"
}

# === Resource-Specific Outputs ===
output "fqdn" {
  value       = azurerm_mysql_flexible_server.this.fqdn
  description = "Fully qualified domain name of the MySQL server"
}

output "database_ids" {
  value       = { for k, v in azurerm_mysql_flexible_database.this : k => v.id }
  description = "Map of database names to database resource IDs"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_mysql_server_id" {
  value       = azurerm_mysql_flexible_server.this.id
  description = "MySQL Flexible Server resource ID (for cross-project consumption)"
}

output "public_mysql_server_name" {
  value       = azurerm_mysql_flexible_server.this.name
  description = "MySQL Flexible Server name (for cross-project consumption)"
}

output "public_mysql_server_fqdn" {
  value       = azurerm_mysql_flexible_server.this.fqdn
  description = "MySQL Flexible Server FQDN (for cross-project consumption)"
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
