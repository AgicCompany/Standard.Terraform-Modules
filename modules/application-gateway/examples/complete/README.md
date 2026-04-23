# Example: Complete Usage

Deploys an Application Gateway with multiple backends, health probes, URL routing, and autoscaling.

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

- Resource group `rg-appgw-complete-dev-weu-001`
- Virtual network `vnet-appgw-complete-dev-weu-001` with address space `10.0.0.0/16`
- Subnet `snet-appgw` with address prefix `10.0.1.0/24`
- Application Gateway `agw-complete-dev-weu-001` (Standard_v2, zone-redundant)
- Public IP `pip-agw-complete-dev-weu-001`
- Two backend pools (web servers with IPs, API servers with FQDNs)
- Two backend HTTP settings (HTTP and HTTPS with health probe)
- Health probe for API backend
- Two HTTP listeners
- Two routing rules
- Redirect configuration
- Autoscale: min 2, max 10

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
| <a name="module_application_gateway"></a> [application\_gateway](#module\_application\_gateway) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_address_pool_ids"></a> [backend\_address\_pool\_ids](#output\_backend\_address\_pool\_ids) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | n/a |
<!-- END_TF_DOCS -->