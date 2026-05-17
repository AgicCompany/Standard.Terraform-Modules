# ai-foundry

Provisions an Azure AI Foundry hub (`Microsoft.MachineLearningServices/workspaces` kind = Hub) with a default project. Optionally creates a private endpoint and diagnostic settings.

> **Note on resource flavour.** This module wraps the AML-workspace-based AI Foundry hub. The newer Cognitive-Services-backed "AI Foundry account" is a different Azure resource (`azurerm_cognitive_account` or `azurerm_ai_services`); use a different module for that. The private-link subresource for this module is `amlworkspace`, and the private DNS zones are `privatelink.api.azureml.ms` and `privatelink.notebooks.azure.net` — not `privatelink.cognitiveservices.azure.com`.

## Required role assignments

The hub's managed identity (system- or user-assigned) needs RBAC on the backing storage account and key vault to function. The module does not grant these; consumers must wire `azurerm_role_assignment` separately. Minimum:

- Storage account: `Storage Blob Data Contributor` to the hub MSI.
- Key Vault: `Key Vault Administrator` (or fine-grained equivalents) to the hub MSI.

## ForceNew foot-guns

Changing any of these on the hub destroys it (and cascade-destroys the default project): `name`, `location`, `resource_group_name`, `key_vault_id`, `storage_account_id`, `high_business_impact_enabled`, the entire `encryption` block. Changing the project's `name`, `location`, or `high_business_impact_enabled` destroys the project. Toggling `encryption` from null to non-null (or vice versa) rebuilds the hub.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
