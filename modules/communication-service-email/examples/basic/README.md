# basic

Azure-managed email domain on an `*.azurecomm.net` subdomain. No senders configured, no engagement tracking, no diagnostics. After apply, ACS exposes the auto-generated `donotreply@<managed>.azurecomm.net` MailFrom — that's what `output.from_address` returns.

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
| <a name="module_acs_email"></a> [acs\_email](#module\_acs\_email) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_from_address"></a> [from\_address](#output\_from\_address) | n/a |
<!-- END_TF_DOCS -->