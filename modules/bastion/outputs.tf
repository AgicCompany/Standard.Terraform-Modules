# === Standard Outputs ===
output "id" {
  value       = azurerm_bastion_host.this.id
  description = "Bastion host resource ID"
}

output "name" {
  value       = azurerm_bastion_host.this.name
  description = "Bastion host name"
}

# === Resource-Specific Outputs ===
output "dns_name" {
  value       = azurerm_bastion_host.this.dns_name
  description = "FQDN of the Bastion host"
}

output "public_ip_address" {
  value       = azurerm_public_ip.this.ip_address
  description = "Public IP address of the Bastion host"
}

output "public_ip_id" {
  value       = azurerm_public_ip.this.id
  description = "Public IP resource ID"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_bastion_id" {
  value       = azurerm_bastion_host.this.id
  description = "Bastion host resource ID (for cross-project consumption)"
}
