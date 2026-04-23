# Example: Complete Usage

Demonstrates Log Analytics workspace creation with custom retention, daily quota, and internet access enabled.

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

- Resource group `rg-log-complete-dev-weu-001`
- Log Analytics workspace `log-complete-dev-weu-001` with:
  - PerGB2018 SKU
  - 90-day retention
  - 5 GB daily ingestion quota
  - Internet ingestion enabled
  - Internet query enabled

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
| <a name="module_log_analytics"></a> [log\_analytics](#module\_log\_analytics) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workspace_guid"></a> [workspace\_guid](#output\_workspace\_guid) | n/a |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | n/a |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | n/a |
<!-- END_TF_DOCS -->