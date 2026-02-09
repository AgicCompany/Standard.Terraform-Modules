# === Standard Outputs ===
output "id" {
  value       = azurerm_container_app_environment.this.id
  description = "Container Apps Environment resource ID"
}

output "name" {
  value       = azurerm_container_app_environment.this.name
  description = "Container Apps Environment name"
}

# === Resource-Specific Outputs ===
output "default_domain" {
  value       = azurerm_container_app_environment.this.default_domain
  description = "Default domain of the environment"
}

output "static_ip_address" {
  value       = azurerm_container_app_environment.this.static_ip_address
  description = "Static IP address of the environment"
}

output "docker_bridge_cidr" {
  value       = azurerm_container_app_environment.this.docker_bridge_cidr
  description = "Docker bridge CIDR"
}

output "platform_reserved_cidr" {
  value       = azurerm_container_app_environment.this.platform_reserved_cidr
  description = "Platform reserved CIDR"
}

output "platform_reserved_dns_ip_address" {
  value       = azurerm_container_app_environment.this.platform_reserved_dns_ip_address
  description = "Platform reserved DNS IP address"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_container_app_environment_id" {
  value       = azurerm_container_app_environment.this.id
  description = "Container Apps Environment resource ID (for cross-project consumption)"
}

output "public_container_app_environment_default_domain" {
  value       = azurerm_container_app_environment.this.default_domain
  description = "Default domain of the environment (for cross-project consumption)"
}
