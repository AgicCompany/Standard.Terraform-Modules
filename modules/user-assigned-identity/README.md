# user-assigned-identity

**Complexity:** Low

Creates an Azure User-Assigned Managed Identity for workload authentication.

## Usage

```hcl
module "identity" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/user-assigned-identity?ref=user-assigned-identity/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "id-payments-dev-weu-001"

  tags = local.common_tags
}
```

## Features

- User-assigned managed identity creation
- Standard outputs for principal ID, client ID, and tenant ID
- Public outputs for cross-project consumption

## Security Defaults

This module creates a managed identity only. Role assignments are the consumer's responsibility and should follow the principle of least privilege.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_identity_id` | User-assigned identity resource ID (for cross-project consumption) |
| `public_principal_id` | Service principal ID (for cross-project consumption) |
| `public_client_id` | Client ID (for cross-project consumption) |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | User-assigned identity name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | Client ID associated with the identity |
| <a name="output_id"></a> [id](#output\_id) | User-assigned identity resource ID |
| <a name="output_name"></a> [name](#output\_name) | User-assigned identity name |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | Service principal ID associated with the identity |
| <a name="output_public_client_id"></a> [public\_client\_id](#output\_public\_client\_id) | Client ID (for cross-project consumption) |
| <a name="output_public_identity_id"></a> [public\_identity\_id](#output\_public\_identity\_id) | User-assigned identity resource ID (for cross-project consumption) |
| <a name="output_public_principal_id"></a> [public\_principal\_id](#output\_public\_principal\_id) | Service principal ID (for cross-project consumption) |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Tenant ID associated with the identity |
<!-- END_TF_DOCS -->

## Notes

- **Identity only:** This module creates the identity resource. Role assignments, federated credentials, and other configurations are the consumer's responsibility.
- **Federated credentials:** Will be added in a future minor version for workload identity federation with GitHub Actions, AKS, etc.
- **Naming:** Provide a fully CAF-compliant name (e.g., `id-<workload>-<env>-<region>-<instance>`).
