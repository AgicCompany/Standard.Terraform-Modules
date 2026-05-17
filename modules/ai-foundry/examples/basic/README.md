# basic

Minimum-viable AI Foundry hub + default project on Microsoft-managed encryption with a SystemAssigned identity, public network access disabled, no private endpoint, no diagnostics.

To deploy you'll also need to grant the hub MSI `Storage Blob Data Contributor` on the storage account and `Key Vault Administrator` on the Key Vault — see the module README.
