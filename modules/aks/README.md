# aks

**Complexity:** High

Creates an Azure Kubernetes Service (AKS) cluster with private-by-default configuration, Azure AD authentication, Azure RBAC authorization, and Container Insights.

## Usage

```hcl
module "aks" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//aks?ref=aks/v1.5.0"

  resource_group_name = "rg-aks-dev-weu-001"
  location            = "westeurope"
  name                = "aks-payments-dev-weu-001"

  default_node_pool = {
    vnet_subnet_id = module.vnet.subnet_ids["snet-aks-nodes"]
  }

  admin_group_object_ids     = [data.azuread_group.aks_admins.object_id]
  log_analytics_workspace_id = module.law.id

  tags = local.common_tags
}
```

## Features

- Private cluster (always enabled — no public API server)
- Default (system) node pool with autoscaling
- Azure CNI Overlay networking (default) with flat CNI available
- Flexible identity: system-assigned (default), user-assigned, or both
- Azure AD authentication (always enabled, local accounts disabled)
- Azure RBAC for Kubernetes authorization (default, configurable via `rbac_mode`)
- Admin group support for cluster admin access
- Container Insights via Log Analytics workspace
- Configurable Kubernetes version and upgrade channel
- SKU tier selection (Free, Standard, Premium)
- Authorized IP ranges for controlled API server access
- Custom node resource group naming

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override |
|---------|---------|---------|
| Private cluster | Enabled (hardcoded) | `authorized_ip_ranges` to allow specific IPs |
| Local accounts | Disabled (hardcoded) | None — Azure AD only |
| Azure RBAC authorization | Enabled | `rbac_mode` to switch to Kubernetes RBAC |
| OIDC issuer | Enabled (always on) | — |
| Container Insights | Enabled | `enable_container_insights` |
| Autoscaling | Enabled | `enable_auto_scaling` |

## Private Cluster

The cluster is **always private** (`private_cluster_enabled = true`). There is no toggle.

Access to the private API server is controlled by `authorized_ip_ranges`:

| `authorized_ip_ranges` value | Behavior |
|------------------------------|----------|
| Not provided (empty) | Fully private. API server only reachable from within the VNet. |
| One or more CIDRs | Private cluster with specific public IPs allowed to reach the API server. |

## Container Registry Integration

The AKS module does not manage container registry role assignments. ACR integration is the consumer's responsibility at the project level. Use the `kubelet_identity` output to assign the `AcrPull` role:

```hcl
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity.object_id
}
```

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_aks_id` | AKS cluster resource ID |
| `public_aks_name` | AKS cluster name |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | Azure AD group object IDs for cluster admin access. | `list(string)` | `[]` | no |
| <a name="input_authorized_ip_ranges"></a> [authorized\_ip\_ranges](#input\_authorized\_ip\_ranges) | Public IP CIDRs allowed to reach the API server. Empty = fully private. | `list(string)` | `[]` | no |
| <a name="input_auto_scaler_profile"></a> [auto\_scaler\_profile](#input\_auto\_scaler\_profile) | Cluster autoscaler profile. When null, Azure defaults apply. | <pre>object({<br/>    balance_similar_node_groups      = optional(bool)<br/>    empty_bulk_delete_max            = optional(number)<br/>    expander                         = optional(string)<br/>    max_graceful_termination_sec     = optional(number)<br/>    max_node_provisioning_time       = optional(string)<br/>    max_unready_nodes                = optional(number)<br/>    max_unready_percentage           = optional(number)<br/>    new_pod_scale_up_delay           = optional(string)<br/>    scale_down_delay_after_add       = optional(string)<br/>    scale_down_delay_after_delete    = optional(string)<br/>    scale_down_delay_after_failure   = optional(string)<br/>    scale_down_unneeded              = optional(string)<br/>    scale_down_unready               = optional(string)<br/>    scale_down_utilization_threshold = optional(string)<br/>    scan_interval                    = optional(string)<br/>    skip_nodes_with_local_storage    = optional(bool)<br/>    skip_nodes_with_system_pods      = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_automatic_upgrade_channel"></a> [automatic\_upgrade\_channel](#input\_automatic\_upgrade\_channel) | Auto-upgrade channel: none, patch, stable, rapid, or node-image. | `string` | `"none"` | no |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Default (system) node pool configuration. | <pre>object({<br/>    vm_size                     = optional(string, "Standard_D2s_v3")<br/>    vnet_subnet_id              = optional(string)<br/>    node_count                  = optional(number, 3)<br/>    min_count                   = optional(number, 1)<br/>    max_count                   = optional(number, 5)<br/>    os_disk_size_gb             = optional(number, 128)<br/>    os_disk_type                = optional(string, "Managed")<br/>    os_sku                      = optional(string, "AzureLinux")<br/>    zones                       = optional(list(string), ["1", "2", "3"])<br/>    max_pods                    = optional(number, 30)<br/>    temporary_name_for_rotation = optional(string, "tmpnodepool")<br/>    upgrade_settings = optional(object({<br/>      max_surge                     = optional(string, "33%")<br/>      drain_timeout_in_minutes      = optional(number, 30)<br/>      node_soak_duration_in_minutes = optional(number, 0)<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_dns_prefix"></a> [dns\_prefix](#input\_dns\_prefix) | DNS prefix for the cluster. When null, defaults to the name variable. | `string` | `null` | no |
| <a name="input_enable_auto_scaling"></a> [enable\_auto\_scaling](#input\_enable\_auto\_scaling) | Enable cluster autoscaler on the default node pool | `bool` | `true` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Enable Container Insights via Log Analytics | `bool` | `true` | no |
| <a name="input_enable_system_assigned_identity"></a> [enable\_system\_assigned\_identity](#input\_enable\_system\_assigned\_identity) | Enable system-assigned managed identity (default: true) | `bool` | `true` | no |
| <a name="input_key_vault_secrets_provider"></a> [key\_vault\_secrets\_provider](#input\_key\_vault\_secrets\_provider) | Key Vault CSI driver configuration. When null, the add-on is disabled. | <pre>object({<br/>    secret_rotation_enabled  = optional(bool, false)<br/>    secret_rotation_interval = optional(string, "2m")<br/>  })</pre> | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version. null = latest stable version available in the region. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID. Required when enable\_container\_insights = true. | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | General maintenance window. Defaults to Saturday+Sunday 00:00-06:00 UTC. Set to null to let Azure schedule at its discretion. | <pre>object({<br/>    allowed = list(object({<br/>      day   = string<br/>      hours = list(number)<br/>    }))<br/>    not_allowed = optional(list(object({<br/>      start = string<br/>      end   = string<br/>    })))<br/>  })</pre> | <pre>{<br/>  "allowed": [<br/>    {<br/>      "day": "Saturday",<br/>      "hours": [<br/>        0,<br/>        1,<br/>        2,<br/>        3,<br/>        4,<br/>        5<br/>      ]<br/>    },<br/>    {<br/>      "day": "Sunday",<br/>      "hours": [<br/>        0,<br/>        1,<br/>        2,<br/>        3,<br/>        4,<br/>        5<br/>      ]<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_maintenance_window_auto_upgrade"></a> [maintenance\_window\_auto\_upgrade](#input\_maintenance\_window\_auto\_upgrade) | Auto-upgrade maintenance window. Defaults to Weekly Sunday 02:00 UTC, 4h duration. Set to null to disable. | <pre>object({<br/>    frequency    = string<br/>    interval     = number<br/>    duration     = number<br/>    day_of_week  = optional(string)<br/>    day_of_month = optional(number)<br/>    week_index   = optional(string)<br/>    start_time   = optional(string)<br/>    utc_offset   = optional(string, "+00:00")<br/>    start_date   = optional(string)<br/>    not_allowed = optional(list(object({<br/>      start = string<br/>      end   = string<br/>    })))<br/>  })</pre> | <pre>{<br/>  "day_of_week": "Sunday",<br/>  "duration": 4,<br/>  "frequency": "Weekly",<br/>  "interval": 1,<br/>  "start_time": "02:00"<br/>}</pre> | no |
| <a name="input_maintenance_window_node_os"></a> [maintenance\_window\_node\_os](#input\_maintenance\_window\_node\_os) | Node OS upgrade maintenance window. Defaults to Weekly Saturday 02:00 UTC, 4h duration. Set to null to disable. | <pre>object({<br/>    frequency    = string<br/>    interval     = number<br/>    duration     = number<br/>    day_of_week  = optional(string)<br/>    day_of_month = optional(number)<br/>    week_index   = optional(string)<br/>    start_time   = optional(string)<br/>    utc_offset   = optional(string, "+00:00")<br/>    start_date   = optional(string)<br/>    not_allowed = optional(list(object({<br/>      start = string<br/>      end   = string<br/>    })))<br/>  })</pre> | <pre>{<br/>  "day_of_week": "Saturday",<br/>  "duration": 4,<br/>  "frequency": "Weekly",<br/>  "interval": 1,<br/>  "start_time": "02:00"<br/>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | AKS cluster name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_network_profile"></a> [network\_profile](#input\_network\_profile) | Network configuration. Defaults to Azure CNI Overlay. The load\_balancer\_profile sub-block configures outbound traffic. The outbound source fields (managed\_outbound\_ip\_count, outbound\_ip\_address\_ids, outbound\_ip\_prefix\_ids) are mutually exclusive. | <pre>object({<br/>    network_plugin      = optional(string, "azure")<br/>    network_plugin_mode = optional(string, "overlay")<br/>    network_policy      = optional(string, "azure")<br/>    pod_cidr            = optional(string, "10.244.0.0/16")<br/>    service_cidr        = optional(string, "10.0.0.0/16")<br/>    dns_service_ip      = optional(string, "10.0.0.10")<br/>    outbound_type       = optional(string, "loadBalancer")<br/>    load_balancer_profile = optional(object({<br/>      managed_outbound_ip_count = optional(number)<br/>      outbound_ip_address_ids   = optional(list(string))<br/>      outbound_ip_prefix_ids    = optional(list(string))<br/>      outbound_ports_allocated  = optional(number, 0)<br/>      idle_timeout_in_minutes   = optional(number, 30)<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_node_resource_group_name"></a> [node\_resource\_group\_name](#input\_node\_resource\_group\_name) | Custom name for the auto-created node resource group. When null, Azure generates MC\_<rg>\_<cluster>\_<region>. | `string` | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone resource ID, "System", or "None". Only applies to private clusters (when authorized\_ip\_ranges is empty). | `string` | `null` | no |
| <a name="input_rbac_mode"></a> [rbac\_mode](#input\_rbac\_mode) | Authorization mode: 'azure' (Azure RBAC) or 'kubernetes' (Kubernetes RBAC). Azure AD authentication is always enabled regardless of mode. | `string` | `"azure"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU tier: Free, Standard (includes Uptime SLA), or Premium. | `string` | `"Free"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | List of user-assigned managed identity IDs | `list(string)` | `[]` | no |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Enable workload identity for pod-to-Azure-service authentication | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | Cluster FQDN |
| <a name="output_id"></a> [id](#output\_id) | AKS cluster resource ID |
| <a name="output_kube_config_raw"></a> [kube\_config\_raw](#output\_kube\_config\_raw) | Raw kubeconfig (sensitive). For bootstrapping only — prefer Azure AD auth. |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | Kubelet managed identity (client\_id, object\_id, user\_assigned\_identity\_id) |
| <a name="output_name"></a> [name](#output\_name) | AKS cluster name |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | Auto-created resource group for cluster infrastructure |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | OIDC issuer URL (for workload identity federation) |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID (only available with SystemAssigned identity) |
| <a name="output_private_fqdn"></a> [private\_fqdn](#output\_private\_fqdn) | Private FQDN of the API server (null for public clusters) |
| <a name="output_public_aks_id"></a> [public\_aks\_id](#output\_public\_aks\_id) | AKS cluster resource ID (for cross-project consumption) |
| <a name="output_public_aks_name"></a> [public\_aks\_name](#output\_public\_aks\_name) | AKS cluster name (for cross-project consumption) |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned managed identity tenant ID (only available with SystemAssigned identity) |
<!-- END_TF_DOCS -->

## Notes

- **AzureRM 4.x: Stable API only.** All preview feature properties were removed from the `azurerm_kubernetes_cluster` resource. If a consumer needs preview features, they must use the `azapi` provider alongside this module.
- **Private cluster is always on.** Unlike other modules with `enable_private_endpoint`, AKS uses `private_cluster_enabled` instead of Private Link. Making a public cluster private later requires cluster recreation. The `authorized_ip_ranges` variable is the escape hatch for development access.
- **Azure RBAC for Kubernetes (default).** Authorization is handled entirely through Azure IAM. This is simpler to manage and stays within Terraform's natural reach. Kubernetes RBAC authorization is available since v1.1.0 via the `rbac_mode` variable to support multi-tenant clusters.
- **DNS prefix:** Defaults to the `name` variable via `coalesce(var.dns_prefix, var.name)` in locals. Most consumers never need to set this. Override only when the cluster name does not meet DNS prefix requirements or a specific prefix is needed.
- **`kubernetes_version = null`:** When `null`, Azure selects the latest stable version. This is convenient but means Terraform may detect drift when Azure releases new versions. For production, pin to a specific version (e.g., `"1.29"`).
- **Node pool name:** The default node pool is always named `"system"`. This is hardcoded. Additional pools use a separate `aks-node-pool` module (future).
- **Node resource group:** Azure auto-creates a resource group (default: `MC_<rg>_<cluster>_<region>`) for cluster infrastructure. The `node_resource_group_name` variable allows overriding this name. Once set, it cannot be changed without recreating the cluster.
- **AzureLinux as default OS:** `os_sku = "AzureLinux"` is Microsoft's recommended Linux distribution for AKS. Override to `"Ubuntu"` if needed.
- **`temporary_name_for_rotation`:** Required when changes to the default node pool force recreation (e.g., changing `vm_size`). AKS creates a temporary pool, migrates workloads, then replaces the original.
- **Naming:** CAF prefix for AKS is `aks`. Example: `aks-payments-dev-weu-001`.
- **`kube_config_raw` output:** Marked as sensitive. For initial bootstrapping only — use `az aks get-credentials` with Azure AD auth for day-to-day access.
- **OIDC issuer URL:** Output for workload identity configuration, available since v1.1.0 via the `workload_identity_enabled` variable.
- **Why CNI Overlay as default:** The framework is private-first — workloads communicate via private endpoints, internal load balancers, and ingress controllers, not direct pod-to-VNet routing. Overlay conserves VNet IPs, scales better, and is Microsoft's recommended path forward. Flat CNI is available by setting `network_plugin_mode = null`.
- **Subnet sizing:** With CNI Overlay (default), only nodes consume subnet IPs. With flat CNI, each node and each pod consumes a subnet IP — size subnets accordingly.
- **Subnet per node pool:** With flat Azure CNI, each node pool can use its own subnet. With CNI Overlay, all node pools share the same subnet. This is why `vnet_subnet_id` is inside `default_node_pool` rather than at the top level.
- **ACR integration:** The `kubelet_identity.object_id` output provides the principal ID needed for `AcrPull` role assignment. See "Container Registry Integration" section above.
- **Kubenet:** Not supported. Use Azure CNI or Azure CNI Overlay.
- **Maintenance window validations:** `day_of_week` must be a day name (Monday-Sunday). `start_time` must be in `HH:MM` format (e.g. `"02:00"`). `frequency` must be `Daily`, `Weekly`, `AbsoluteMonthly`, or `RelativeMonthly`. `duration` must be 4-24 hours.
