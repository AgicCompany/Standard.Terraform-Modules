# === Standard Outputs ===
output "id" {
  value       = azurerm_redis_cache.this.id
  description = "Redis Cache resource ID"
}

output "name" {
  value       = azurerm_redis_cache.this.name
  description = "Redis Cache name"
}

# === Resource-Specific Outputs ===
output "hostname" {
  value       = azurerm_redis_cache.this.hostname
  description = "Redis Cache hostname"
}

output "ssl_port" {
  value       = azurerm_redis_cache.this.ssl_port
  description = "Redis Cache SSL port"
}

output "port" {
  value       = azurerm_redis_cache.this.port
  description = "Redis Cache non-SSL port"
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
output "public_redis_id" {
  value       = azurerm_redis_cache.this.id
  description = "Redis Cache resource ID (for cross-project consumption)"
}

output "public_redis_name" {
  value       = azurerm_redis_cache.this.name
  description = "Redis Cache name (for cross-project consumption)"
}

output "public_redis_hostname" {
  value       = azurerm_redis_cache.this.hostname
  description = "Redis Cache hostname (for cross-project consumption)"
}
