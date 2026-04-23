# Example: Complete Usage

Deploys an API Management service with private endpoint, managed identity, and client certificates.

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

- Resource group `rg-apim-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone `privatelink.azure-api.net` linked to the VNet
- API Management service `apim-complete-dev-weu-001` with:
  - Developer SKU (capacity 1)
  - SystemAssigned managed identity
  - Client certificate authentication enabled
  - Private endpoint with DNS integration
  - Public access disabled (default)

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.69.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apim"></a> [apim](#module\_apim) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apim_gateway_url"></a> [apim\_gateway\_url](#output\_apim\_gateway\_url) | n/a |
| <a name="output_apim_id"></a> [apim\_id](#output\_apim\_id) | n/a |
| <a name="output_apim_principal_id"></a> [apim\_principal\_id](#output\_apim\_principal\_id) | n/a |
| <a name="output_private_endpoint_ip"></a> [private\_endpoint\_ip](#output\_private\_endpoint\_ip) | n/a |
<!-- END_TF_DOCS -->