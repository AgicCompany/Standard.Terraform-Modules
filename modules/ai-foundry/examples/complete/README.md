# complete

Demonstrates the full feature surface of `ai-foundry`:

- BYO storage, Key Vault, Application Insights, Container Registry.
- Combined SystemAssigned + UserAssigned identity.
- `managed_network_isolation_mode = "AllowOnlyApprovedOutbound"`.
- Private endpoint with both required private DNS zones (`privatelink.api.azureml.ms`, `privatelink.notebooks.azure.net`).
- Diagnostic settings to a Log Analytics workspace.
- High Business Impact mode enabled.

You still need to grant RBAC to the UAMI on the storage account and Key Vault — not shown here to keep the example focused on the module surface.
