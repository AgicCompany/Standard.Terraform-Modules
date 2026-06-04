# === Standard Outputs ===
output "id" {
  value       = local.job.id
  description = "Container App Job resource ID"
}

output "name" {
  value       = local.job.name
  description = "Container App Job name"
}

# === Resource-Specific Outputs ===
output "outbound_ip_addresses" {
  value       = local.job.outbound_ip_addresses
  description = "Outbound IP addresses of the Container App Job"
}

output "event_stream_endpoint" {
  value       = local.job.event_stream_endpoint
  description = "Event stream endpoint for log streaming"
}

output "principal_id" {
  value       = try(local.job.identity[0].principal_id, null)
  description = "System-assigned managed identity principal ID (when enabled)"
}

output "tenant_id" {
  value       = try(local.job.identity[0].tenant_id, null)
  description = "System-assigned managed identity tenant ID (when enabled)"
}
