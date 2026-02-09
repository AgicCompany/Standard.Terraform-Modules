# === Standard Outputs ===
output "id" {
  value       = azurerm_mssql_database.this.id
  description = "SQL Database resource ID"
}

output "name" {
  value       = azurerm_mssql_database.this.name
  description = "SQL Database name"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_database_id" {
  value       = azurerm_mssql_database.this.id
  description = "SQL Database resource ID (for cross-project consumption)"
}

output "public_database_name" {
  value       = azurerm_mssql_database.this.name
  description = "SQL Database name (for cross-project consumption)"
}
