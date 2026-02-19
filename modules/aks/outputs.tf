# === Standard Outputs ===
output "id" {
  value       = azurerm_kubernetes_cluster.this.id
  description = "AKS cluster resource ID"
}

output "name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "AKS cluster name"
}

# === Resource-Specific Outputs ===
output "kube_config_raw" {
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  description = "Raw kubeconfig (sensitive). For bootstrapping only — prefer Azure AD auth."
  sensitive   = true
}

output "fqdn" {
  value       = azurerm_kubernetes_cluster.this.fqdn
  description = "Cluster FQDN"
}

output "private_fqdn" {
  value       = azurerm_kubernetes_cluster.this.private_fqdn
  description = "Private FQDN of the API server"
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.this.node_resource_group
  description = "Auto-created resource group for cluster infrastructure"
}

output "oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
  description = "OIDC issuer URL (for workload identity federation)"
}

output "principal_id" {
  value       = try(azurerm_kubernetes_cluster.this.identity[0].principal_id, null)
  description = "System-assigned managed identity principal ID (only available with SystemAssigned identity)"
}

output "tenant_id" {
  value       = try(azurerm_kubernetes_cluster.this.identity[0].tenant_id, null)
  description = "System-assigned managed identity tenant ID (only available with SystemAssigned identity)"
}

output "kubelet_identity" {
  value       = try(azurerm_kubernetes_cluster.this.kubelet_identity[0], null)
  description = "Kubelet managed identity (client_id, object_id, user_assigned_identity_id)"
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_aks_id" {
  value       = azurerm_kubernetes_cluster.this.id
  description = "AKS cluster resource ID (for cross-project consumption)"
}

output "public_aks_name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "AKS cluster name (for cross-project consumption)"
}
