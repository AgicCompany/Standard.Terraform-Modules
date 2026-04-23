# Example: Complete Usage

Demonstrates all features of the container-app module including probes, init containers, scale rules, secrets, and managed identity.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated
- Existing resource group (or modify example to create one)

## What This Creates

- Resource group `rg-ca-complete-dev-weu-001`
- Log Analytics workspace `law-ca-complete-dev-weu-001`
- Virtual network with a `/21` subnet delegated to `Microsoft.App/environments`
- Container Apps Environment `cae-complete-dev-weu-001` with:
  - Internal load balancer
  - Dedicated workload profile (D4)
- Container App `ca-api-complete-dev-weu-001` with:
  - Hello-world container image (0.5 CPU / 1Gi memory)
  - HTTP ingress on port 80 (external)
  - Liveness, readiness, and startup probes
  - Init container for database migrations
  - Secret-referenced environment variable
  - HTTP scale rule (1-5 replicas, 50 concurrent requests)
  - System-assigned managed identity
  - Dedicated workload profile

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
| <a name="module_container_app"></a> [container\_app](#module\_container\_app) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_environment.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.cae](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_fqdn"></a> [container\_app\_fqdn](#output\_container\_app\_fqdn) | n/a |
| <a name="output_container_app_id"></a> [container\_app\_id](#output\_container\_app\_id) | n/a |
| <a name="output_container_app_outbound_ips"></a> [container\_app\_outbound\_ips](#output\_container\_app\_outbound\_ips) | n/a |
| <a name="output_container_app_principal_id"></a> [container\_app\_principal\_id](#output\_container\_app\_principal\_id) | n/a |
<!-- END_TF_DOCS -->