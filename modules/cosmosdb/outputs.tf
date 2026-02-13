# === Standard Outputs ===
output "id" {
  value       = azurerm_cosmosdb_account.this.id
  description = "Cosmos DB account resource ID"
}

output "name" {
  value       = azurerm_cosmosdb_account.this.name
  description = "Cosmos DB account name"
}

# === Resource-Specific Outputs ===
output "endpoint" {
  value       = azurerm_cosmosdb_account.this.endpoint
  description = "Cosmos DB account endpoint URL"
}

output "database_ids" {
  value       = { for k, v in azurerm_cosmosdb_sql_database.this : k => v.id }
  description = "Map of database names to database resource IDs"
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
output "public_cosmosdb_id" {
  value       = azurerm_cosmosdb_account.this.id
  description = "Cosmos DB account resource ID (for cross-project consumption)"
}

output "public_cosmosdb_name" {
  value       = azurerm_cosmosdb_account.this.name
  description = "Cosmos DB account name (for cross-project consumption)"
}

output "public_cosmosdb_endpoint" {
  value       = azurerm_cosmosdb_account.this.endpoint
  description = "Cosmos DB account endpoint (for cross-project consumption)"
}
