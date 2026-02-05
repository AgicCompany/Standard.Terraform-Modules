# === Standard Outputs ===
output "id" {
  value       = azurerm_virtual_network.this.id
  description = "Virtual network resource ID"
}

output "name" {
  value       = azurerm_virtual_network.this.name
  description = "Virtual network name"
}

# === Resource-Specific Outputs ===
output "address_space" {
  value       = azurerm_virtual_network.this.address_space
  description = "Virtual network address space"
}

output "subnet_ids" {
  value = {
    for k, v in azurerm_subnet.this : k => v.id
  }
  description = "Map of subnet name to subnet ID"
}

output "subnet_address_prefixes" {
  value = {
    for k, v in azurerm_subnet.this : k => v.address_prefixes
  }
  description = "Map of subnet name to address prefixes"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "Virtual network resource ID (for cross-project consumption)"
}

output "public_vnet_name" {
  value       = azurerm_virtual_network.this.name
  description = "Virtual network name (for cross-project consumption)"
}

output "public_subnet_ids" {
  value = {
    for k, v in azurerm_subnet.this : k => v.id
  }
  description = "Map of subnet name to subnet ID (for cross-project consumption)"
}
