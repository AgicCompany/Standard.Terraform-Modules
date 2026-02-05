# === Standard Outputs ===
output "id" {
  value       = azurerm_key_vault.this.id
  description = "Key Vault resource ID"
}

output "name" {
  value       = azurerm_key_vault.this.name
  description = "Key Vault name"
}

# === Resource-Specific Outputs ===
output "vault_uri" {
  value       = azurerm_key_vault.this.vault_uri
  description = "Key Vault URI"
}

output "tenant_id" {
  value       = azurerm_key_vault.this.tenant_id
  description = "Azure AD tenant ID"
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
output "public_vault_id" {
  value       = azurerm_key_vault.this.id
  description = "Key Vault resource ID (for cross-project consumption)"
}

output "public_vault_uri" {
  value       = azurerm_key_vault.this.vault_uri
  description = "Key Vault URI (for cross-project consumption)"
}
