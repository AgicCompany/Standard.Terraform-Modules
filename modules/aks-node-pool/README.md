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