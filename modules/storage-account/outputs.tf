# === Standard Outputs ===
output "id" {
  value       = azurerm_storage_account.this.id
  description = "Storage account resource ID"
}

output "name" {
  value       = azurerm_storage_account.this.name
  description = "Storage account name"
}

# === Resource-Specific Outputs ===
output "primary_blob_endpoint" {
  value       = azurerm_storage_account.this.primary_blob_endpoint
  description = "Primary blob endpoint URL"
}

output "primary_file_endpoint" {
  value       = azurerm_storage_account.this.primary_file_endpoint
  description = "Primary file endpoint URL"
}

output "primary_table_endpoint" {
  value       = azurerm_storage_account.this.primary_table_endpoint
  description = "Primary table endpoint URL"
}

output "primary_queue_endpoint" {
  value       = azurerm_storage_account.this.primary_queue_endpoint
  description = "Primary queue endpoint URL"
}

output "primary_location" {
  value       = azurerm_storage_account.this.primary_location
  description = "Primary location of the storage account"
}

# === Private Endpoint Outputs ===
output "private_endpoint_ids" {
  value = {
    for k, v in azurerm_private_endpoint.this : k => v.id
  }
  description = "Map of subresource name to private endpoint ID"
}

output "private_ip_addresses" {
  value = {
    for k, v in azurerm_private_endpoint.this : k => v.private_service_connection[0].private_ip_address
  }
  description = "Map of subresource name to private IP address"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_storage_account_id" {
  value       = azurerm_storage_account.this.id
  description = "Storage account resource ID (for cross-project consumption)"
}

output "public_storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "Storage account name (for cross-project consumption)"
}

output "public_primary_blob_endpoint" {
  value       = azurerm_storage_account.this.primary_blob_endpoint
  description = "Primary blob endpoint URL (for cross-project consumption)"
}
