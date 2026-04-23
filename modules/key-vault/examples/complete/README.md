# Example: Complete Usage

Demonstrates all features of the key-vault module including private endpoint, public access with network ACLs, and RBAC role assignments.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated (`az login`)

## What This Creates

- Resource group `rg-kv-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone for Key Vault

**Key Vault with Private Endpoint (`kv-private-dev-weu-001`):**
- RBAC authorization enabled
- Soft delete (30 days retention)
- Purge protection enabled
- Private endpoint with DNS integration
- VM integration flags enabled (deployment, disk encryption, template deployment)

**Key Vault with Public Access (`kv-public-dev-weu-001`):**
- RBAC authorization enabled
- Soft delete (7 days retention)
- Purge protection disabled (for easy cleanup in dev/test)
- Public network access with network ACLs (IP-restricted)

**Role Assignments:**
- Key Vault Administrator role for the current user on both vaults

## Clean Up

```bash
terraform destroy
```

**Note:** The private Key Vault has purge protection enabled, so it will remain in a soft-deleted state for 30 days. The public Key Vault can be immediately purged since purge protection is disabled.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.69.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_vault_private"></a> [key\_vault\_private](#module\_key\_vault\_private) | ../../ | n/a |
| <a name="module_key_vault_public"></a> [key\_vault\_public](#module\_key\_vault\_public) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.kv_admin_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kv_admin_public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_endpoint_ip"></a> [private\_endpoint\_ip](#output\_private\_endpoint\_ip) | n/a |
| <a name="output_private_vault_id"></a> [private\_vault\_id](#output\_private\_vault\_id) | n/a |
| <a name="output_private_vault_uri"></a> [private\_vault\_uri](#output\_private\_vault\_uri) | n/a |
| <a name="output_public_vault_id"></a> [public\_vault\_id](#output\_public\_vault\_id) | n/a |
| <a name="output_public_vault_uri"></a> [public\_vault\_uri](#output\_public\_vault\_uri) | n/a |
<!-- END_TF_DOCS -->