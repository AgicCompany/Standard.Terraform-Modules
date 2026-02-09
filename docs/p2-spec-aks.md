# Module: aks

**Priority:** P2
**Complexity:** High
**Status:** In Progress
**Target Version:** v1.0.0

## What It Creates

- `azurerm_kubernetes_cluster` -- Azure Kubernetes Service cluster

## v1.0.0 Scope

A private-by-default AKS cluster with a single system node pool, Azure AD authentication, Azure RBAC for Kubernetes authorization, and Container Insights. Scoped to deliver a working cluster with sensible defaults -- not an exhaustive AKS configuration surface.

The `azurerm_kubernetes_cluster` resource has 100+ attributes. This module exposes the most common settings and defers advanced configuration to minor versions. The guiding principle: **a production-ready private cluster with one node pool that works out of the box.**

### In Scope

- Cluster creation with configurable Kubernetes version
- Default (system) node pool with autoscaling
- Private cluster (always enabled -- see Private Cluster section)
- Azure CNI Overlay networking (default) with flat CNI available via override
- System-assigned managed identity
- Azure AD authentication (always enabled, local accounts disabled)
- Azure RBAC for Kubernetes authorization (hardcoded in v1.0.0 -- see RBAC section)
- Container Insights via Log Analytics workspace
- Upgrade settings (automatic channel, max surge)
- SKU tier selection (Free, Standard, Premium)

### Out of Scope

See [Roadmap](#roadmap) for version targets and [Backlog](#backlog) for unscheduled items.

## Security Defaults

| Setting | Default | Override |
|---------|---------|----------|
| Private cluster | Enabled (hardcoded) | `authorized_ip_ranges` to allow specific IPs |
| Local accounts | Disabled (hardcoded) | None -- Azure AD only |
| Azure RBAC authorization | Enabled (hardcoded) | `rbac_mode` in v1.1.0 |
| Network plugin | Azure CNI Overlay | `network_profile.network_plugin_mode = null` for flat CNI |
| Default OS | AzureLinux | `default_node_pool.os_sku` |
| Autoscaling | Enabled | `enable_auto_scaling = false` |
| Upgrade channel | None (manual control) | `automatic_upgrade_channel` |

## RBAC

### Authentication

Azure AD authentication is always enabled. Local Kubernetes accounts are disabled (`local_account_disabled = true`). This is hardcoded -- there is no toggle. All cluster access goes through Entra ID (formerly Azure AD).

### Authorization

v1.0.0 uses **Azure RBAC for Kubernetes Authorization** (`azure_rbac_enabled = true`). This is hardcoded -- there is no toggle in v1.0.0.

Azure RBAC manages all Kubernetes authorization through Azure IAM role assignments. Built-in roles:

| Role | Scope | Purpose |
|------|-------|---------|
| Azure Kubernetes Service RBAC Cluster Admin | Cluster | Full cluster access |
| Azure Kubernetes Service RBAC Admin | Cluster or Namespace | Admin access, can manage RBAC |
| Azure Kubernetes Service RBAC Writer | Cluster or Namespace | Read/write access to most objects |
| Azure Kubernetes Service RBAC Reader | Cluster or Namespace | Read-only access |

This model is appropriate for single-tenant and single-workload clusters. For multi-tenant clusters requiring fine-grained namespace isolation, Kubernetes RBAC authorization is planned for v1.1.0 (see Roadmap).

### Admin Group

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `admin_group_object_ids` | list(string) | No | `[]` | Azure AD group object IDs for cluster admin access |

When provided, these groups receive cluster admin privileges via Azure AD integration. This is the recommended way to manage admin access rather than individual user assignments.

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_auto_scaling` | `true` | Enable cluster autoscaler on the default node pool |
| `enable_container_insights` | `true` | Enable Container Insights via Log Analytics |

## Private Cluster

The cluster is **always private** (`private_cluster_enabled = true`). This is hardcoded -- there is no `enable_private_cluster` toggle.

The access posture is controlled by `authorized_ip_ranges`:

| Configuration | Behavior |
|---------------|----------|
| `authorized_ip_ranges = []` (default) | Fully private. API server accessible only from within the VNet. |
| `authorized_ip_ranges = ["1.2.3.4/32"]` | Private cluster with specific public IPs allowed to reach the API server. |

For development and testing access to private clusters:

| Method | Complexity | Use Case |
|--------|-----------|----------|
| `az aks command invoke` | Lowest | Ad-hoc commands via Azure API. No VNet access needed. |
| Authorized IP ranges | Low | Allow office/VPN IPs to reach API server. |
| VPN / ExpressRoute | Medium | Laptop is "inside" the network. |
| Jumpbox / Bastion | Medium | VM in the VNet, SSH via Azure Bastion. |
| CI/CD self-hosted agent | Medium | Agent runs in the VNet. Needed for pipelines anyway. |

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `dns_prefix` | string | No | `null` | DNS prefix for the cluster. When `null`, defaults to the `name` variable. Override only when a custom DNS prefix is needed. |
| `kubernetes_version` | string | No | `null` | Kubernetes version. When `null`, Azure selects the latest stable version. |
| `sku_tier` | string | No | `"Free"` | SKU tier: `Free`, `Standard` (includes Uptime SLA), or `Premium`. Override to `Standard` or higher for production. |
| `automatic_upgrade_channel` | string | No | `"none"` | Auto-upgrade channel: `none`, `patch`, `stable`, `rapid`, `node-image`. Default is `none` for full manual control over upgrades. |
| `node_resource_group_name` | string | No | `null` | Custom name for the auto-created node resource group. When `null`, Azure generates `MC_<rg>_<cluster>_<region>`. |
| `authorized_ip_ranges` | list(string) | No | `[]` | Public IP ranges allowed to reach the API server. Empty means fully private. |
| `admin_group_object_ids` | list(string) | No | `[]` | Azure AD group object IDs for cluster admin access. |
| `log_analytics_workspace_id` | string | Conditional | -- | Log Analytics workspace ID. Required when `enable_container_insights = true`. |

### Default Node Pool Variable

```hcl
variable "default_node_pool" {
  type = object({
    vm_size                     = optional(string, "Standard_D2s_v3")
    vnet_subnet_id              = optional(string)
    node_count                  = optional(number, 3)
    min_count                   = optional(number, 1)
    max_count                   = optional(number, 5)
    os_disk_size_gb             = optional(number, 128)
    os_disk_type                = optional(string, "Managed")
    os_sku                      = optional(string, "AzureLinux")
    zones                       = optional(list(string), ["1", "2", "3"])
    max_pods                    = optional(number, 30)
    temporary_name_for_rotation = optional(string, "tmpnodepool")
    upgrade_settings = optional(object({
      max_surge                     = optional(string, "33%")
      drain_timeout_in_minutes      = optional(number, 30)
      node_soak_duration_in_minutes = optional(number, 0)
    }), {})
  })
  default     = {}
  description = "Default (system) node pool configuration."
}
```

The `vnet_subnet_id` is provided within the `default_node_pool` variable -- not as a top-level variable -- because it is a node pool concern. With flat Azure CNI, each node pool can use its own subnet (all must belong to the same VNet). With CNI Overlay (the default), all node pools share the same subnet.

### Network Profile Variable

```hcl
variable "network_profile" {
  type = object({
    network_plugin      = optional(string, "azure")         # azure (CNI) -- only supported option
    network_plugin_mode = optional(string, "overlay")       # overlay (recommended) or null for flat CNI
    network_policy      = optional(string, "azure")         # azure or calico
    pod_cidr            = optional(string, "10.244.0.0/16") # Pod CIDR for Overlay mode. Ignored in flat CNI.
    service_cidr        = optional(string, "10.0.0.0/16")
    dns_service_ip      = optional(string, "10.0.0.10")
    outbound_type       = optional(string, "loadBalancer")  # loadBalancer or userDefinedRouting
  })
  default     = {}
  description = "Network configuration. Defaults to Azure CNI Overlay."
}
```

## Dependencies

| Resource | Source | Notes |
|----------|--------|-------|
| Subnet | `virtual-network` module | Default node pool VNet integration. With Overlay (default), only nodes consume subnet IPs. With flat CNI, nodes + pods consume subnet IPs -- size accordingly. |
| Log Analytics workspace | `log-analytics-workspace` module | Container Insights (when enabled) |
| Container Registry | `container-registry` module (optional) | Image pulling. See ACR Integration note below. |

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `kube_config_raw` | Raw kubeconfig (sensitive). For bootstrapping only -- prefer Azure AD auth. |
| `fqdn` | Cluster FQDN (private when private cluster enabled) |
| `private_fqdn` | Private FQDN of the API server |
| `node_resource_group` | Auto-created resource group for cluster infrastructure |
| `oidc_issuer_url` | OIDC issuer URL (for workload identity federation) |
| `principal_id` | System-assigned managed identity principal ID |
| `tenant_id` | System-assigned managed identity tenant ID |
| `kubelet_identity` | Kubelet managed identity (object with client_id, object_id, user_assigned_identity_id) |
| `public_aks_id` | Cluster ID (public output for cross-project consumption) |
| `public_aks_name` | Cluster name (public output for cross-project consumption) |

## Roadmap

### v1.1.0 -- Multi-tenant and operational maturity

- **Kubernetes RBAC authorization mode** -- Add `rbac_mode` variable (`"azure"` or `"kubernetes"`) to support Kubernetes RBAC authorization for multi-tenant cluster scenarios. Azure AD authentication remains mandatory regardless of authorization mode. When `rbac_mode = "kubernetes"`, the module enables AAD authentication + Kubernetes RBAC authorization instead of Azure RBAC. Consumers manage RoleBindings inside the cluster.
- **Workload identity federation** -- Enable `oidc_issuer_enabled` and `workload_identity_enabled`. The OIDC issuer URL is already output in v1.0.0, so the groundwork is laid. This is the recommended pattern for pod-to-Azure-service authentication (pod identity is deprecated).
- **Key Vault CSI driver add-on** -- Common companion to workload identity. Enables pods to mount Key Vault secrets as volumes or sync them to Kubernetes secrets.

### v1.2.0 -- Production hardening

- **Auto-scaler profile tuning** -- Expose `auto_scaler_profile` block for fine-tuning scale-down thresholds, scan intervals, and cooldown periods. Azure defaults work for most workloads but production clusters often need tuning.
- **Maintenance windows** -- `maintenance_window` and `maintenance_window_auto_upgrade` blocks for controlling when Azure performs cluster and node image upgrades. Important for production SLA compliance.
- **Load balancer profile customization** -- Outbound IP management, idle timeout, allocated outbound ports. Relevant for production traffic patterns where SNAT exhaustion or idle connection drops become an issue.
- **Private DNS zone customization** -- `private_dns_zone_id` for using custom private DNS zones instead of the system-managed zone (`"System"`). Needed for hub-spoke network topologies with centralized DNS.

### Backlog (unscheduled)

- **aks-node-pool module** -- Separate module wrapping `azurerm_kubernetes_cluster_node_pool` for additional node pools. Each pool has its own lifecycle independent of the cluster. This is a separate module, not an AKS module change.
- **Windows node pools** -- Requires `azurerm_kubernetes_cluster_node_pool` with `os_type = "Windows"`. Depends on the `aks-node-pool` module.
- **User-assigned identity and kubelet identity customization** -- System-assigned is fine for most scenarios. Custom identities add complexity around pre-creation and role assignments.
- **Storage profile customization** -- Disk CSI, file CSI, snapshot controller toggles. Azure defaults are sensible.
- **Web app routing / managed ingress controller** -- Most teams use their own ingress controller (NGINX, Traefik, etc.).
- **HTTP proxy configuration** -- For clusters that route outbound traffic through a corporate proxy.
- **Disk encryption set** -- Customer-managed keys for node OS disks.
- **Azure Policy add-on** -- Evaluate when governance requirements demand it.

## Notes

- **AzureRM 4.x: Stable API only.** All preview feature properties were removed from the `azurerm_kubernetes_cluster` resource. If a consumer needs preview features, they must use the `azapi` provider alongside this module. This actually helps scope v1.0.0 -- we can only use what is in the stable API.
- **Private cluster is always on.** Unlike other modules with `enable_private_endpoint`, AKS does not use Private Link for the API server -- it uses a different mechanism (`private_cluster_enabled`). Making a public cluster private later requires cluster recreation. We avoid this by defaulting to private from day one. The `authorized_ip_ranges` variable is the escape hatch for development access.
- **Azure RBAC for Kubernetes (v1.0.0).** Authorization is handled entirely through Azure IAM. This is simpler to manage and stays within Terraform's natural reach (role assignments are `azurerm_role_assignment` resources). Kubernetes RBAC authorization is planned for v1.1.0 to support multi-tenant clusters where fine-grained namespace-level permissions are needed.
- **DNS prefix:** Defaults to the `name` variable via `coalesce(var.dns_prefix, var.name)` in locals. Most consumers never need to set this. Override only when the cluster name does not meet DNS prefix requirements or a specific prefix is needed.
- **`kubernetes_version = null`:** When `null`, Azure selects the latest stable version. This is convenient but means Terraform may detect drift when Azure releases new versions. For production, pin to a specific version (e.g., `"1.29"`) and upgrade deliberately.
- **Node pool name:** The default node pool name is always `"system"`. This is hardcoded in the module -- consumers do not control it. Additional pools (via the future `aks-node-pool` module) get consumer-defined names.
- **Node resource group:** Azure auto-creates a resource group (default: `MC_<rg>_<cluster>_<region>`) for cluster infrastructure (VMs, disks, load balancers). The `node_resource_group_name` variable allows overriding this name for organizations with strict naming conventions. Once set, it cannot be changed without recreating the cluster.
- **AzureLinux as default OS:** `os_sku = "AzureLinux"` (formerly Mariner) is Microsoft's recommended Linux distribution for AKS. It is smaller, faster to boot, and maintained by Microsoft. Consumers can override to `"Ubuntu"` if needed.
- **`temporary_name_for_rotation`:** Required when changes to the default node pool force recreation (e.g., changing `vm_size`). AKS creates a temporary pool with this name, migrates workloads, then replaces the original. Without this, such changes are blocked.
- **Naming:** CAF prefix for AKS is `aks`. Example: `aks-payments-dev-weu-001`.
- **`kube_config_raw` output:** Marked as sensitive. Useful for initial bootstrapping (e.g., installing Helm charts via Terraform). For day-to-day access, use `az aks get-credentials` with Azure AD auth.
- **OIDC issuer URL:** Output even though workload identity is deferred. The URL is generated when the cluster is created and is needed later when configuring workload identity. Outputting it now avoids a module change later.
- **Kubenet:** Deprecated, retiring March 31, 2028. Not supported by this module. Use Azure CNI or Azure CNI Overlay.
- **Why CNI Overlay as default:** The framework is private-first -- workloads communicate via private endpoints, internal load balancers, and ingress controllers, not direct pod-to-VNet routing. Overlay conserves VNet IPs (only nodes consume them), scales better, and is Microsoft's recommended path forward. Flat CNI is available by setting `network_plugin_mode = null` for projects that genuinely need direct pod routability from the VNet. Note: Azure Application Gateway Ingress Controller (AGIC) is not supported with Overlay.
- **Subnet sizing:** With CNI Overlay (default), only nodes consume subnet IPs. A `/24` gives you ~251 usable IPs for nodes. With flat CNI, each node and each pod consumes a subnet IP -- a `/24` supports ~246 pods across all nodes. Plan accordingly; undersized subnets are the #1 AKS deployment failure.
- **Subnet per node pool:** With flat Azure CNI, each node pool can use its own subnet (all must belong to the same VNet). With CNI Overlay, all node pools share the same subnet. This is why `vnet_subnet_id` is inside the `default_node_pool` variable rather than at the top level.
- **ACR integration:** The AKS module does not manage container registry role assignments. ACR integration is the consumer's responsibility at the project level. The `kubelet_identity.object_id` output provides the principal ID needed for the `AcrPull` role assignment. This keeps the AKS module decoupled from registry concerns -- not every cluster uses ACR, and some use multiple registries. Document the consumer-side pattern in the module README under a "Container Registry Integration" section with a copy-paste example.
- **This module does not block other P2 modules.** It has the most complex dependency surface and longest development time. Other P2 modules should be completed independently. AKS may ship after the rest of P2 -- that is fine.
