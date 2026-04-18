# === Standard Outputs ===
output "id" {
  value       = azurerm_managed_redis.this.id
  description = "Managed Redis resource ID"
}

output "name" {
  value       = azurerm_managed_redis.this.name
  description = "Managed Redis instance name"
}

# === Resource-Specific Outputs ===
output "hostname" {
  value       = azurerm_managed_redis.this.hostname
  description = "Managed Redis hostname"
}

output "port" {
  value       = azurerm_managed_redis.this.default_database[0].port
  description = "Managed Redis default database port"
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
