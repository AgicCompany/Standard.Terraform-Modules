# === Standard Outputs ===
output "id" {
  value       = azurerm_user_assigned_identity.this.id
  description = "User-assigned identity resource ID"
}

output "name" {
  value       = azurerm_user_assigned_identity.this.name
  description = "User-assigned identity name"
}

# === Resource-Specific Outputs ===
output "principal_id" {
  value       = azurerm_user_assigned_identity.this.principal_id
  description = "Service principal ID associated with the identity"
}

output "client_id" {
  value       = azurerm_user_assigned_identity.this.client_id
  description = "Client ID associated with the identity"
}

output "tenant_id" {
  value       = azurerm_user_assigned_identity.this.tenant_id
  description = "Tenant ID associated with the identity"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_identity_id" {
  value       = azurerm_user_assigned_identity.this.id
  description = "User-assigned identity resource ID (for cross-project consumption)"
}

output "public_principal_id" {
  value       = azurerm_user_assigned_identity.this.principal_id
  description = "Service principal ID (for cross-project consumption)"
}

output "public_client_id" {
  value       = azurerm_user_assigned_identity.this.client_id
  description = "Client ID (for cross-project consumption)"
}
