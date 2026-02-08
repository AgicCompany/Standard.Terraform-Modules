# user-assigned-identity

**Complexity:** Very Simple

Creates an Azure User-Assigned Managed Identity for workload authentication.

## Usage

```hcl
module "identity" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//user-assigned-identity?ref=user-assigned-identity/v1.0.0"

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

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **Identity only:** This module creates the identity resource. Role assignments, federated credentials, and other configurations are the consumer's responsibility.
- **Federated credentials:** Will be added in a future minor version for workload identity federation with GitHub Actions, AKS, etc.
- **Naming:** Provide a fully CAF-compliant name (e.g., `id-<workload>-<env>-<region>-<instance>`).
