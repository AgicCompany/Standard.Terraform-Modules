# mssql-managed-instance

**Complexity:** High

Creates an Azure SQL Managed Instance with secure defaults, always-on transparent data encryption, Advanced Threat Protection, and optional diagnostics.

> **Provisioning time:** create, scale and delete operations on a SQL Managed Instance take hours (up to 24 h; the first instance in a subnet is slowest). Terraform blocks for the whole run — plan CI/agent timeouts accordingly. The module keeps the provider's 24 h timeouts; override via `timeouts` if you need shorter hard limits.

## Usage

```hcl
module "sql_managed_instance" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/mssql-managed-instance?ref=mssql-managed-instance/v1.0.0"

  resource_group_name = "rg-sql-prod-weu-001"
  location            = "westeurope"
  name                = "sqlmi-payments-prod-weu-001"

  # Sizing is deliberately required — no defaults
  subnet_id          = module.vnet.subnet_ids["snet-sqlmi"]
  sku_name           = "GP_Gen5"
  vcores             = 4
  storage_size_in_gb = 32

  azuread_administrator = {
    login_username = "sqlmi-admins"
    object_id      = "00000000-0000-0000-0000-000000000000"
    principal_type = "Group"
  }

  tags = local.common_tags
}
```

## Features

- SQL Managed Instance (General Purpose / Business Critical, Gen5 and Gen8 hardware)
- Microsoft Entra ID administrator (required) with Entra-only authentication by default
- Optional SQL administrator login for mixed authentication
- System-assigned and/or user-assigned managed identity
- Transparent data encryption, always configured: service-managed or customer-managed key (Key Vault, optional auto-rotation)
- Advanced Threat Protection with email notifications
- Zone redundancy, next-gen General Purpose tier, backup storage redundancy, connection type, time zone and maintenance window controls
- `dns_zone_partner_id` pass-through for building failover-group pairs
- Optional multi-sink diagnostic settings

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Entra-only authentication | Enabled | `enable_aad_only_auth` |
| Public data endpoint | Disabled | `enable_public_data_endpoint` |
| Minimum TLS version | 1.2 (only accepted value) | `min_tls_version` |
| Transparent data encryption | Enabled, service-managed key | `customer_managed_key` |
| Advanced Threat Protection | Enabled | `enable_security_alert_policy`, `security_alert_policy` |
| Managed identity | SystemAssigned | `identity` |
| Zone redundancy | Disabled (cost) | `enable_zone_redundancy` |

## Network Prerequisites

The module does **not** create networking. Before applying, the consumer must provide a subnet that:

- is dedicated to SQL Managed Instance (no other resource types),
- is delegated to `Microsoft.Sql/managedInstances`,
- has a network security group **and** a route table associated (Azure's service-aided subnet configuration injects the rules and routes it needs),
- is at least a `/27` (a `/26` or larger is recommended for scaling headroom).

Use the `virtual-network`, `network-security-group` and `route-table` modules, and add a `depends_on` from this module to the subnet associations so the instance is not created before they exist. See `examples/basic`.

## Customer-Managed TDE Key

When `customer_managed_key` is set:

- The Key Vault must have soft delete and purge protection enabled.
- The instance identity (system-assigned principal, or the user-assigned identity in `identity.identity_ids`) needs `Get`, `WrapKey` and `UnwrapKey` on the key — the *Key Vault Crypto Service Encryption User* role on RBAC vaults. Grant it **before** the instance is created. With a system-assigned identity only, the principal does not exist until the instance does, so the first apply fails at the TDE resource; use a user-assigned identity for customer-managed keys (see `examples/complete`).
- Use a versioned key ID unless `auto_rotation_enabled = true`; with auto-rotation a versionless ID is allowed and the deploying principal must be able to read the latest key version.
- TDE can never be removed once enabled. Setting `customer_managed_key` back to `null` switches to a service-managed key in place.

See `examples/complete` for a full Key Vault + user-assigned identity wiring.

## Microsoft Entra Prerequisite

The instance's managed identity needs the **Directory Readers** role in Microsoft Entra ID (or the narrower `User.Read.All`, `GroupMember.Read.All` and `Application.Read.All` Graph permissions) before Entra logins work. Creating the instance with the administrator set succeeds without it, but sign-ins fail until a Privileged Role Administrator grants the role to the identity. With the default Entra-only authentication and no SQL login, an instance without this role has no working login path.

## Notes

Operations that **force replacement** of the instance (hours of downtime and data loss — plan them as migrations):

- Flipping `enable_aad_only_auth` from `true` to `false` and supplying `administrator_login`: Azure generates a login name when the instance is created Entra-only, and `administrator_login` cannot change afterwards. Decide the authentication mode before the first apply.
- Removing a system-assigned identity (`identity.type` from `SystemAssigned` or `SystemAssigned, UserAssigned` to `UserAssigned`).
- Changing `database_format` from `AlwaysUpToDate` back to `SQLServer2022`.
- Setting `dns_zone_partner_id` after creation.
- Changing `collation`, `timezone_id` or `subnet_id`.

Other constraints checked before apply:

- `enable_zone_redundancy = true` requires `storage_account_type` of `ZRS` or `GZRS` (precondition).
- `enable_general_purpose_v2 = true` is only valid with `GP_*` SKUs (rejected by the provider at plan). Zone redundancy on the next-gen General Purpose tier is not generally available.
- `hybrid_secondary_usage = "Passive"` only has an effect with `license_type = "BasePrice"`.

## Public Outputs

These outputs are designed for cross-project state consumption:

- `public_managed_instance_id`
- `public_managed_instance_name`
- `public_managed_instance_fqdn`

## Tests

`tests/validation.tftest.hcl` runs offline against a mocked provider and covers every input validation and precondition:

```bash
terraform init -backend=false
terraform test
```

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.68.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.68.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_mssql_managed_instance.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_instance) | resource |
| [azurerm_mssql_managed_instance_security_alert_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_instance_security_alert_policy) | resource |
| [azurerm_mssql_managed_instance_transparent_data_encryption.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_instance_transparent_data_encryption) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | SQL admin username. Required when enable\_aad\_only\_auth = false. Changing it forces a new instance. | `string` | `null` | no |
| <a name="input_administrator_login_password"></a> [administrator\_login\_password](#input\_administrator\_login\_password) | SQL admin password. Required when enable\_aad\_only\_auth = false. When non-null: min 12 chars; must include upper, lower, digit, and symbol. | `string` | `null` | no |
| <a name="input_azuread_administrator"></a> [azuread\_administrator](#input\_azuread\_administrator) | Microsoft Entra ID administrator. principal\_type must be User, Group, or Application. tenant\_id only when the administrator is homed in another tenant. The instance identity needs the Directory Readers role in Entra ID for logins to work (see README). | <pre>object({<br/>    login_username = string<br/>    object_id      = string<br/>    principal_type = string<br/>    tenant_id      = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_collation"></a> [collation](#input\_collation) | Instance collation. Changing it forces a new instance. | `string` | `"SQL_Latin1_General_CP1_CI_AS"` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer-managed TDE protector key in Azure Key Vault. null = service-managed key. The instance identity needs Get, WrapKey and UnwrapKey on the key. Use a versioned key ID unless auto\_rotation\_enabled = true. | <pre>object({<br/>    key_vault_key_id      = string<br/>    auto_rotation_enabled = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_database_format"></a> [database\_format](#input\_database\_format) | Internal database format tied to the SQL engine version: SQLServer2022 or AlwaysUpToDate. | `string` | `"SQLServer2022"` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Optional diagnostic settings. null disables. Supports multi-sink (Log Analytics, storage account, Event Hub). enabled\_log\_categories = null -> all categories the resource supports. enabled\_metrics = null -> all metrics the resource supports. At least one of log\_analytics\_workspace\_id, storage\_account\_id, or eventhub\_authorization\_rule\_id is required when the object is non-null. | <pre>object({<br/>    name                           = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    enabled_log_categories         = optional(list(string))<br/>    enabled_metrics                = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_dns_zone_partner_id"></a> [dns\_zone\_partner\_id](#input\_dns\_zone\_partner\_id) | ID of another SQL Managed Instance whose DNS zone this instance shares (prerequisite for a failover group). Set at creation only. | `string` | `null` | no |
| <a name="input_enable_aad_only_auth"></a> [enable\_aad\_only\_auth](#input\_enable\_aad\_only\_auth) | Restrict authentication to Microsoft Entra ID only. When false, administrator\_login and administrator\_login\_password are required. Switching from true to false after creation forces instance replacement (see README Notes). | `bool` | `true` | no |
| <a name="input_enable_general_purpose_v2"></a> [enable\_general\_purpose\_v2](#input\_enable\_general\_purpose\_v2) | Use the next-gen General Purpose service tier (GP SKUs only). | `bool` | `false` | no |
| <a name="input_enable_public_data_endpoint"></a> [enable\_public\_data\_endpoint](#input\_enable\_public\_data\_endpoint) | Enable the public data endpoint (TCP 3342). Disabled by default. | `bool` | `false` | no |
| <a name="input_enable_security_alert_policy"></a> [enable\_security\_alert\_policy](#input\_enable\_security\_alert\_policy) | Enable Advanced Threat Protection (security alert policy) on the instance. | `bool` | `true` | no |
| <a name="input_enable_zone_redundancy"></a> [enable\_zone\_redundancy](#input\_enable\_zone\_redundancy) | Deploy the instance across availability zones (extra cost). | `bool` | `false` | no |
| <a name="input_hybrid_secondary_usage"></a> [hybrid\_secondary\_usage](#input\_hybrid\_secondary\_usage) | Hybrid secondary usage for DR: Active or Passive (Passive is license-free for a failover-group secondary with Azure Hybrid Benefit). | `string` | `"Active"` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity. type must be "SystemAssigned", "UserAssigned", or "SystemAssigned, UserAssigned". identity\_ids is required (non-empty) iff type includes UserAssigned. An identity is required for Entra authentication and customer-managed TDE keys. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "type": "SystemAssigned"<br/>}</pre> | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License model: LicenseIncluded (pay-as-you-go) or BasePrice (Azure Hybrid Benefit, requires existing SQL Server licenses with Software Assurance). | `string` | `"LicenseIncluded"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_maintenance_configuration_name"></a> [maintenance\_configuration\_name](#input\_maintenance\_configuration\_name) | Public maintenance configuration window: SQL\_Default or SQL\_{Location}\_MI\_{1\|2} (e.g. SQL\_WestEurope\_MI\_1). | `string` | `"SQL_Default"` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | Minimum TLS version. Only "1.2" is supported; TLS 1.0/1.1 retired by Azure. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | SQL Managed Instance name (full CAF-compliant name, provided by consumer). Must be globally unique. | `string` | n/a | yes |
| <a name="input_proxy_override"></a> [proxy\_override](#input\_proxy\_override) | Connection type: Default, Proxy, or Redirect. | `string` | `"Default"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_security_alert_policy"></a> [security\_alert\_policy](#input\_security\_alert\_policy) | Advanced Threat Protection settings, applied when enable\_security\_alert\_policy = true. disabled\_alerts values: Sql\_Injection, Sql\_Injection\_Vulnerability, Access\_Anomaly, Data\_Exfiltration, Unsafe\_Action, Brute\_Force. | <pre>object({<br/>    email_addresses              = optional(list(string), [])<br/>    email_account_admins_enabled = optional(bool, false)<br/>    disabled_alerts              = optional(list(string), [])<br/>    retention_days               = optional(number, 0)<br/>  })</pre> | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Service tier and hardware generation. No default: sizing an instance that takes hours to (re)provision must be an explicit choice. | `string` | n/a | yes |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | Backup storage redundancy: GRS, GZRS, LRS, or ZRS. | `string` | `"GRS"` | no |
| <a name="input_storage_size_in_gb"></a> [storage\_size\_in\_gb](#input\_storage\_size\_in\_gb) | Maximum storage in GB. Must be a multiple of 32. No default (see sku\_name). | `number` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of the subnet hosting the instance. Must be dedicated to SQL MI, delegated to Microsoft.Sql/managedInstances, and have a network security group and route table associated (consumer responsibility). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Operation timeouts for the instance. Provisioning a SQL Managed Instance can take several hours; the provider defaults (24h) are kept unless overridden. | <pre>object({<br/>    create = optional(string, "24h")<br/>    update = optional(string, "24h")<br/>    delete = optional(string, "24h")<br/>  })</pre> | `{}` | no |
| <a name="input_timezone_id"></a> [timezone\_id](#input\_timezone\_id) | Windows time zone ID the instance operates in (e.g. "W. Europe Standard Time"). Changing it forces a new instance. | `string` | `"UTC"` | no |
| <a name="input_vcores"></a> [vcores](#input\_vcores) | Number of vCores. No default (see sku\_name). | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_zone"></a> [dns\_zone](#output\_dns\_zone) | DNS zone of the instance; pass as dns\_zone\_partner\_id when creating a failover-group secondary |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | Fully qualified domain name of the instance (VNet-local endpoint) |
| <a name="output_id"></a> [id](#output\_id) | SQL Managed Instance resource ID |
| <a name="output_name"></a> [name](#output\_name) | SQL Managed Instance name |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID (null when only user-assigned) |
| <a name="output_public_managed_instance_fqdn"></a> [public\_managed\_instance\_fqdn](#output\_public\_managed\_instance\_fqdn) | SQL Managed Instance FQDN (for cross-project consumption) |
| <a name="output_public_managed_instance_id"></a> [public\_managed\_instance\_id](#output\_public\_managed\_instance\_id) | SQL Managed Instance resource ID (for cross-project consumption) |
| <a name="output_public_managed_instance_name"></a> [public\_managed\_instance\_name](#output\_public\_managed\_instance\_name) | SQL Managed Instance name (for cross-project consumption) |
| <a name="output_security_alert_policy_id"></a> [security\_alert\_policy\_id](#output\_security\_alert\_policy\_id) | Security alert policy resource ID (when enabled) |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned managed identity tenant ID (null when only user-assigned) |
| <a name="output_transparent_data_encryption_id"></a> [transparent\_data\_encryption\_id](#output\_transparent\_data\_encryption\_id) | TDE encryption protector resource ID |
<!-- END_TF_DOCS -->
