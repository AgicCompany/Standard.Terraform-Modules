# === Standard Outputs ===
output "id" {
  value       = azurerm_servicebus_namespace.this.id
  description = "Service Bus namespace resource ID"
}

output "name" {
  value       = azurerm_servicebus_namespace.this.name
  description = "Service Bus namespace name"
}

# === Resource-Specific Outputs ===
output "endpoint" {
  value       = azurerm_servicebus_namespace.this.endpoint
  description = "Service Bus namespace endpoint"
}

output "queue_ids" {
  value       = { for k, v in azurerm_servicebus_queue.this : k => v.id }
  description = "Map of queue names to their resource IDs"
}

output "topic_ids" {
  value       = { for k, v in azurerm_servicebus_topic.this : k => v.id }
  description = "Map of topic names to their resource IDs"
}

output "subscription_ids" {
  value       = { for k, v in azurerm_servicebus_subscription.this : k => v.id }
  description = "Map of subscription keys (topic/subscription) to their resource IDs"
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
output "public_servicebus_id" {
  value       = azurerm_servicebus_namespace.this.id
  description = "Service Bus namespace resource ID (for cross-project consumption)"
}

output "public_servicebus_name" {
  value       = azurerm_servicebus_namespace.this.name
  description = "Service Bus namespace name (for cross-project consumption)"
}

output "public_servicebus_endpoint" {
  value       = azurerm_servicebus_namespace.this.endpoint
  description = "Service Bus namespace endpoint (for cross-project consumption)"
}
