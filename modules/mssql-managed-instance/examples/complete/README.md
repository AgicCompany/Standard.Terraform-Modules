# Example: Complete Usage

Demonstrates every feature of the module: Business Critical tier with Azure Hybrid Benefit, mixed Entra + SQL authentication, system- and user-assigned identities, customer-managed TDE key in Key Vault with auto-rotation, zone redundancy, Redirect connection type, Advanced Threat Protection with email alerts, and diagnostics to Log Analytics.

## Usage

```bash
export TF_VAR_sql_admin_password='<min 12 chars, upper/lower/digit/symbol>'
terraform init
terraform plan
terraform apply
```

> **Provisioning time:** creating a SQL Managed Instance takes several hours (up to 24 h). Terraform blocks for the whole duration.

## Prerequisites

- Azure subscription with SQL Server licenses + Software Assurance (for `license_type = "BasePrice"`), or change it to `LicenseIncluded`
- Azure CLI authenticated; the signed-in user becomes the Entra administrator and is granted *Key Vault Crypto Officer* to create the TDE key
- The Key Vault name must be globally unique — change `kv-sqlmi-ex-prod-weu-001` before applying

## What This Creates

- Resource group, virtual network, delegated subnet, NSG and route table
- Log Analytics workspace `law-sqlmi-example-prod-weu-001`
- User-assigned identity `id-sqlmi-example-prod-weu-001` with *Key Vault Crypto Service Encryption User* on the vault
- Key Vault (RBAC, purge protection) and RSA-2048 key `sqlmi-tde-protector`
- SQL Managed Instance `sqlmi-payments-prod-weu-001` with:
  - `BC_Gen5`, 8 vCores, 256 GB, Azure Hybrid Benefit, zone-redundant, ZRS backups
  - Entra administrator plus SQL login `sqladmin`
  - Customer-managed TDE protector (versionless key, auto-rotation)
  - Redirect connection type, W. Europe time zone, `SQL_WestEurope_MI_1` maintenance window
  - Advanced Threat Protection emailing `security@contoso.com` and account admins, 30-day retention
  - All diagnostic log categories and metrics to Log Analytics

## Clean Up

```bash
terraform destroy
```

The Key Vault has purge protection enabled; it is soft-deleted on destroy and the name stays reserved for 90 days.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sql_managed_instance"></a> [sql\_managed\_instance](#module\_sql\_managed\_instance) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_key.tde](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_network_security_group.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.deployer_crypto_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.sqlmi_crypto_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_route_table.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_user_assigned_identity.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sql_admin_password"></a> [sql\_admin\_password](#input\_sql\_admin\_password) | SQL administrator password (min 12 chars, upper/lower/digit/symbol). Supplied via TF\_VAR\_sql\_admin\_password. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_instance_dns_zone"></a> [managed\_instance\_dns\_zone](#output\_managed\_instance\_dns\_zone) | n/a |
| <a name="output_managed_instance_fqdn"></a> [managed\_instance\_fqdn](#output\_managed\_instance\_fqdn) | n/a |
| <a name="output_managed_instance_id"></a> [managed\_instance\_id](#output\_managed\_instance\_id) | n/a |
| <a name="output_managed_instance_principal_id"></a> [managed\_instance\_principal\_id](#output\_managed\_instance\_principal\_id) | n/a |
<!-- END_TF_DOCS -->
