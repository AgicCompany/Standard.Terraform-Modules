# Example: Complete Usage

Demonstrates all features of the key-vault module including private endpoint, public access with network ACLs, and RBAC role assignments.

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

- Resource group `rg-kv-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone for Key Vault

**Key Vault with Private Endpoint (`kv-private-dev-weu-001`):**
- RBAC authorization enabled
- Soft delete (30 days retention)
- Purge protection enabled
- Private endpoint with DNS integration
- VM integration flags enabled (deployment, disk encryption, template deployment)

**Key Vault with Public Access (`kv-public-dev-weu-001`):**
- RBAC authorization enabled
- Soft delete (7 days retention)
- Purge protection disabled (for easy cleanup in dev/test)
- Public network access with network ACLs (IP-restricted)

**Role Assignments:**
- Key Vault Administrator role for the current user on both vaults

## Clean Up

```bash
terraform destroy
```

**Note:** The private Key Vault has purge protection enabled, so it will remain in a soft-deleted state for 30 days. The public Key Vault can be immediately purged since purge protection is disabled.
