# aks-node-pool

**Complexity:** Low

Creates additional (user) node pools for an existing AKS cluster. This module is a companion to the `aks` module and manages node pools as separate resources using `for_each`, allowing independent lifecycle management without affecting the cluster or its default system pool.

## Usage

```hcl
module "aks_node_pool" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//aks-node-pool?ref=aks-node-pool/v1.0.0"

  kubernetes_cluster_id = module.aks.id

  node_pools = {
    workload = {
      vm_size   = "Standard_D4s_v3"
      min_count = 2
      max_count = 10
    }
  }
}
```

## Features

- `for_each`-based node pool creation from a single map variable
- Autoscaling support (enabled by default, with configurable min/max counts)
- Spot instance support with configurable eviction policy and max price
- Windows node pool support (`os_type = "Windows"`)
- Upgrade settings (max surge, drain timeout, node soak duration)
- Availability zone configuration (defaults to zones 1, 2, 3)
- Node labels and taints for scheduling control
- Ultra SSD and host encryption support
- FIPS-enabled node pool support
- Per-pool subnet placement for flat Azure CNI topologies
- Scale-down mode selection (Delete or Deallocate)
- Orchestrator version pinning per pool
- Validated inputs for mode, priority, os_type, and scale_down_mode

## Examples

- [basic](./examples/basic) -- single worker pool with autoscaling
- [complete](./examples/complete) -- multiple pools including GPU and Spot instances with labels, taints, and custom subnets

## Notes

- **Node pool names:** Each key in the `node_pools` map becomes the Azure node pool name. AKS node pool names must be 1-12 characters, lowercase alphanumeric only (no hyphens or underscores).
- **Autoscaling vs. fixed count:** When `auto_scaling_enabled = true` (the default), `min_count` and `max_count` control the pool size. When disabled, `node_count` sets a fixed number of nodes.
- **Spot instances:** Set `priority = "Spot"` to use Spot VMs. The `eviction_policy` (Delete or Deallocate) and `spot_max_price` fields only apply when priority is Spot. Use `spot_max_price = -1` to accept on-demand pricing as the maximum.
- **AzureLinux as default OS:** `os_sku = "AzureLinux"` is Microsoft's recommended Linux distribution for AKS. The `os_sku` field is automatically set to `null` for Windows pools.
- **Subnet per pool:** With flat Azure CNI, each node pool can target its own subnet via `vnet_subnet_id`. With CNI Overlay, all pools share the cluster subnet.
- **Upgrade settings:** Defaults to 33% max surge, 30-minute drain timeout, and no node soak. Adjust for production workloads that need graceful rolling upgrades.
- **`temporary_name_for_rotation`:** Set this when changes to the node pool force recreation (e.g., changing `vm_size`). AKS creates a temporary pool, migrates workloads, then replaces the original.
- **Separate lifecycle:** Because node pools are managed as individual `azurerm_kubernetes_cluster_node_pool` resources, adding or removing a pool does not trigger changes to the cluster or other pools.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster_node_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#input\_kubernetes\_cluster\_id) | Resource ID of the AKS cluster to attach node pools to | `string` | n/a | yes |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Map of node pool configurations. Each key becomes the node pool name. | <pre>map(object({<br/>    vm_size                     = optional(string, "Standard_D2s_v3")<br/>    node_count                  = optional(number, 3)<br/>    auto_scaling_enabled        = optional(bool, true)<br/>    min_count                   = optional(number, 1)<br/>    max_count                   = optional(number, 5)<br/>    mode                        = optional(string, "User")<br/>    os_type                     = optional(string, "Linux")<br/>    os_sku                      = optional(string, "AzureLinux")<br/>    os_disk_size_gb             = optional(number, 128)<br/>    os_disk_type                = optional(string, "Managed")<br/>    vnet_subnet_id              = optional(string)<br/>    zones                       = optional(list(string), ["1", "2", "3"])<br/>    max_pods                    = optional(number, 30)<br/>    node_labels                 = optional(map(string), {})<br/>    node_taints                 = optional(list(string), [])<br/>    priority                    = optional(string, "Regular")<br/>    eviction_policy             = optional(string)<br/>    spot_max_price              = optional(number)<br/>    scale_down_mode             = optional(string, "Delete")<br/>    temporary_name_for_rotation = optional(string)<br/>    orchestrator_version        = optional(string)<br/>    ultra_ssd_enabled           = optional(bool, false)<br/>    host_encryption_enabled     = optional(bool, false)<br/>    fips_enabled                = optional(bool, false)<br/>    upgrade_settings = optional(object({<br/>      max_surge                     = optional(string, "33%")<br/>      drain_timeout_in_minutes      = optional(number, 30)<br/>      node_soak_duration_in_minutes = optional(number, 0)<br/>    }), {})<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_pool_ids"></a> [node\_pool\_ids](#output\_node\_pool\_ids) | Map of node pool names to resource IDs |
| <a name="output_node_pool_names"></a> [node\_pool\_names](#output\_node\_pool\_names) | Map of node pool keys to Azure node pool names |
<!-- END_TF_DOCS -->