# Example: Complete Usage

Demonstrates all features of the service-bus module including Premium SKU, private endpoint, queues, topics, and subscriptions.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated

## What This Creates

- Resource group `rg-servicebus-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone `privatelink.servicebus.windows.net` linked to the VNet
- Service Bus namespace `sb-complete-dev-weu-001` with:
  - Premium SKU with 1 messaging unit
  - Local auth disabled
  - Private endpoint with DNS integration
  - Two queues: `orders` and `notifications`
  - Two topics: `events` (with 2 subscriptions) and `commands` (with 1 subscription)

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
| <a name="module_service_bus"></a> [service\_bus](#module\_service\_bus) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.servicebus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.servicebus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace_endpoint"></a> [namespace\_endpoint](#output\_namespace\_endpoint) | n/a |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | n/a |
| <a name="output_private_endpoint_ip"></a> [private\_endpoint\_ip](#output\_private\_endpoint\_ip) | n/a |
| <a name="output_queue_ids"></a> [queue\_ids](#output\_queue\_ids) | n/a |
| <a name="output_topic_ids"></a> [topic\_ids](#output\_topic\_ids) | n/a |
<!-- END_TF_DOCS -->