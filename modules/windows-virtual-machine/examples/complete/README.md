# Example: Complete Usage

Demonstrates all features of the windows-virtual-machine module including identity, boot diagnostics, hybrid benefit, and data disks.

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

- Resource group `rg-winvm-complete-dev-weu-001`
- Virtual network with compute subnet
- Random password (generated for convenience)
- Windows VM `vm-wincm-dev-001` with:
  - Standard_B2s size in zone 1
  - Windows Server 2022 Datacenter Gen2
  - Password authentication
  - Azure Hybrid Benefit enabled
  - W. Europe Standard Time timezone
  - System-assigned managed identity
  - Boot diagnostics (managed storage)
  - One 64GB Premium data disk

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
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_virtual_machine"></a> [virtual\_machine](#module\_virtual\_machine) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_password.example](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | n/a |
| <a name="output_vm_principal_id"></a> [vm\_principal\_id](#output\_vm\_principal\_id) | n/a |
| <a name="output_vm_private_ip"></a> [vm\_private\_ip](#output\_vm\_private\_ip) | n/a |
<!-- END_TF_DOCS -->