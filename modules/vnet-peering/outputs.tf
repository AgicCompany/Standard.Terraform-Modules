# === Standard Outputs ===
output "id" {
  value       = azurerm_virtual_network_peering.local_to_remote.id
  description = "Local-to-remote peering resource ID"
}

output "name" {
  value       = azurerm_virtual_network_peering.local_to_remote.name
  description = "Local-to-remote peering name"
}

# === Resource-Specific Outputs ===
output "local_to_remote_id" {
  value       = azurerm_virtual_network_peering.local_to_remote.id
  description = "Local-to-remote peering resource ID"
}

output "remote_to_local_id" {
  value       = azurerm_virtual_network_peering.remote_to_local.id
  description = "Remote-to-local peering resource ID"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_peering_id" {
  value       = azurerm_virtual_network_peering.local_to_remote.id
  description = "Local-to-remote peering resource ID (for cross-project consumption)"
}
