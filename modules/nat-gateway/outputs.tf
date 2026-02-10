# === Standard Outputs ===
output "id" {
  value       = azurerm_nat_gateway.this.id
  description = "NAT gateway resource ID"
}

output "name" {
  value       = azurerm_nat_gateway.this.name
  description = "NAT gateway name"
}

# === Resource-Specific Outputs ===
output "public_ip_address" {
  value       = azurerm_public_ip.this.ip_address
  description = "Public IP address of the NAT gateway"
}

output "public_ip_id" {
  value       = azurerm_public_ip.this.id
  description = "Public IP resource ID"
}

output "resource_guid" {
  value       = azurerm_nat_gateway.this.resource_guid
  description = "NAT gateway resource GUID"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_nat_gateway_id" {
  value       = azurerm_nat_gateway.this.id
  description = "NAT gateway resource ID (for cross-project consumption)"
}
