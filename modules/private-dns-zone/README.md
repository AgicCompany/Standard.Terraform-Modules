# private-dns-zone

**Complexity:** Medium

Creates an Azure Private DNS Zone with virtual network linking for private endpoint DNS resolution.

## Usage

```hcl
module "dns_blob" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//private-dns-zone?ref=private-dns-zone/v1.0.0"

  resource_group_name = "rg-dns-dev-weu-001"
  name                = "privatelink.blob.core.windows.net"

  virtual_network_links = {
    hub-vnet = {
      virtual_network_id = module.hub_vnet.id
    }
  }

  tags = local.common_tags
}
```

## Features

- Private DNS zone creation for any Azure private link DNS name
- Virtual network linking with optional auto-registration
- Map-based VNet links for multi-VNet topologies

## Security Defaults

Private DNS zones are the foundation for private endpoint DNS resolution. No `location` variable is required as DNS zones are global Azure resources.

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Auto-registration | Disabled | `virtual_network_links[*].registration_enabled` |

## Common Zone Names

| Service | DNS Zone Name |
|---------|---------------|
| Blob Storage | `privatelink.blob.core.windows.net` |
| File Storage | `privatelink.file.core.windows.net` |
| Table Storage | `privatelink.table.core.windows.net` |
| Queue Storage | `privatelink.queue.core.windows.net` |
| Key Vault | `privatelink.vaultcore.azure.net` |
| SQL Database | `privatelink.database.windows.net` |
| Container Registry | `privatelink.azurecr.io` |
| Web Apps | `privatelink.azurewebsites.net` |
| Azure Monitor | `privatelink.monitor.azure.com` |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **No location variable:** Private DNS zones are global resources and do not require a location.
- **Auto-registration:** When `registration_enabled = true`, VMs in the linked VNet automatically register A records. Only one VNet link per zone can have auto-registration enabled.
- **DNS records:** Individual DNS record management is deferred to a future version.
- **Conditional forwarders:** On-premises DNS integration (conditional forwarders) is deferred to a future version.
