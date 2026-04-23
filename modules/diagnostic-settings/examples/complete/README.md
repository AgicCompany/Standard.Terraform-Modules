# Example: Complete Usage

Demonstrates diagnostic settings with selective log categories, dedicated tables, and multiple target resources.

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

- Resource group `rg-diag-complete-dev-weu-001`
- Log Analytics workspace `log-diag-complete-dev-weu-001`
- Key Vault `kv-diagcm-dev-weu-001`
- Key Vault `kv-diagcm-dev-weu-002`

**Diagnostic Settings:**
- Key Vault 1: selective categories (AuditEvent, AzurePolicyEvaluationDetails) with dedicated tables
- Key Vault 2: all categories (default) with dedicated tables

## Clean Up

```bash
terraform destroy
```

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_diag_keyvault_all"></a> [diag\_keyvault\_all](#module\_diag\_keyvault\_all) | ../../ | n/a |
| <a name="module_diag_keyvault_selective"></a> [diag\_keyvault\_selective](#module\_diag\_keyvault\_selective) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault.example2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_keyvault_all_diag_id"></a> [keyvault\_all\_diag\_id](#output\_keyvault\_all\_diag\_id) | n/a |
| <a name="output_keyvault_selective_diag_id"></a> [keyvault\_selective\_diag\_id](#output\_keyvault\_selective\_diag\_id) | n/a |
<!-- END_TF_DOCS -->