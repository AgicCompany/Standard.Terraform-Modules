# mssql-server

**Complexity:** Medium

Creates an Azure SQL logical server with secure defaults, Azure AD authentication, and optional private endpoint.

## Usage

```hcl
module "sql_server" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/mssql-server?ref=mssql-server/v1.1.0"

  resource_group_name = "rg-sql-dev-weu-001"
  location            = "westeurope"
  name                = "sql-payments-dev-weu-001"

  azuread_administrator = {
    login_username = "sqladmin@contoso.com"
    object_id      = "00000000-0000-0000-0000-000000000000"
  }

  # Private endpoint (required inputs when enable_private_endpoint = true)
  subnet_id           = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id = module.private_dns.zone_ids["privatelink.database.windows.net"]

  tags = local.common_tags
}
```

## Features

- SQL logical server with configurable version
- Azure AD administrator (required)
- Azure AD-only authentication (default, most secure)
- Private endpoint with DNS integration
- System-assigned managed identity (always enabled)
- Configurable connection policy (Default, Proxy, Redirect)
- Optional SQL administrator login for hybrid auth scenarios

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Minimum TLS | 1.2 | `minimum_tls_version` |
| Public access | Disabled | `enable_public_access` |
| Private endpoint | Enabled | `enable_private_endpoint` |
| Azure AD only auth | Enabled | `enable_aad_only_auth` |

## Private Endpoint

When `enable_private_endpoint = true` (default), the following inputs are required:

| Variable | Description |
|----------|-------------|
| `subnet_id` | Subnet ID for the private endpoint |
| `private_dns_zone_id` | Private DNS zone ID for `privatelink.database.windows.net` |

The module creates the private endpoint and configures DNS zone group registration.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_sql_server_id` | SQL Server resource ID |
| `public_sql_server_name` | SQL Server name |
| `public_sql_server_fqdn` | SQL Server FQDN |

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
| [azurerm_mssql_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | SQL admin username. Required when enable\_aad\_only\_auth = false. | `string` | `null` | no |
| <a name="input_administrator_login_password"></a> [administrator\_login\_password](#input\_administrator\_login\_password) | SQL admin password. Required when enable\_aad\_only\_auth = false. | `string` | `null` | no |
| <a name="input_azuread_administrator"></a> [azuread\_administrator](#input\_azuread\_administrator) | Azure AD administrator configuration | <pre>object({<br/>    login_username = string<br/>    object_id      = string<br/>  })</pre> | n/a | yes |
| <a name="input_connection_policy"></a> [connection\_policy](#input\_connection\_policy) | Connection policy: Default, Proxy, or Redirect | `string` | `"Default"` | no |
| <a name="input_enable_aad_only_auth"></a> [enable\_aad\_only\_auth](#input\_enable\_aad\_only\_auth) | Restrict authentication to Azure AD only | `bool` | `true` | no |
| <a name="input_enable_outbound_networking_restriction"></a> [enable\_outbound\_networking\_restriction](#input\_enable\_outbound\_networking\_restriction) | Restrict outbound networking access from the SQL server | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for this SQL server | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | Minimum TLS version | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | SQL Server name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.database.windows.net. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_version_number"></a> [version\_number](#input\_version\_number) | SQL Server version | `string` | `"12.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fully_qualified_domain_name"></a> [fully\_qualified\_domain\_name](#output\_fully\_qualified\_domain\_name) | Fully qualified domain name of the SQL server |
| <a name="output_id"></a> [id](#output\_id) | SQL Server resource ID |
| <a name="output_name"></a> [name](#output\_name) | SQL Server name |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_sql_server_fqdn"></a> [public\_sql\_server\_fqdn](#output\_public\_sql\_server\_fqdn) | SQL Server FQDN (for cross-project consumption) |
| <a name="output_public_sql_server_id"></a> [public\_sql\_server\_id](#output\_public\_sql\_server\_id) | SQL Server resource ID (for cross-project consumption) |
| <a name="output_public_sql_server_name"></a> [public\_sql\_server\_name](#output\_public\_sql\_server\_name) | SQL Server name (for cross-project consumption) |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned managed identity tenant ID |
<!-- END_TF_DOCS -->

## Notes

- **Azure AD-only authentication:** Default is `enable_aad_only_auth = true`, which disables SQL authentication entirely. This is the Microsoft-recommended security posture. When enabled, `administrator_login` and `administrator_login_password` are not required. When disabled, SQL auth is available alongside Azure AD auth, and the SQL admin credentials must be provided.
- **SQL admin password from Key Vault:** When SQL auth is enabled, the consumer retrieves the admin password from Key Vault using a `data.azurerm_key_vault_secret` block and passes it to this module. The module does not interact with Key Vault directly.
- **Naming constraint:** SQL server names must be globally unique, 1-63 characters, lowercase alphanumeric and hyphens. CAF prefix: `sql`. Example: `sql-payments-dev-weu-001`.
- **Minimum TLS version:** Only `"1.2"` is accepted. TLS 1.0 and 1.1 were retired by Azure on 2025-08-31.
- **`version = "12.0"`:** This is the only version currently supported by Azure. The variable exists for forward compatibility.
- **Connection policy:** `Default` uses Redirect within Azure and Proxy from outside Azure. `Redirect` has better performance for Azure-to-Azure connections. `Proxy` forces all connections through the Azure SQL gateway. For private endpoint access, `Default` is fine.
- **System-assigned identity:** Always enabled on the server to support features like TDE with CMK and Azure AD integration.
- **Relationship to mssql-database:** This module creates the logical server. The `mssql-database` module creates individual databases within the server. The server `id` output is the link between them.
