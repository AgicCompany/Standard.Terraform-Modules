# Example: Complete Usage

Demonstrates every feature of the module: Business Critical tier with Azure Hybrid Benefit, mixed Entra + SQL authentication, system- and user-assigned identities, customer-managed TDE key in Key Vault with auto-rotation, zone redundancy, Redirect connection type, Advanced Threat Protection with email alerts, and diagnostics to Log Analytics.

## Usage

```bash
export TF_VAR_sql_admin_password='<min 12 chars, upper/lower/digit/symbol>'
terraform init
terraform plan
terraform apply
```

> **Provisioning time:** creating a SQL Managed Instance takes several hours (up to 24 h). Terraform blocks for the whole duration.

## Prerequisites

- Azure subscription with SQL Server licenses + Software Assurance (for `license_type = "BasePrice"`), or change it to `LicenseIncluded`
- Azure CLI authenticated; the signed-in user becomes the Entra administrator and is granted *Key Vault Crypto Officer* to create the TDE key
- The Key Vault name must be globally unique — change `kv-sqlmi-ex-prod-weu-001` before applying

## What This Creates

- Resource group, virtual network, delegated subnet, NSG and route table
- Log Analytics workspace `law-sqlmi-example-prod-weu-001`
- User-assigned identity `id-sqlmi-example-prod-weu-001` with *Key Vault Crypto Service Encryption User* on the vault
- Key Vault (RBAC, purge protection) and RSA-2048 key `sqlmi-tde-protector`
- SQL Managed Instance `sqlmi-payments-prod-weu-001` with:
  - `BC_Gen5`, 8 vCores, 256 GB, Azure Hybrid Benefit, zone-redundant, ZRS backups
  - Entra administrator plus SQL login `sqladmin`
  - Customer-managed TDE protector (versionless key, auto-rotation)
  - Redirect connection type, W. Europe time zone, `SQL_WestEurope_MI_1` maintenance window
  - Advanced Threat Protection emailing `security@contoso.com` and account admins, 30-day retention
  - All diagnostic log categories and metrics to Log Analytics

## Clean Up

```bash
terraform destroy
```

The Key Vault has purge protection enabled; it is soft-deleted on destroy and the name stays reserved for 90 days.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
