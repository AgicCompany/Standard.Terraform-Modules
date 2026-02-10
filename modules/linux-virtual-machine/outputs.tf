# === Standard Outputs ===
output "id" {
  value       = azurerm_linux_virtual_machine.this.id
  description = "Virtual machine resource ID"
}

output "name" {
  value       = azurerm_linux_virtual_machine.this.name
  description = "Virtual machine name"
}

# === Resource-Specific Outputs ===
output "private_ip_address" {
  value       = azurerm_network_interface.this.private_ip_address
  description = "Private IP address of the network interface"
}

output "network_interface_id" {
  value       = azurerm_network_interface.this.id
  description = "Network interface resource ID"
}

output "principal_id" {
  value       = var.enable_system_assigned_identity ? azurerm_linux_virtual_machine.this.identity[0].principal_id : null
  description = "System-assigned managed identity principal ID (when enabled)"
}

output "tenant_id" {
  value       = var.enable_system_assigned_identity ? azurerm_linux_virtual_machine.this.identity[0].tenant_id : null
  description = "System-assigned managed identity tenant ID (when enabled)"
}

output "public_ip_address" {
  value       = var.enable_public_ip ? azurerm_public_ip.this[0].ip_address : null
  description = "Public IP address (when enabled)"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_vm_id" {
  value       = azurerm_linux_virtual_machine.this.id
  description = "Virtual machine resource ID (for cross-project consumption)"
}

output "public_vm_name" {
  value       = azurerm_linux_virtual_machine.this.name
  description = "Virtual machine name (for cross-project consumption)"
}

output "public_vm_private_ip" {
  value       = azurerm_network_interface.this.private_ip_address
  description = "Private IP address (for cross-project consumption)"
}
