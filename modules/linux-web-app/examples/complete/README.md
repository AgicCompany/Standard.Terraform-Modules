# Example: Complete Usage

Demonstrates all features of the linux-web-app module including Docker application stack, private endpoint, VNet integration, managed identities, application settings, and connection strings.

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

- Resource group `rg-webapp-complete-dev-weu-001`
- Virtual network with private endpoint and VNet integration subnets
- Private DNS zone `privatelink.azurewebsites.net` linked to the VNet
- App Service Plan `asp-webapp-complete-dev-weu-001` (Linux, P1v3 SKU)
- User-assigned managed identity
- Linux Web App `app-complete-dev-weu-001` with:
  - Docker application stack (nginx)
  - Private endpoint with DNS integration
  - VNet integration for outbound traffic
  - System-assigned and user-assigned managed identities
  - Application settings and connection strings
  - Health check path (`/health`)
  - Always-on enabled
  - HTTPS only, TLS 1.2 minimum, FTPS disabled

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
| <a name="module_web_app"></a> [web\_app](#module\_web\_app) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.webapps](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.webapps](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.vnet_integration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_endpoint_ip"></a> [private\_endpoint\_ip](#output\_private\_endpoint\_ip) | n/a |
| <a name="output_web_app_hostname"></a> [web\_app\_hostname](#output\_web\_app\_hostname) | n/a |
| <a name="output_web_app_id"></a> [web\_app\_id](#output\_web\_app\_id) | n/a |
| <a name="output_web_app_principal_id"></a> [web\_app\_principal\_id](#output\_web\_app\_principal\_id) | n/a |
<!-- END_TF_DOCS -->