# === Standard Outputs ===
output "id" {
  value       = azurerm_eventhub_namespace.this.id
  description = "Event Hub namespace resource ID"
}

output "name" {
  value       = azurerm_eventhub_namespace.this.name
  description = "Event Hub namespace name"
}

# === Resource-Specific Outputs ===
output "namespace_id" {
  value       = azurerm_eventhub_namespace.this.id
  description = "Event Hub namespace resource ID"
}

output "eventhub_ids" {
  value       = { for k, v in azurerm_eventhub.this : k => v.id }
  description = "Map of Event Hub names to their resource IDs"
}

output "consumer_group_ids" {
  value       = { for k, v in azurerm_eventhub_consumer_group.this : k => v.id }
  description = "Map of consumer group keys to their resource IDs"
}

output "authorization_rule_ids" {
  value       = { for k, v in azurerm_eventhub_namespace_authorization_rule.this : k => v.id }
  description = "Map of authorization rule names to their resource IDs"
}

# === Private Endpoint Outputs ===
output "private_endpoint_id" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
  description = "Private endpoint resource ID (when enabled)"
}

output "private_ip_address" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address : null
  description = "Private IP address of the private endpoint (when enabled)"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_namespace_id" {
  value       = azurerm_eventhub_namespace.this.id
  description = "Event Hub namespace resource ID (for cross-project consumption)"
}

output "public_namespace_name" {
  value       = azurerm_eventhub_namespace.this.name
  description = "Event Hub namespace name (for cross-project consumption)"
}
