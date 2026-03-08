# Terraform Module Catalog

> **Repository:** `git::https://github.com/AgicCompany/Standard.Terraform-Modules.git`
> **Provider:** AzureRM >= 4.0.0 | **Terraform:** >= 1.9.0
> **Defaults:** Private endpoints enabled, TLS 1.2 enforced, public access disabled

## Usage Pattern

```hcl
module "<name>" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/<module-name>?ref=<module-name>/v<version>"
  # ...
}
```

---

## Networking

### virtual-network `v1.0.0`
Creates an Azure Virtual Network with configurable subnets.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | VNet name |
| `address_space` | list(string) | yes | — | Address prefixes (e.g., `["10.0.0.0/16"]`) |
| `subnets` | map(object) | no | `{}` | Subnet configs: address_prefixes, service_endpoints, private_endpoint_network_policies, delegation |
| `subnet_nsg_associations` | map(string) | no | `{}` | Map subnet names to NSG IDs |
| `subnet_route_table_associations` | map(string) | no | `{}` | Map subnet names to route table IDs |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `address_space`, `subnet_ids`, `subnet_ids_map`

---

### vnet-peering `v1.0.0`
Creates bidirectional Azure Virtual Network peering between two VNets.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | yes | — | Peering name |
| `virtual_network_id` | string | yes | — | Local VNet resource ID |
| `virtual_network_resource_group_name` | string | yes | — | Local VNet RG |
| `virtual_network_name` | string | yes | — | Local VNet name |
| `remote_virtual_network_id` | string | yes | — | Remote VNet resource ID |
| `remote_virtual_network_resource_group_name` | string | yes | — | Remote VNet RG |
| `remote_virtual_network_name` | string | yes | — | Remote VNet name |
| `allow_virtual_network_access` | bool | no | `true` | Allow VNet access |
| `allow_forwarded_traffic` | bool | no | `false` | Allow forwarded traffic |
| `allow_gateway_transit` | bool | no | `false` | Allow gateway transit |
| `use_remote_gateways` | bool | no | `false` | Use remote gateways |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`

---

### network-security-group `v1.1.0`
Creates an Azure NSG with configurable security rules managed as separate resources.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | NSG name |
| `security_rules` | map(object) | no | `{}` | Rules: priority, direction (Inbound/Outbound), access (Allow/Deny), protocol (Tcp/Udp/Icmp/*), source/destination port ranges, source/destination address prefixes |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `security_rule_ids`

---

### route-table `v1.1.0`
Creates an Azure Route Table with configurable routes managed as separate resources.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Route table name |
| `disable_bgp_route_propagation` | bool | no | `false` | Disable BGP route propagation |
| `routes` | map(object) | no | `{}` | Routes: address_prefix, next_hop_type (VirtualNetworkGateway/VnetLocal/Internet/VirtualAppliance/None), next_hop_in_ip_address |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `route_ids`

---

### nat-gateway `v1.0.0`
Creates an Azure NAT Gateway with Standard SKU public IP for outbound connectivity.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | NAT Gateway name |
| `idle_timeout_in_minutes` | number | no | `4` | Idle timeout (4-120) |
| `zones` | list(string) | no | `[]` | Availability zones |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `public_ip_id`, `public_ip_address`

---

### private-dns-zone `v1.0.0`
Creates an Azure Private DNS Zone with virtual network linking.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `name` | string | yes | — | DNS zone name (e.g., `privatelink.blob.core.windows.net`) |
| `virtual_network_links` | map(object) | no | `{}` | VNet links: virtual_network_id, registration_enabled |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `virtual_network_link_ids`

---

### bastion `v1.0.0`
Creates an Azure Bastion host with automatic public IP for secure RDP/SSH access.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Bastion name |
| `subnet_id` | string | yes | — | AzureBastionSubnet ID (minimum /26) |
| `sku` | string | no | `"Basic"` | Basic or Standard |
| `copy_paste_enabled` | bool | no | `true` | Enable copy/paste |
| `file_copy_enabled` | bool | no | `false` | Enable file copy (Standard only) |
| `ip_connect_enabled` | bool | no | `false` | Enable IP connect (Standard only) |
| `shareable_link_enabled` | bool | no | `false` | Enable shareable links (Standard only) |
| `tunneling_enabled` | bool | no | `false` | Enable tunneling (Standard only) |
| `scale_units` | number | no | `2` | Scale units 2-50 (Standard only) |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `dns_name`, `public_ip_address`, `public_ip_id`

---

### front-door `v1.0.0`
Creates an Azure Front Door profile with endpoints, origin groups, and routes.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `name` | string | yes | — | Front Door profile name |
| `sku_name` | string | no | `"Standard_AzureFrontDoor"` | Standard_AzureFrontDoor or Premium_AzureFrontDoor |
| `response_timeout_seconds` | number | no | `60` | Response timeout (16-240) |
| `endpoints` | map(object) | no | `{}` | Endpoints with enabled flag |
| `origin_groups` | map(object) | no | `{}` | Origin groups: health_probe, load_balancing |
| `origins` | map(object) | no | `{}` | Origins: host_name, priority, weight, origin_group |
| `routes` | map(object) | no | `{}` | Routes: endpoint, origin_group, patterns, protocols |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `resource_guid`, `endpoint_ids`, `endpoint_host_names`, `origin_group_ids`, `origin_ids`, `route_ids`

---

### application-gateway `v1.1.0`
Creates an Azure Application Gateway (v2) with public IP, L7 load balancing, SSL termination, and optional WAF.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | AppGw name |
| `subnet_id` | string | yes | — | Dedicated subnet (minimum /24) |
| `sku_name` | string | no | `"Standard_v2"` | Standard_v2 or WAF_v2 |
| `sku_tier` | string | no | `"Standard_v2"` | Standard_v2 or WAF_v2 |
| `autoscale` | object | no | `{min=1, max=2}` | Min/max capacity |
| `zones` | list(string) | no | `[]` | Availability zones |
| `firewall_policy_id` | string | no | `null` | WAF policy ID |
| `frontend_ports` | map(object) | no | ports 80, 443 | Port definitions |
| `backend_address_pools` | map(object) | no | `{}` | Pools: fqdns, ip_addresses |
| `backend_http_settings` | map(object) | no | `{}` | HTTP settings: port, protocol, probe, affinity, timeout |
| `http_listeners` | map(object) | no | `{}` | Listeners: protocol, port, hostname, ssl_certificate |
| `request_routing_rules` | map(object) | no | `{}` | Rules: priority, listener, pool, settings |
| `probes` | map(object) | no | `{}` | Health probes: protocol, path, interval |
| `ssl_certificates` | map(object) | no | `{}` | PFX data+password or Key Vault secret ID (sensitive) |
| `redirect_configurations` | map(object) | no | `{}` | Redirects: type (Permanent/Found/SeeOther/Temporary) |
| `url_path_maps` | map(object) | no | `{}` | Path-based routing |
| `enable_http2` | bool | no | `true` | Enable HTTP/2 |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `public_ip_address`, `public_ip_id`, `backend_address_pool_ids`

---

## Compute

### linux-virtual-machine `v1.1.0`
Creates an Azure Linux VM with NIC, optional public IP, and data disk management.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | VM name |
| `size` | string | yes | — | VM size (e.g., Standard_B1s) |
| `subnet_id` | string | yes | — | Subnet for NIC |
| `admin_username` | string | yes | — | Admin username |
| `admin_ssh_public_key` | string | no | `null` | SSH public key (required if password auth disabled) |
| `admin_password` | string | no | `null` | Password (sensitive, required if password auth enabled) |
| `source_image_reference` | object | no | Ubuntu 22.04 LTS Gen2 | publisher, offer, sku, version |
| `os_disk` | object | no | Premium_LRS | caching, storage_account_type, disk_size_gb |
| `data_disks` | map(object) | no | `{}` | Data disks: lun, size, storage type, caching |
| `enable_password_auth` | bool | no | `false` | Enable password authentication |
| `enable_public_ip` | bool | no | `false` | Create public IP |
| `enable_system_assigned_identity` | bool | no | `false` | Enable system-assigned identity |
| `user_assigned_identity_ids` | list(string) | no | `[]` | User-assigned identity IDs |
| `zone` | string | no | `null` | Availability zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `private_ip_address`, `network_interface_id`, `principal_id`, `tenant_id`, `public_ip_address`

---

### windows-virtual-machine `v1.0.0`
Creates an Azure Windows VM with NIC, optional public IP, and data disk management.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | VM name |
| `size` | string | yes | — | VM size (e.g., Standard_B2s) |
| `subnet_id` | string | yes | — | Subnet for NIC |
| `admin_username` | string | yes | — | Admin username |
| `admin_password` | string | yes | — | Admin password (sensitive) |
| `source_image_reference` | object | no | Windows Server 2022 | publisher, offer, sku, version |
| `os_disk` | object | no | Premium_LRS | caching, storage_account_type, disk_size_gb |
| `data_disks` | map(object) | no | `{}` | Data disks: lun, size, storage type, caching |
| `enable_public_ip` | bool | no | `false` | Create public IP |
| `enable_system_assigned_identity` | bool | no | `false` | Enable system-assigned identity |
| `user_assigned_identity_ids` | list(string) | no | `[]` | User-assigned identity IDs |
| `zone` | string | no | `null` | Availability zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `private_ip_address`, `network_interface_id`, `public_ip_address`

---

### aks `v1.5.0`
Creates an Azure Kubernetes Service cluster with private-by-default config, Azure AD auth, RBAC, and Container Insights.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | AKS cluster name |
| `default_node_pool` | object | no | Standard_D2s_v3 | vm_size, subnet_id, node_count, min/max_count, zones, os_disk_size_gb, etc. |
| `dns_prefix` | string | no | name | DNS prefix |
| `kubernetes_version` | string | no | `null` (latest) | Kubernetes version |
| `sku_tier` | string | no | `"Free"` | Free, Standard, or Premium |
| `network_profile` | object | no | azure CNI | network_plugin, network_policy, service_cidr, dns_service_ip, load_balancer_sku |
| `authorized_ip_ranges` | list(string) | no | `[]` | Public IPs allowed to reach API server |
| `admin_group_object_ids` | list(string) | no | `[]` | Azure AD group IDs for cluster admin |
| `rbac_mode` | string | no | `"azure"` | azure or kubernetes |
| `key_vault_secrets_provider` | object | no | `null` | Key Vault CSI driver: secret_rotation_enabled, rotation_interval |
| `node_resource_group_name` | string | no | `null` | Custom node RG name |
| `log_analytics_workspace_id` | string | no | `null` | LAW ID (required if Container Insights enabled) |
| `automatic_upgrade_channel` | string | no | `"none"` | none, patch, rapid, stable, node-image |
| `auto_scaler_profile` | object | no | defaults | Cluster autoscaler config |
| `maintenance_window` | object | no | Sat-Sun 00:00-06:00 UTC | General maintenance window |
| `maintenance_window_auto_upgrade` | object | no | Weekly Sunday 02:00, 4h | Auto-upgrade maintenance window |
| `maintenance_window_node_os` | object | no | Weekly Saturday 02:00, 4h | Node OS upgrade window |
| `private_dns_zone_id` | string | no | `null` | Private DNS zone for private clusters |
| `enable_system_assigned_identity` | bool | no | `true` | Enable system-assigned identity |
| `enable_auto_scaling` | bool | no | `true` | Enable cluster autoscaler |
| `enable_container_insights` | bool | no | `true` | Enable Container Insights |
| `workload_identity_enabled` | bool | no | `false` | Enable workload identity |
| `user_assigned_identity_ids` | list(string) | no | `[]` | User-assigned identity IDs |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `fqdn`, `private_fqdn`, `kube_config_raw` (sensitive), `kubelet_identity`, `principal_id`, `tenant_id`, `oidc_issuer_url`, `node_resource_group`

---

### aks-node-pool `v1.0.0`
Creates additional user node pools for an existing AKS cluster.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `kubernetes_cluster_id` | string | yes | — | AKS cluster resource ID |
| `node_pools` | map(object) | no | `{}` | Node pools: vm_size, node_count, min/max_count, auto_scaling, os_type, priority, zones, labels, taints, subnet_id |

**Outputs:** `node_pool_ids`, `node_pool_names`

---

### container-app-environment `v1.0.0`
Creates an Azure Container Apps Environment with VNet integration and workload profiles.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | CAE name |
| `log_analytics_workspace_id` | string | yes | — | LAW ID for logging |
| `infrastructure_subnet_id` | string | no | `null` | Subnet for VNet integration |
| `workload_profiles` | map(object) | no | `{}` | Dedicated workload profiles: type, min, max |
| `enable_internal_load_balancer` | bool | no | `true` | Use internal load balancer |
| `enable_zone_redundancy` | bool | no | `false` | Enable zone redundancy |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `default_domain`, `static_ip_address`, `docker_bridge_cidr`, `platform_reserved_cidr`, `platform_reserved_dns_ip_address`

---

### container-app `v1.1.0`
Creates an Azure Container App in an existing Container Apps Environment.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `name` | string | yes | — | Container App name |
| `container_app_environment_id` | string | yes | — | CAE resource ID |
| `container` | object | yes | — | Main container: image, cpu, memory, env, probes |
| `revision_mode` | string | no | `"Single"` | Single or Multiple |
| `ingress` | object | no | `null` | Ingress: target_port, transport, traffic_weight |
| `secrets` | map(string) | no | `{}` | Secrets (sensitive) |
| `scale` | object | no | `null` | Scale: min_replicas, max_replicas, rules |
| `user_assigned_identity_ids` | list(string) | no | `[]` | User-assigned identity IDs |
| `workload_profile_name` | string | no | `null` | Workload profile (null = Consumption) |
| `init_containers` | list(object) | no | `[]` | Init containers |
| `enable_ingress` | bool | no | `false` | Enable ingress |
| `enable_external_ingress` | bool | no | `false` | Enable external ingress |
| `enable_system_assigned_identity` | bool | no | `false` | Enable system-assigned identity |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `latest_revision_fqdn`, `latest_revision_name`, `outbound_ip_addresses`, `principal_id`, `tenant_id`

---

## Web & App Services

### app-service-plan `v1.0.0`
Creates an Azure App Service Plan with configurable OS, SKU, and optional zone redundancy.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | ASP name |
| `sku_name` | string | yes | — | F1, B1-B3, S1-S3, P0-P3v3, Y1, EP1-EP3 |
| `os_type` | string | no | `"Linux"` | Linux, Windows, WindowsContainer |
| `worker_count` | number | no | `1` | Worker count |
| `enable_zone_redundancy` | bool | no | `false` | Zone redundancy (Premium SKU required) |
| `enable_per_site_scaling` | bool | no | `false` | Per-site scaling |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `kind`, `reserved`

---

### linux-web-app `v1.0.0`
Creates an Azure Linux Web App with secure defaults and optional private endpoint.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Web App name |
| `service_plan_id` | string | yes | — | App Service Plan ID |
| `application_stack` | object | no | `null` | Runtime: docker, dotnet, node, python, java, php |
| `app_settings` | map(string) | no | `{}` | Environment variables |
| `connection_strings` | map(object) | no | `{}` | Connection strings (sensitive) |
| `vnet_integration_subnet_id` | string | no | `null` | VNet integration subnet |
| `health_check_path` | string | no | `null` | Health check path |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `enable_vnet_integration` | bool | no | `false` | Enable VNet integration |
| `enable_system_assigned_identity` | bool | no | `true` | Enable system-assigned identity |
| `always_on` | bool | no | `true` | Always on |
| `user_assigned_identity_ids` | list(string) | no | `[]` | User-assigned identity IDs |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `default_hostname`, `outbound_ip_addresses`, `principal_id`, `tenant_id`, `private_endpoint_id`, `private_ip_address`

---

### function-app `v1.0.0`
Creates an Azure Linux Function App with secure defaults and optional private endpoint.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Function App name |
| `service_plan_id` | string | yes | — | App Service Plan ID |
| `storage_account_name` | string | yes | — | Storage account for runtime |
| `storage_account_access_key` | string | yes | — | Storage access key (sensitive) |
| `application_stack` | object | no | `null` | Runtime: dotnet, java, node, python, powershell, docker |
| `app_settings` | map(string) | no | `{}` | App settings |
| `functions_extension_version` | string | no | `"~4"` | Functions runtime version |
| `vnet_integration_subnet_id` | string | no | `null` | VNet integration subnet |
| `application_insights_connection_string` | string | no | `null` | App Insights connection string |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `enable_vnet_integration` | bool | no | `false` | Enable VNet integration |
| `enable_system_assigned_identity` | bool | no | `true` | Enable system-assigned identity |
| `user_assigned_identity_ids` | list(string) | no | `[]` | User-assigned identity IDs |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `default_hostname`, `outbound_ip_addresses`, `principal_id`, `tenant_id`, `private_endpoint_id`, `private_ip_address`

---

### static-web-app `v1.1.0`
Creates an Azure Static Web App with configurable SKU and app settings.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Static Web App name |
| `sku_tier` | string | no | `"Free"` | Free or Standard |
| `sku_size` | string | no | `"Free"` | Free or Standard |
| `app_settings` | map(string) | no | `{}` | App settings |
| `enable_private_endpoint` | bool | no | `true` | Enable PE (Standard only) |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `default_host_name`, `api_key` (sensitive), `private_endpoint_id`

---

### api-management `v1.0.0`
Creates an Azure API Management service with VNet integration, multi-region support, and optional private endpoint.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | APIM service name |
| `publisher_name` | string | yes | — | Publisher name |
| `publisher_email` | string | yes | — | Publisher email |
| `sku_name` | string | no | `"Developer_1"` | Developer_1, Basic_1-4, Standard_1-4, Premium_1-4, Consumption |
| `virtual_network_type` | string | no | `"None"` | None, External, Internal |
| `virtual_network_subnet_id` | string | no | `null` | Subnet for VNet integration |
| `zones` | list(string) | no | `[]` | Availability zones (Premium only) |
| `additional_locations` | list(object) | no | `[]` | Multi-region locations (Premium only) |
| `identity_type` | string | no | `"SystemAssigned"` | SystemAssigned, UserAssigned, or both |
| `identity_ids` | list(string) | no | `[]` | User-assigned identity IDs |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `gateway_url`, `management_api_url`, `developer_portal_url`, `principal_id`, `tenant_id`, `public_ip_addresses`, `private_endpoint_id`, `private_ip_address`

---

## Data & Storage

### storage-account `v1.1.0`
Creates an Azure Storage Account with secure defaults and optional private endpoints per subresource.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Storage account name (3-24 chars, lowercase alphanumeric) |
| `account_tier` | string | no | `"Standard"` | Standard or Premium |
| `account_replication_type` | string | no | `"GRS"` | LRS, GRS, RAGRS, ZRS |
| `access_tier` | string | no | `null` | Hot or Cool |
| `min_tls_version` | string | no | `"TLS1_2"` | Must be TLS1_2 |
| `enable_blob_soft_delete` | bool | no | `true` | Enable blob soft delete |
| `blob_soft_delete_retention_days` | number | no | `7` | Blob soft delete retention |
| `enable_container_soft_delete` | bool | no | `true` | Enable container soft delete |
| `container_soft_delete_retention_days` | number | no | `7` | Container soft delete retention |
| `enable_blob_versioning` | bool | no | `false` | Enable blob versioning |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoints |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `allow_nested_items_to_be_public` | bool | no | `false` | Allow public blob containers |
| `network_rules` | object | no | `null` | Bypass, default_action, IP rules, VNet rules |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_ids` | map(string) | no | `{}` | Map of subresources (blob, file, table, queue) to DNS zone IDs |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `primary_blob_endpoint`, `primary_queue_endpoint`, `primary_table_endpoint`, `primary_file_endpoint`, `private_endpoint_ids`

---

### key-vault `v1.0.0`
Creates an Azure Key Vault with RBAC authorization and optional private endpoint.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Key Vault name |
| `sku_name` | string | no | `"standard"` | standard or premium |
| `tenant_id` | string | no | current tenant | AAD tenant ID |
| `soft_delete_retention_days` | number | no | `90` | Soft delete retention (7-90) |
| `enabled_for_deployment` | bool | no | `false` | VM certificate retrieval |
| `enabled_for_disk_encryption` | bool | no | `false` | Disk encryption |
| `enabled_for_template_deployment` | bool | no | `false` | ARM template access |
| `network_acls` | object | no | `null` | Firewall: bypass, default_action, IP rules, subnet IDs |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `enable_purge_protection` | bool | no | `true` | Enable purge protection |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `vault_uri`, `tenant_id`, `private_endpoint_id`, `private_ip_address`

---

### mssql-server `v1.1.0`
Creates an Azure SQL logical server with Azure AD auth and optional private endpoint.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | SQL server name |
| `azuread_administrator` | object | yes | — | login_username and object_id |
| `version` | string | no | `"12.0"` | SQL server version |
| `minimum_tls_version` | string | no | `"1.2"` | Must be 1.2 |
| `connection_policy` | string | no | `null` | Default, Proxy, Redirect |
| `administrator_login` | string | no | `null` | SQL admin login (hybrid auth) |
| `administrator_login_password` | string | no | `null` | SQL admin password (sensitive) |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `enable_aad_only_auth` | bool | no | `true` | Azure AD-only auth |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `fully_qualified_domain_name`, `principal_id`, `private_endpoint_id`, `private_ip_address`

---

### mssql-database `v1.0.0`
Creates an Azure SQL Database on an existing SQL server.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | yes | — | Database name |
| `server_id` | string | yes | — | SQL server resource ID |
| `sku_name` | string | yes | — | DTU (S0, S1, P1) or vCore (GP_Gen5_2, etc.) |
| `backup_retention_days` | number | no | `null` | Short-term backup retention (1-35) |
| `geo_redundant_backup_enabled` | bool | no | `true` | Geo-redundant backup |
| `zone_redundancy_enabled` | bool | no | `false` | Zone redundancy |
| `read_scale_out_enabled` | bool | no | `false` | Read scale-out |
| `license_type` | string | no | `null` | LicenseIncluded or BasePrice |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`

---

### mysql-flexible-server `v2.0.0`
Creates an Azure MySQL Flexible Server with configurable databases and server parameters.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | MySQL server name |
| `administrator_login` | string | yes | — | Admin login |
| `administrator_password` | string | yes | — | Admin password (sensitive) |
| `sku_name` | string | yes | — | B_Standard_B1s, Standard_D2ds_v4, etc. |
| `version` | string | no | `null` | 5.7, 8.0.21 |
| `databases` | map(object) | no | `{}` | Database names |
| `firewall_rules` | map(object) | no | `{}` | Rules: start_ip, end_ip |
| `server_parameters` | map(object) | no | `{}` | Server config parameters |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `delegated_subnet_id` | string | no | `null` | VNet delegation (mutually exclusive with PE) |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `subnet_id` | string | no | `null` | PE subnet |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `fqdn`, `database_ids`, `server_parameter_ids`

---

### postgresql-flexible-server `v2.0.0`
Creates an Azure PostgreSQL Flexible Server with configurable databases and server parameters.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | PostgreSQL server name |
| `administrator_login` | string | yes | — | Admin login |
| `administrator_password` | string | yes | — | Admin password (sensitive) |
| `sku_name` | string | yes | — | B_Standard_B1s, Standard_D2s_v3, etc. |
| `version` | string | no | `null` | 12-16 |
| `databases` | map(object) | no | `{}` | Database names |
| `firewall_rules` | map(object) | no | `{}` | Rules: start_ip, end_ip |
| `server_parameters` | map(object) | no | `{}` | Server config parameters |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `delegated_subnet_id` | string | no | `null` | VNet delegation (mutually exclusive with PE) |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `subnet_id` | string | no | `null` | PE subnet |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `fqdn`, `database_ids`, `server_parameter_ids`

---

### cosmosdb `v1.1.0`
Creates an Azure Cosmos DB account with SQL API databases and optional private endpoint.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Cosmos DB account name |
| `offer_type` | string | no | `"Standard"` | Offer type |
| `kind` | string | no | `"GlobalDocumentDB"` | GlobalDocumentDB, MongoDB, Parse |
| `consistency_policy` | object | no | Session | Level: BoundedStaleness, Eventual, Session, Strong, ConsistentPrefix |
| `geo_locations` | list(object) | no | same region | Multi-region: location, failover_priority, zone_redundant |
| `free_tier_enabled` | bool | no | `false` | Enable free tier |
| `automatic_failover_enabled` | bool | no | `false` | Enable auto-failover |
| `minimal_tls_version` | string | no | `"Tls12"` | Must be Tls12 |
| `sql_databases` | map(object) | no | `{}` | SQL databases: throughput, max_throughput |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `enable_multiple_write_locations` | bool | no | `false` | Multi-region writes |
| `enable_local_auth` | bool | no | `false` | Disable key-based auth |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `endpoint`, `database_ids`, `private_endpoint_id`, `private_ip_address`

---

### redis-cache `v1.1.0`
Creates an Azure Redis Cache with secure defaults and optional private endpoint.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Redis cache name |
| `sku_name` | string | no | `"Standard"` | Basic, Standard, Premium |
| `family` | string | no | `"C"` | C (Basic/Standard) or P (Premium) |
| `capacity` | number | no | `1` | 0-6 for C, 1-5 for P |
| `minimum_tls_version` | string | no | `"1.2"` | Must be 1.2 |
| `maxmemory_policy` | string | no | `null` | Eviction policy |
| `firewall_rules` | map(object) | no | `{}` | IP firewall rules |
| `patch_schedule` | object | no | `null` | Patch schedule (Premium only) |
| `zones` | list(string) | no | `[]` | Availability zones (Premium only) |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `enable_non_ssl_port` | bool | no | `false` | Enable non-SSL port |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `hostname`, `port`, `primary_access_key` (sensitive), `private_endpoint_id`, `private_ip_address`

---

## Messaging

### service-bus `v1.1.0`
Creates an Azure Service Bus namespace with queues, topics, and optional private endpoint.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Service Bus namespace name |
| `sku` | string | no | `"Standard"` | Basic, Standard, Premium |
| `minimum_tls_version` | string | no | `"1.2"` | Must be 1.2 |
| `queues` | map(object) | no | `{}` | Queues with configurable properties |
| `topics` | map(object) | no | `{}` | Topics with subscriptions |
| `enable_private_endpoint` | bool | no | `true` | Enable PE (Premium only) |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `enable_local_auth` | bool | no | `false` | Enable local/SAS auth |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `queue_ids`, `topic_ids`, `subscription_ids`, `private_endpoint_id`, `private_ip_address`

---

### event-hub `v1.1.0`
Creates an Azure Event Hub namespace with event hubs, consumer groups, and optional private endpoint.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Event Hub namespace name |
| `sku` | string | no | `"Standard"` | Basic, Standard, Premium |
| `capacity` | number | no | `1` | Throughput units |
| `minimum_tls_version` | string | no | `"1.2"` | Must be 1.2 |
| `auto_inflate_enabled` | bool | no | `false` | Auto-inflate throughput |
| `maximum_throughput_units` | number | no | `null` | Max throughput units (with auto-inflate) |
| `event_hubs` | map(object) | no | `{}` | Event hubs: partition_count, message_retention, consumer_groups |
| `authorization_rules` | map(object) | no | `{}` | Namespace auth rules: listen, send, manage |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `enable_local_auth` | bool | no | `false` | Enable local/SAS auth |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `eventhub_ids`, `consumer_group_ids`, `authorization_rule_ids`, `private_endpoint_id`, `private_ip_address`

---

## Monitoring & Identity

### log-analytics-workspace `v1.0.0`
Creates an Azure Log Analytics workspace for centralized logging.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | LAW name |
| `sku` | string | no | `"PerGB2018"` | Free, PerGB2018, PerNode, Premium, Standard, etc. |
| `retention_in_days` | number | no | `30` | Retention (30-730) |
| `daily_quota_gb` | number | no | `-1` | Daily quota (-1 = unlimited) |
| `enable_internet_ingestion` | bool | no | `false` | Allow internet ingestion |
| `enable_internet_query` | bool | no | `false` | Allow internet queries |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `workspace_id`

---

### application-insights `v1.0.0`
Creates an Azure Application Insights resource backed by Log Analytics for APM.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | App Insights name |
| `workspace_id` | string | yes | — | Log Analytics workspace ID |
| `application_type` | string | no | `"web"` | web, ios, java, Node.JS, other, phone, store |
| `retention_in_days` | number | no | `90` | Retention: 30, 60, 90, 120, 180, 270, 365, 550, 730 |
| `daily_data_cap_in_gb` | number | no | `null` | Daily data cap (null = unlimited) |
| `sampling_percentage` | number | no | `100` | Sampling percentage (0-100) |
| `disable_ip_masking` | bool | no | `false` | Disable IP masking |
| `local_authentication_disabled` | bool | no | `true` | Disable local/API key auth |
| `internet_ingestion_enabled` | bool | no | `false` | Allow internet ingestion |
| `internet_query_enabled` | bool | no | `false` | Allow internet queries |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `app_id`, `instrumentation_key` (sensitive), `connection_string` (sensitive)

---

### diagnostic-settings `v1.0.0`
Creates an Azure Monitor diagnostic setting to route logs and metrics to Log Analytics.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | yes | — | Diagnostic setting name |
| `target_resource_id` | string | yes | — | Target resource ID |
| `log_analytics_workspace_id` | string | yes | — | LAW ID |
| `enabled_log_categories` | list(string) | no | `null` | Log categories (null = allLogs) |
| `metric_categories` | list(string) | no | `null` | Metric categories (null = AllMetrics) |
| `log_analytics_destination_type` | string | no | `null` | Dedicated or AzureDiagnostics |

**Outputs:** `id`, `name`

---

### action-group `v1.0.0`
Creates an Azure Monitor Action Group for alert notifications.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `name` | string | yes | — | Action group name |
| `short_name` | string | yes | — | Short name (max 12 chars) |
| `email_receivers` | map(object) | no | `{}` | Email receivers |
| `sms_receivers` | map(object) | no | `{}` | SMS receivers: country_code, phone_number |
| `webhook_receivers` | map(object) | no | `{}` | Webhook receivers: URI, optional AAD auth |
| `azure_app_push_receivers` | map(object) | no | `{}` | Push notification receivers |
| `enabled` | bool | no | `true` | Enable action group |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`

---

### user-assigned-identity `v1.0.0`
Creates an Azure User-Assigned Managed Identity.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | Identity name |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `principal_id`, `client_id`, `tenant_id`

---

## Container Registry

### container-registry `v1.0.0`
Creates an Azure Container Registry with secure defaults and optional private endpoint.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | yes | — | Resource group name |
| `location` | string | yes | — | Azure region |
| `name` | string | yes | — | ACR name (5-50 chars, alphanumeric, globally unique) |
| `sku` | string | no | `"Premium"` | Basic, Standard, Premium |
| `georeplications` | map(object) | no | `{}` | Geo-replication locations (Premium only) |
| `enable_private_endpoint` | bool | no | `true` | Enable private endpoint |
| `enable_public_access` | bool | no | `false` | Enable public access |
| `enable_admin` | bool | no | `false` | Admin account (not recommended) |
| `enable_content_trust` | bool | no | `false` | Image signing (Premium only) |
| `enable_geo_replication` | bool | no | `false` | Enable geo-replication |
| `subnet_id` | string | no | `null` | PE subnet |
| `private_dns_zone_id` | string | no | `null` | PE DNS zone |
| `tags` | map(string) | no | `{}` | Tags |

**Outputs:** `id`, `name`, `login_server`, `principal_id`, `tenant_id`, `private_endpoint_id`, `private_ip_address`
