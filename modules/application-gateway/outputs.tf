# === Standard Outputs ===
output "id" {
  value       = azurerm_application_gateway.this.id
  description = "Application Gateway resource ID"
}

output "name" {
  value       = azurerm_application_gateway.this.name
  description = "Application Gateway name"
}

# === Resource-Specific Outputs ===
output "public_ip_address" {
  value       = azurerm_public_ip.this.ip_address
  description = "Public IP address of the Application Gateway"
}

output "public_ip_id" {
  value       = azurerm_public_ip.this.id
  description = "Public IP resource ID"
}

output "backend_address_pool_ids" {
  value       = { for pool in azurerm_application_gateway.this.backend_address_pool : pool.name => pool.id }
  description = "Map of backend address pool names to IDs"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_appgw_id" {
  value       = azurerm_application_gateway.this.id
  description = "Application Gateway resource ID (for cross-project consumption)"
}

output "public_appgw_public_ip" {
  value       = azurerm_public_ip.this.ip_address
  description = "Application Gateway public IP (for cross-project consumption)"
}
