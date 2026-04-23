# Example: Complete Usage

Deploys an Event Hub namespace with multiple event hubs, consumer groups, and private endpoint.

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

- Resource group `rg-evh-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone `privatelink.servicebus.windows.net` linked to the VNet
- Event Hub namespace `evh-complete-dev-weu-001` with:
  - Standard SKU with auto-inflate (up to 10 throughput units)
  - Private endpoint with DNS integration
  - Local authentication disabled (default)
  - Public access disabled (default)
  - TLS 1.2 minimum
- Event hub `events` with 4 partitions, 7 day retention, and `analytics` consumer group
- Event hub `telemetry` with 2 partitions and 1 day retention
- Namespace authorization rule `app-sender` with send permission

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
| <a name="module_event_hub"></a> [event\_hub](#module\_event\_hub) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_consumer_group_ids"></a> [consumer\_group\_ids](#output\_consumer\_group\_ids) | n/a |
| <a name="output_event_hub_namespace_id"></a> [event\_hub\_namespace\_id](#output\_event\_hub\_namespace\_id) | n/a |
| <a name="output_eventhub_ids"></a> [eventhub\_ids](#output\_eventhub\_ids) | n/a |
| <a name="output_private_endpoint_ip"></a> [private\_endpoint\_ip](#output\_private\_endpoint\_ip) | n/a |
<!-- END_TF_DOCS -->