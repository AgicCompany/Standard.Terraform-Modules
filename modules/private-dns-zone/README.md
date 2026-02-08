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
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Private DNS zone name (e.g., privatelink.blob.core.windows.net) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_virtual_network_links"></a> [virtual\_network\_links](#input\_virtual\_network\_links) | Map of virtual network links. Key is used as the link name. | <pre>map(object({<br/>    virtual_network_id   = string<br/>    registration_enabled = optional(bool, false)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Private DNS zone resource ID |
| <a name="output_name"></a> [name](#output\_name) | Private DNS zone name |
| <a name="output_public_dns_zone_id"></a> [public\_dns\_zone\_id](#output\_public\_dns\_zone\_id) | Private DNS zone resource ID (for cross-project consumption) |
| <a name="output_virtual_network_link_ids"></a> [virtual\_network\_link\_ids](#output\_virtual\_network\_link\_ids) | Map of link name to virtual network link resource ID |
<!-- END_TF_DOCS -->

## Notes

- **No location variable:** Private DNS zones are global resources and do not require a location.
- **Auto-registration:** When `registration_enabled = true`, VMs in the linked VNet automatically register A records. Only one VNet link per zone can have auto-registration enabled.
- **DNS records:** Individual DNS record management is deferred to a future version.
- **Conditional forwarders:** On-premises DNS integration (conditional forwarders) is deferred to a future version.
