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

# === Identity Outputs ===
output "identity" {
  value = var.identity == null ? null : {
    type         = azurerm_storage_account.this.identity[0].type
    principal_id = azurerm_storage_account.this.identity[0].principal_id
    tenant_id    = azurerm_storage_account.this.identity[0].tenant_id
    identity_ids = azurerm_storage_account.this.identity[0].identity_ids
  }
  description = "Managed identity of the storage account, or null when no identity is configured. principal_id and tenant_id are populated only for types that include SystemAssigned. The storage account exposes no client_id for user-assigned identities -- read that from the azurerm_user_assigned_identity resource."
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
