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
  value       = var.infrastructure_subnet_id != null ? azurerm_container_app_environment.this.docker_bridge_cidr : null
  description = "Docker bridge CIDR (null for non-VNet environments)"
}

output "platform_reserved_cidr" {
  value       = var.infrastructure_subnet_id != null ? azurerm_container_app_environment.this.platform_reserved_cidr : null
  description = "Platform reserved CIDR (null for non-VNet environments)"
}

output "platform_reserved_dns_ip_address" {
  value       = var.infrastructure_subnet_id != null ? azurerm_container_app_environment.this.platform_reserved_dns_ip_address : null
  description = "Platform reserved DNS IP address (null for non-VNet environments)"
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
