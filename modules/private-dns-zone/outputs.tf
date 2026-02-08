# === Standard Outputs ===
output "id" {
  value       = azurerm_private_dns_zone.this.id
  description = "Private DNS zone resource ID"
}

output "name" {
  value       = azurerm_private_dns_zone.this.name
  description = "Private DNS zone name"
}

# === Resource-Specific Outputs ===
output "virtual_network_link_ids" {
  value = {
    for k, v in azurerm_private_dns_zone_virtual_network_link.this : k => v.id
  }
  description = "Map of link name to virtual network link resource ID"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_dns_zone_id" {
  value       = azurerm_private_dns_zone.this.id
  description = "Private DNS zone resource ID (for cross-project consumption)"
}
