# === Standard Outputs ===
output "id" {
  value       = azurerm_cdn_frontdoor_profile.this.id
  description = "Front Door profile resource ID"
}

output "name" {
  value       = azurerm_cdn_frontdoor_profile.this.name
  description = "Front Door profile name"
}

# === Resource-Specific Outputs ===
output "resource_guid" {
  value       = azurerm_cdn_frontdoor_profile.this.resource_guid
  description = "Front Door profile resource GUID"
}

output "endpoint_ids" {
  value       = { for k, v in azurerm_cdn_frontdoor_endpoint.this : k => v.id }
  description = "Map of endpoint names to their resource IDs"
}

output "endpoint_host_names" {
  value       = { for k, v in azurerm_cdn_frontdoor_endpoint.this : k => v.host_name }
  description = "Map of endpoint names to their host names"
}

output "origin_group_ids" {
  value       = { for k, v in azurerm_cdn_frontdoor_origin_group.this : k => v.id }
  description = "Map of origin group names to their resource IDs"
}

output "origin_ids" {
  value       = { for k, v in azurerm_cdn_frontdoor_origin.this : k => v.id }
  description = "Map of origin names to their resource IDs"
}

output "route_ids" {
  value       = { for k, v in azurerm_cdn_frontdoor_route.this : k => v.id }
  description = "Map of route names to their resource IDs"
}

output "custom_domain_ids" {
  value       = { for k, v in azurerm_cdn_frontdoor_custom_domain.this : k => v.id }
  description = "Map of custom domain keys to their resource IDs"
}

output "custom_domain_validation_tokens" {
  value       = { for k, v in azurerm_cdn_frontdoor_custom_domain.this : k => v.validation_token }
  description = "Map of custom domain keys to their DNS validation tokens"
}

output "firewall_policy_id" {
  value       = var.waf != null ? azurerm_cdn_frontdoor_firewall_policy.this[0].id : null
  description = "WAF firewall policy resource ID (null if WAF disabled)"
}

output "rule_set_ids" {
  value       = { for k, v in azurerm_cdn_frontdoor_rule_set.this : k => v.id }
  description = "Map of rule set keys to their resource IDs"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_frontdoor_id" {
  value       = azurerm_cdn_frontdoor_profile.this.id
  description = "Front Door profile resource ID (for cross-project consumption)"
}

output "public_frontdoor_name" {
  value       = azurerm_cdn_frontdoor_profile.this.name
  description = "Front Door profile name (for cross-project consumption)"
}

output "public_frontdoor_endpoint_host_names" {
  value       = { for k, v in azurerm_cdn_frontdoor_endpoint.this : k => v.host_name }
  description = "Map of endpoint host names (for cross-project consumption)"
}
