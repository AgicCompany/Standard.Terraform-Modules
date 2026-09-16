# === Standard Outputs ===
output "id" {
  value       = azurerm_mssql_managed_instance.this.id
  description = "SQL Managed Instance resource ID"
}

output "name" {
  value       = azurerm_mssql_managed_instance.this.name
  description = "SQL Managed Instance name"
}

# === Resource-Specific Outputs ===
output "fqdn" {
  value       = azurerm_mssql_managed_instance.this.fqdn
  description = "Fully qualified domain name of the instance (VNet-local endpoint)"
}

output "dns_zone" {
  value       = azurerm_mssql_managed_instance.this.dns_zone
  description = "DNS zone of the instance; pass as dns_zone_partner_id when creating a failover-group secondary"
}

output "principal_id" {
  value       = try(azurerm_mssql_managed_instance.this.identity[0].principal_id, null)
  description = "System-assigned managed identity principal ID (null when only user-assigned)"
}

output "tenant_id" {
  value       = try(azurerm_mssql_managed_instance.this.identity[0].tenant_id, null)
  description = "System-assigned managed identity tenant ID (null when only user-assigned)"
}

output "transparent_data_encryption_id" {
  value       = azurerm_mssql_managed_instance_transparent_data_encryption.this.id
  description = "TDE encryption protector resource ID"
}

output "security_alert_policy_id" {
  value       = var.enable_security_alert_policy ? azurerm_mssql_managed_instance_security_alert_policy.this[0].id : null
  description = "Security alert policy resource ID (when enabled)"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_managed_instance_id" {
  value       = azurerm_mssql_managed_instance.this.id
  description = "SQL Managed Instance resource ID (for cross-project consumption)"
}

output "public_managed_instance_name" {
  value       = azurerm_mssql_managed_instance.this.name
  description = "SQL Managed Instance name (for cross-project consumption)"
}

output "public_managed_instance_fqdn" {
  value       = azurerm_mssql_managed_instance.this.fqdn
  description = "SQL Managed Instance FQDN (for cross-project consumption)"
}
