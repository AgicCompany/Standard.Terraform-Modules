# Example: Customer-Managed Keys

Demonstrates storage account encryption with a user-assigned identity and a Key Vault Premium RSA-HSM 3072 key. A commented variant shows how to use a Managed HSM key instead.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

This example is validated, not applied, by the repository checks. Applying it creates billable Azure resources. Choose globally unique Key Vault and storage account names before deployment.

## Prerequisites

- Azure subscription
- Azure CLI authenticated (`az login`)
- Deploying principal with permissions to create the resources and role assignments. It needs RBAC permission to create a key in the vault; the example grants it `Key Vault Crypto Officer` before creating the key.
- Allow time for Azure RBAC assignments to propagate before key creation and storage account creation. Terraform dependencies order the operations but do not wait for RBAC propagation.

## What This Creates

- Resource group `rg-st-cmk-example-dev-weu-001`
- User-assigned managed identity for the storage account
- Key Vault Premium with soft delete, purge protection and RBAC authorization enabled
- RSA-HSM 3072 key, referenced by its versionless ID for automatic key rotation
- `Key Vault Crypto Officer` role assignment for the deploying principal
- `Key Vault Crypto Service Encryption User` role assignment for the storage identity, created by the consumer rather than the module
- Storage account with customer-managed key encryption, secure defaults and no private endpoint

The Managed HSM variant uses `managed_hsm_key_id` instead of `key_vault_key_id` and requires `Managed HSM Crypto Service Encryption User` on the HSM key scope.

## Clean Up

```bash
terraform destroy
```

The vault has purge protection enabled. Deleted vaults and keys remain recoverable for the 7-day retention period and cannot be purged before it ends.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_cmk"></a> [storage\_cmk](#module\_storage\_cmk) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_key.cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.deployer_crypto_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_cmk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity"></a> [identity](#output\_identity) | n/a |
| <a name="output_key_vault_key_versionless_id"></a> [key\_vault\_key\_versionless\_id](#output\_key\_vault\_key\_versionless\_id) | n/a |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | n/a |
<!-- END_TF_DOCS -->
