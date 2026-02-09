# === Standard Outputs ===
output "id" {
  value       = azurerm_mssql_server.this.id
  description = "SQL Server resource ID"
}

output "name" {
  value       = azurerm_mssql_server.this.name
  description = "SQL Server name"
}

# === Resource-Specific Outputs ===
output "fully_qualified_domain_name" {
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
  description = "Fully qualified domain name of the SQL server"
}

output "principal_id" {
  value       = azurerm_mssql_server.this.identity[0].principal_id
  description = "System-assigned managed identity principal ID"
}

output "tenant_id" {
  value       = azurerm_mssql_server.this.identity[0].tenant_id
  description = "System-assigned managed identity tenant ID"
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

# === Public Outputs (Cross-Project Consumption) ===
output "public_sql_server_id" {
  value       = azurerm_mssql_server.this.id
  description = "SQL Server resource ID (for cross-project consumption)"
}

output "public_sql_server_name" {
  value       = azurerm_mssql_server.this.name
  description = "SQL Server name (for cross-project consumption)"
}

output "public_sql_server_fqdn" {
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
  description = "SQL Server FQDN (for cross-project consumption)"
}
