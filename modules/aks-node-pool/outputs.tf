output "node_pool_ids" {
  value       = { for k, v in azurerm_kubernetes_cluster_node_pool.this : k => v.id }
  description = "Map of node pool names to resource IDs"
}

output "node_pool_names" {
  value       = { for k, v in azurerm_kubernetes_cluster_node_pool.this : k => v.name }
  description = "Map of node pool keys to Azure node pool names"
}
