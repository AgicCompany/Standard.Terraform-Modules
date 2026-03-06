# Module: private-dns-zone

**Priority:** P1  
**Status:** Not Started  
**Target Version:** v1.0.0

## What It Creates

- `azurerm_private_dns_zone` — Azure Private DNS Zone
- `azurerm_private_dns_zone_virtual_network_link` — One link per entry in the `virtual_network_links` variable

## v1.0.0 Scope

A private DNS zone with virtual network linking. This module is the DNS foundation for the private endpoint pattern — every module that creates private endpoints needs a corresponding DNS zone.

### In Scope

- Private DNS zone creation
- Virtual network linking (one or more vnets)
- Auto-registration support per link

### Out of Scope (Deferred)

- DNS records (A, CNAME, etc.) — private endpoints create their own A records automatically via the DNS zone group. Manual records are consumer responsibility.
- Conditional forwarders
- DNS zone delegation

## Feature Flags

No feature flags for v1.0.0. The module is straightforward — create a zone, link it to vnets.

## Private Endpoint Support

Not applicable. DNS zones do not have private endpoints — they *serve* them.

## Variables

This module uses a modified standard interface. The `location` variable is not required because private DNS zones are global resources in Azure. `resource_group_name` and `tags` apply normally.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `resource_group_name` | string | Yes | — | Target resource group |
| `name` | string | Yes | — | DNS zone name (e.g., `privatelink.blob.core.windows.net`) |
| `tags` | map(string) | No | `{}` | Tags to apply |
| `virtual_network_links` | map(object) | No | `{}` | Map of virtual networks to link (see below) |

**Note:** The `location` variable is omitted because `azurerm_private_dns_zone` is a global resource. The `resource_group_name` determines where the metadata is stored, not the geographic location.

### Virtual Network Links Variable Structure

```hcl
variable "virtual_network_links" {
  type = map(object({
    virtual_network_id   = string
    registration_enabled = optional(bool, false)
  }))
  default     = {}
  description = "Map of virtual networks to link. Key is used as the link name."
}
```

### Example Usage

```hcl
module "dns_blob" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//private-dns-zone?ref=private-dns-zone/v1.0.0"

  resource_group_name = "rg-network-dev-weu-001"
  name                = "privatelink.blob.core.windows.net"
  tags                = local.common_tags

  virtual_network_links = {
    main = {
      virtual_network_id   = module.vnet.id
      registration_enabled = false
    }
  }
}
```

### Common Private DNS Zone Names

| Azure Service | DNS Zone Name |
|---------------|---------------|
| Blob Storage | `privatelink.blob.core.windows.net` |
| File Storage | `privatelink.file.core.windows.net` |
| Table Storage | `privatelink.table.core.windows.net` |
| Queue Storage | `privatelink.queue.core.windows.net` |
| Key Vault | `privatelink.vaultcore.azure.net` |
| SQL Database | `privatelink.database.windows.net` |
| Container Registry | `privatelink.azurecr.io` |
| Web Apps | `privatelink.azurewebsites.net` |
| Azure Monitor | `privatelink.monitor.azure.com` |

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `public_dns_zone_id` | DNS zone resource ID (for cross-project consumption — passed to modules that create private endpoints) |
| `virtual_network_link_ids` | Map of link name to link resource ID |

## Notes

- **No location variable:** This is a deliberate deviation from the standard interface. Private DNS zones are global resources. Accepting a `location` variable would be misleading. This is documented in the module README.
- **Zone naming:** Zone names must match Azure's expected private link zone names exactly (e.g., `privatelink.blob.core.windows.net`). The module does not validate or generate these — consumers must provide the correct name.
- **Auto-registration:** The `registration_enabled` flag enables auto-registration of VM DNS records in the zone. This is typically only used for custom DNS zones, not for `privatelink.*` zones. Defaults to `false`.
- **Shared resource:** DNS zones are typically shared across an entire project or organization. They are usually created in a networking project and their IDs are shared via `terraform_remote_state` outputs. The `public_dns_zone_id` output supports this pattern.
- **Multiple zones:** Consumers typically create one DNS zone per Azure service that uses private endpoints. A project with storage and key vault needs at least five zones (blob, file, table, queue, vault). Using `for_each` at the project level is the recommended approach.
