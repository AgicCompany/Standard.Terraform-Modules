# Terraform Framework Specification

## Phase 1: Foundation & Standards | Phase 2: Module Architecture | Phase 3: State & Backend | Phase 4: Environment Management | Phase 5: CI/CD Pipeline | Phase 6: Governance & Onboarding

**Version:** 1.0  
**Status:** Draft  
**Author:** Infrastructure Team  
**Target Audience:** Infrastructure Team, Development Teams  
**Cloud Provider:** Microsoft Azure

---

## 1. Overview

This document defines the standards and conventions for using Terraform within the organization. The framework establishes a consistent approach for infrastructure deployment across all teams and projects.

**Goals:**

- Standardize Terraform usage across teams
- Ensure consistency between environments
- Enable reusability through shared modules
- Establish clear conventions for naming and tagging
- Provide a foundation for CI/CD integration

---

## 2. Repository Types

The framework defines two repository types:

1. **Terraform Modules Repo** — Central source of truth for reusable modules, maintained by infra team
2. **Project Repo** — Contains app code, infrastructure, and pipelines

---

## 3. Project Repository Structure

Project repositories contain application source code, Terraform infrastructure, and CI/CD pipelines.

### 3.1 Top-Level Layout

```
project-repo/
├── src/                          # App source code
├── infrastructures/
│   └── iac/                      # Terraform code
├── ops/                          # CI/CD definitions
│   ├── infrastructure.yml
│   └── app.yml
└── README.md
```

### 3.2 Terraform Directory Layout (infrastructures/iac/)

All Terraform code follows a flat structure with environment-specific variable files. This ensures all environments use identical infrastructure code with only configuration differences.

```
infrastructures/iac/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── locals.tf
├── data.tf
├── versions.tf
├── terraform.tfvars
├── environments/
│   ├── dev.tfvars
│   ├── dev.backend.tfvars
│   ├── test.tfvars
│   ├── test.backend.tfvars
│   ├── stg.tfvars
│   ├── stg.backend.tfvars
│   ├── prod.tfvars
│   └── prod.backend.tfvars
├── modules/                      # Only if remote modules not possible
│   └── MODULES.md
├── bootstrap/
│   ├── bootstrap.sh
│   ├── bootstrap.ps1
│   └── README.md
├── .gitignore
├── .terraform-version
├── .terraform.lock.hcl
└── README.md
```

### 3.3 Terraform Files

| File/Directory | Purpose |
|----------------|---------|
| `main.tf` | Primary resource definitions |
| `variables.tf` | Input variable declarations |
| `outputs.tf` | Output declarations |
| `providers.tf` | Provider configuration (azurerm, etc.) |
| `locals.tf` | Local values, naming logic, computed values, tags |
| `data.tf` | Data sources |
| `versions.tf` | Terraform and provider version constraints |
| `terraform.tfvars` | Common default values shared across all environments |
| `environments/` | Environment-specific configuration files |
| `modules/` | Local modules (only when remote not possible) |
| `bootstrap/` | Bootstrap scripts for state storage setup |
| `.gitignore` | Git ignore patterns |
| `.terraform-version` | Terraform version pin (for tfenv) |
| `.terraform.lock.hcl` | Provider dependency lock file (commit this) |
| `README.md` | Terraform documentation |

### 3.4 Environment Files

Each environment requires two configuration files within the `environments/` directory:

| File Pattern | Purpose |
|--------------|---------|
| `<env>.tfvars` | Environment-specific variable values |
| `<env>.backend.tfvars` | Environment-specific backend configuration |

**Standard environments:** dev, test, stg, prod

### 3.5 File Splitting Convention

When `main.tf` exceeds approximately 150-200 lines, split by resource domain. Name files after the resource domain, not Azure resource types. Keep related resources together.

| File | Contents |
|------|----------|
| `network.tf` | VNets, subnets, NSGs, peerings |
| `storage.tf` | Storage accounts, containers |
| `compute.tf` | VMs, VMSS, availability sets |
| `database.tf` | SQL, CosmosDB, etc. |
| `identity.tf` | Managed identities, role assignments |
| `monitoring.tf` | Log analytics, alerts, diagnostics |

### 3.6 Usage Pattern

Initialize for a specific environment (from `infrastructures/iac/` directory):

```bash
terraform init -backend-config=environments/dev.backend.tfvars
```

Plan and apply with common values plus environment overrides:

```bash
terraform plan -var-file=terraform.tfvars -var-file=environments/dev.tfvars
terraform apply -var-file=terraform.tfvars -var-file=environments/dev.tfvars
```

**Note:** Later var-file wins on conflicts, so environment-specific values override common defaults.

---

## 4. Local Modules

When remote modules are not accessible (e.g., project on client's Azure DevOps), modules can be copied locally.

### 4.1 Local Modules Directory

```
infrastructures/iac/
├── modules/
│   ├── storage-account/
│   ├── key-vault/
│   └── MODULES.md
```

### 4.2 Module Sourcing Priority

1. **Remote first** — Use modules from central `terraform-modules` repo
2. **Local fallback** — Copy to `modules/` only if remote not accessible

### 4.3 Remote vs Local Sourcing

```hcl
# Remote (standard)
module "storage" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/storage-account?ref=storage-account/v1.2.0"
}

# Local (when remote not possible)
module "storage" {
  source = "./modules/storage-account"
}
```

### 4.4 Version Tracking (MODULES.md)

Document copied module versions:

```markdown
# Local Modules

Modules copied from central terraform-modules repository.

| Module | Source Version | Copy Date | Notes |
|--------|----------------|-----------|-------|
| storage-account | v1.2.0 | 2024-02-15 | — |
| key-vault | v2.0.1 | 2024-02-15 | — |

## Updating

To update a module:
1. Check latest version in terraform-modules repo
2. Copy new version to this folder
3. Update this table
4. Test in dev environment
```

### 4.5 Local Module Standards

Local modules must follow:

- Same folder structure as central modules (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`)
- Same interface standards (`name`, `location`, `resource_group_name`, `tags`)

Versioning and changelog are not required for local copies.

### 4.6 Update Responsibility

- No formal update process
- Handle updates case-by-case when issues arise
- Project team responsible for their local copies

---

## 5. Resource Naming Convention

Resource naming follows Microsoft Cloud Adoption Framework (CAF) conventions. Project names must be a maximum of 12 characters, lowercase, no hyphens.

### 5.1 Standard Pattern

Resources with hyphen support:

```
<resource-prefix>-<project>-<environment>-<region>-<instance>
```

Resources with restrictions (no hyphens, length limits):

```
<resource-prefix><project><environment><region><instance>
```

### 5.2 Naming Components

| Component | Description | Example |
|-----------|-------------|---------|
| resource-prefix | CAF abbreviation for resource type | rg, vnet, st, kv |
| project | Project name (max 12 chars) | payments |
| environment | Environment abbreviation | dev, test, stg, prod |
| region | 3-letter region code | weu, neu, eus |
| instance | 3-digit instance number | 001, 002 |

### 5.3 Resource Examples

| Resource | Pattern | Example |
|----------|---------|---------|
| Resource Group | `rg-<project>-<env>-<region>-<instance>` | rg-payments-dev-weu-001 |
| Virtual Network | `vnet-<project>-<env>-<region>-<instance>` | vnet-payments-dev-weu-001 |
| Subnet | `snet-<purpose>-<env>-<instance>` | snet-frontend-dev-001 |
| Storage Account | `st<project><env><region><instance>` | stpaymentsdevweu001 |
| Key Vault | `kv-<project>-<env>-<region>-<instance>` | kv-payments-dev-weu-001 |
| VM | `vm-<project>-<role>-<env>-<instance>` | vm-payments-web-dev-001 |

### 5.4 Custom Naming Override

Projects with specific naming requirements can override auto-generated names using custom variables. Implementation uses `coalesce()` to fall back to CAF-compliant defaults when custom names are not provided.

---

## 6. Tagging Strategy

All Azure resources must include mandatory tags. Tags are implemented via a `common_tags` local in `locals.tf` and applied to all resources.

### 6.1 Mandatory Tags

| Tag | Source | Purpose | Example |
|-----|--------|---------|---------|
| `project` | Variable | Cost allocation, grouping | payments |
| `environment` | Variable | Identify environment | dev |
| `owner` | Variable | Contact for questions | team-infrastructure |
| `managed_by` | Hardcoded | How resource is managed | terraform |

### 6.2 Implementation

Tags are defined in `locals.tf` as a `common_tags` map and applied to all resources that support tags.

---

## 7. Bootstrap

Each project requires a dedicated Azure Storage Account for Terraform state and a Key Vault for secrets. Bootstrap is implemented as Azure CLI scripts (Bash and PowerShell) rather than Terraform to avoid the chicken-and-egg problem of state management.

### 7.1 Bootstrap Location

Bootstrap scripts reside in the project repository under the `bootstrap/` directory:

- `bootstrap.sh` — Bash (Linux/macOS/WSL)
- `bootstrap.ps1` — PowerShell (Windows)
- `README.md` — Usage instructions

### 7.2 Script Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `project` | Yes | Project name (max 12 characters) |
| `region` | Yes | Azure region (e.g., westeurope) |
| `region_short` | Yes | 3-letter region code (e.g., weu) |

### 7.3 Resources Created

| Resource | Naming | Configuration |
|----------|--------|---------------|
| Resource Group | `rg-<project>-tfstate-<region_short>-001` | Container for state + secrets |
| Storage Account | `st<project>tfstate<region_short>001` | LRS redundancy |
| Blob Container | `tfstate` | — |
| Key Vault | `kv-<project>-secrets-<region_short>-001` | Project secrets |

### 7.4 State File Organization

One storage account per project with separate state files per environment.

| Environment | State File Key |
|-------------|----------------|
| dev | `<project>-dev.tfstate` |
| test | `<project>-test.tfstate` |
| stg | `<project>-stg.tfstate` |
| prod | `<project>-prod.tfstate` |

### 7.5 Generated Files

Bootstrap scripts generate backend configuration files for all environments in the `environments/` directory.

**Example generated `dev.backend.tfvars`:**

```hcl
resource_group_name  = "rg-payments-tfstate-weu-001"
storage_account_name = "stpaymentstfstateweu001"
container_name       = "tfstate"
key                  = "payments-dev.tfstate"
```

### 7.6 Authentication Methods

The storage account supports three authentication methods. Scripts output instructions for each method after completion.

| Method | Backend Config | Use Case |
|--------|----------------|----------|
| Access Key | `access_key = "xxx"` | Local dev (quick) |
| Azure AD | `use_azuread_auth = true` | Local dev (more secure) |
| Managed Identity | `use_msi = true` | CI/CD pipelines |

### 7.7 Script Output

After completion, scripts display:

- Created resource names
- Generated file locations
- Authentication method instructions
- Example terraform init command

---

## 8. README Template

All projects must include a `README.md` following this lightweight template. Optional sections may be deleted if not applicable.

### 8.1 Required Sections

- **Project Name and Overview:** Brief description of what this deploys
- **Prerequisites:** Required access/permissions and dependencies
- **Usage:** terraform init/plan/apply commands
- **Environments:** What environments exist, any differences
- **Inputs/Outputs:** Can be auto-generated via terraform-docs

### 8.2 Optional Sections

- **Notes:** Anything non-obvious, gotchas, architectural decisions

---

## 9. Environment Philosophy

All environments must be structurally identical. The same Azure resources are deployed to each environment; only configuration differs (such as SKU, tier, or capacity). This ensures that what is tested in dev/test/staging is what gets deployed to production.

### 9.1 Environment Progression

Standard four-tier progression:

| Environment | Purpose |
|-------------|---------|
| dev | Development and experimentation |
| test | QA validation |
| stg | Pre-production validation |
| prod | Production |

### 9.2 Handling Environment Differences

When certain resources are only needed in specific environments (such as geo-replication in prod only), use explicit feature flags rather than removing resources from environment configurations. This makes differences visible and intentional.

**Example:**

```hcl
variable "enable_geo_replication" {
  type        = bool
  default     = false
  description = "Enable geo-replication (typically prod only)"
}
```

---

## 10. Shared Modules

Reusable modules are hosted centrally in Azure DevOps (primary) or GitHub and sourced remotely. Projects do not contain a local `modules/` directory for shared modules.

Module architecture and versioning will be defined in Phase 2.

---

# Phase 2: Module Architecture

---

## 11. Module Repository Structure

All reusable modules are hosted in a single monorepo. This provides a central location for discovery while allowing independent versioning per module.

### 11.1 Repository Layout

```
terraform-modules/
├── storage-account/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── locals.tf
│   ├── data.tf
│   ├── versions.tf
│   ├── examples/
│   │   ├── basic/
│   │   │   ├── main.tf
│   │   │   └── README.md
│   │   └── complete/
│   │       ├── main.tf
│   │       └── README.md
│   ├── CHANGELOG.md
│   └── README.md
├── virtual-network/
│   └── ...
├── key-vault/
│   └── ...
└── README.md
```

### 11.2 Module Folder Structure

Each module contains:

| File/Directory | Purpose |
|----------------|---------|
| `main.tf` | Resource definitions |
| `variables.tf` | Input variable declarations |
| `outputs.tf` | Output declarations |
| `locals.tf` | Local values (keep even if empty) |
| `data.tf` | Data sources (keep even if empty) |
| `versions.tf` | Terraform and provider version constraints |
| `examples/` | Usage examples |
| `CHANGELOG.md` | Version history |
| `README.md` | Module documentation |

### 11.3 Examples Directory

Each module includes usage examples. A `basic/` example is required; a `complete/` example demonstrating all features is recommended. Add additional examples as needed (e.g., `with-private-endpoint/`, `with-cmk-encryption/`).

---

## 12. Module Versioning

Modules are versioned independently using Git tags with strict semantic versioning.

### 12.1 Tag Format

Pattern: `<module-name>/v<major>.<minor>.<patch>`

Examples:

- `storage-account/v1.0.0`
- `storage-account/v1.1.0`
- `virtual-network/v2.0.0`

### 12.2 Semantic Versioning Rules

Strict adherence to semantic versioning:

| Bump | When | Example |
|------|------|---------|
| MAJOR | Breaking change — consumers must modify their code | Renaming a variable, removing an output, changing default behavior |
| MINOR | New feature, backward compatible | Adding a new optional variable, new output |
| PATCH | Bug fix, backward compatible | Fixing a typo, correcting logic without interface change |

### 12.3 Module Sourcing

```hcl
module "storage" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/storage-account?ref=storage-account/v1.0.0"
}

module "network" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/virtual-network?ref=virtual-network/v2.3.1"
}
```

Each module can be pinned to a different version independently.

---

## 13. Module Interface Standards

All modules follow a consistent interface for inputs and outputs.

### 13.1 Common Input Variables

All modules must accept these standard variables:

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `resource_group_name` | string | Yes | Target resource group |
| `location` | string | Yes | Azure region |
| `name` | string | Yes | Resource name (full name, passed by consumer) |
| `tags` | map(string) | No (default: `{}`) | Tags to apply |

### 13.2 Variable Conventions

- Use `snake_case` for all variable names
- Provide sensible defaults where possible to minimize required inputs
- Resource-specific variables follow the common ones

### 13.3 Standard Outputs

All modules must output:

| Output | Description |
|--------|-------------|
| `id` | Resource ID |
| `name` | Resource name |

Plus resource-specific outputs (e.g., `primary_blob_endpoint` for storage, `vault_uri` for Key Vault). Note: secrets such as access keys must never be exposed as outputs — see Module Standards document.

### 13.4 Naming Responsibility

Modules do not generate resource names. The consuming project is responsible for generating CAF-compliant names in `locals.tf` and passing the full name to the module.

---

## 14. Module Provider Requirements

Modules must declare minimum provider versions in `versions.tf`.

### 14.1 Example versions.tf

```hcl
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}
```

### 14.2 Version Constraint Rules

- Declare the minimum version required for features used in the module
- Use `>=` constraints, not exact versions
- Consuming projects can pin higher versions but not lower
- Terraform resolves the intersection of all constraints

---

## 15. Module Documentation

Each module includes a standardized README.

### 15.1 README Template

```markdown
# Module Name

**Complexity:** Low | Medium | High

Brief description of what this module creates.

## Usage

\```hcl
module "example" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//<module>?ref=<module>/v1.0.0"

  resource_group_name = "rg-example-dev-weu-001"
  location            = "westeurope"
  name                = "example-resource-name"
  tags                = local.common_tags
}
\```

## Features

- Feature 1 (enabled via `enable_x`)
- Feature 2 (enabled via `enable_y`)

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| TLS version | 1.2 | `min_tls_version` |
| Public access | Disabled | `public_network_access_enabled` |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= x.x |
| azurerm | >= x.x |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| ... | ... | ... | ... | ... |

## Outputs

| Name | Description |
|------|-------------|
| ... | ... |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

## Notes

- Gotcha 1
- Azure quirk to be aware of
```

**Note:** Inputs and Outputs tables can be auto-generated with `terraform-docs`.

---

## 16. Module Changelog

Each module maintains its own CHANGELOG.md following the Keep a Changelog format.

### 16.1 Changelog Format

```markdown
# Changelog

## [1.1.0] - 2024-02-15

### Added
- New variable `enable_https_only`

## [1.0.1] - 2024-02-10

### Fixed
- Corrected default value for `min_tls_version`

## [1.0.0] - 2024-02-01

### Added
- Initial release
```

### 16.2 Changelog Sections

| Section | Use for |
|---------|---------|
| Added | New features |
| Changed | Changes in existing functionality |
| Deprecated | Features to be removed in future |
| Removed | Removed features |
| Fixed | Bug fixes |
| Security | Security-related fixes |

---

# Phase 3: State & Backend

---

## 17. Remote State Configuration

Terraform state is stored remotely in Azure Storage for all real deployments. Local state is used only for development experimentation.

### 17.1 Backend Configuration

All environments use the Azure Storage backend with this configuration structure:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-<project>-tfstate-<region>-001"
    storage_account_name = "st<project>tfstate<region>001"
    container_name       = "tfstate"
    key                  = "<project>-<env>.tfstate"
  }
}
```

Configuration values are provided via environment-specific backend files (`environments/<env>.backend.tfvars`).

### 17.2 State File Organization

| Scope | Pattern |
|-------|---------|
| One storage account | Per project |
| One state file | Per environment |
| State file key | `<project>-<env>.tfstate` |

---

## 18. State Locking

Azure Storage provides automatic state locking via blob leases.

### 18.1 Default Behavior

- Lease duration: 60 seconds
- Auto-renewal: Yes, during active operations
- Release on completion: Automatic
- Release on crash: Automatic after lease expiry (60 seconds)

### 18.2 Lock Conflicts

If a lock conflict occurs:

1. Terraform displays the lock holder information
2. Wait for the other operation to complete
3. If the lock is stale (crashed process), wait 60 seconds for auto-release
4. Force unlock only as last resort: `terraform force-unlock <lock-id>`

---

## 19. State Access Patterns

### 19.1 Managed Identity per Environment

Each environment uses a dedicated Managed Identity for CI/CD pipelines:

| Environment | Identity Naming | Role |
|-------------|-----------------|------|
| dev | `id-<project>-dev-001` | Storage Blob Data Contributor |
| test | `id-<project>-test-001` | Storage Blob Data Contributor |
| stg | `id-<project>-stg-001` | Storage Blob Data Contributor |
| prod | `id-<project>-prod-001` | Storage Blob Data Contributor |

### 19.2 Alternative: Managed Identity per Project

Projects may use a single identity covering all environments if preferred:

| Scope | Identity Naming | Role |
|-------|-----------------|------|
| All environments | `id-<project>-tfstate-001` | Storage Blob Data Contributor |

### 19.3 Authentication Methods

| Method | Use Case | Backend Config |
|--------|----------|----------------|
| Access Key | Local dev (quick) | `access_key = "xxx"` |
| Azure AD | Local dev (secure) | `use_azuread_auth = true` |
| Managed Identity | CI/CD pipelines | `use_msi = true` |

---

## 20. Local Development Workflow

Developers use local state for experimentation. Remote state is reserved for real deployments via CI/CD.

### 20.1 Local Development

```bash
# Initialize without backend config — uses local state
terraform init

# Work locally
terraform plan
terraform apply
```

Local state file (`terraform.tfstate`) is created in the project directory. This file is excluded via `.gitignore`.

### 20.2 Real Deployments

All deployments to real environments (dev, test, stg, prod) use remote state via CI/CD pipelines:

```bash
# Initialize with backend config — uses remote state
terraform init -backend-config=environments/dev.backend.tfvars

# Plan and apply
terraform plan -var-file=terraform.tfvars -var-file=environments/dev.tfvars
terraform apply -var-file=terraform.tfvars -var-file=environments/dev.tfvars
```

### 20.3 Workflow Summary

| Activity | State | Who |
|----------|-------|-----|
| Development, experimentation | Local | Developer |
| Real deployments | Remote | CI/CD pipeline |

---

## 21. Cross-Project State Access

Projects may need to read outputs from another project's state (e.g., shared networking).

### 21.1 Using terraform_remote_state

Place `terraform_remote_state` blocks in `data.tf`:

```hcl
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-network-tfstate-weu-001"
    storage_account_name = "stnetworktfstateweu001"
    container_name       = "tfstate"
    key                  = "network-prod.tfstate"
  }
}

# Usage
resource "azurerm_subnet" "example" {
  virtual_network_name = data.terraform_remote_state.network.outputs.public_vnet_name
  # ...
}
```

### 21.2 Public Outputs Convention

Projects exposing outputs for cross-project consumption should:

1. Use `public_` prefix for outputs intended for external consumption
2. Document public outputs in README under a "Public Outputs" section

**Example:**

```hcl
output "public_vnet_id" {
  description = "Virtual network ID (public - for cross-project consumption)"
  value       = azurerm_virtual_network.main.id
}

output "public_vnet_name" {
  description = "Virtual network name (public - for cross-project consumption)"
  value       = azurerm_virtual_network.main.name
}
```

### 21.3 Access Control

Consuming projects need read access to the source state storage account:

| Role | Scope | Purpose |
|------|-------|---------|
| Storage Blob Data Reader | Source storage account | Read state file |

All projects must be under the same Microsoft Entra ID tenant.

---

# Phase 4: Environment Management

---

## 22. Environment Definitions

### 22.1 Standard Environments

| Environment | Code | Purpose |
|-------------|------|---------|
| Development | dev | Development and experimentation |
| Test | test | QA validation |
| Staging | stg | Pre-production validation |
| Production | prod | Production workloads |

### 22.2 Environment Progression

Deployments are fully manual. Each environment is deployed independently with explicit approval.

```
dev → test → stg → prod
       ↑       ↑      ↑
    manual  manual  manual
```

---

## 23. Variable Management

Variables are organized in three layers, with later files overriding earlier ones.

### 23.1 Variable Layers

| File | Purpose | Example Values |
|------|---------|----------------|
| `terraform.tfvars` | Common defaults, shared across all envs | `project`, `owner`, feature flag defaults |
| `environments/<env>.tfvars` | Environment-specific overrides | `environment`, `location`, `region_short`, SKUs |
| Pipeline secrets / Key Vault | Sensitive values | Passwords, keys, connection strings |

### 23.2 Common Variables (terraform.tfvars)

```hcl
project = "payments"
owner   = "team-infrastructure"

# Feature flag defaults
enable_geo_replication = false
enable_backup          = false
enable_diagnostic_logs = true
```

### 23.3 Environment Variables (environments/<env>.tfvars)

```hcl
# environments/dev.tfvars
environment  = "dev"
location     = "westeurope"
region_short = "weu"
vm_sku       = "Standard_B2s"

# environments/prod.tfvars
environment            = "prod"
location               = "westeurope"
region_short           = "weu"
vm_sku                 = "Standard_D4s_v3"
enable_geo_replication = true
enable_backup          = true
```

### 23.4 Location and Region

Location and region are defined per-environment, allowing geo-separation or disaster recovery setups:

| Variable | Type | Description |
|----------|------|-------------|
| `location` | string | Azure region (e.g., westeurope) |
| `region_short` | string | 3-letter code (e.g., weu) |

---

## 24. Feature Flags

Resources that differ between environments are controlled via feature flags.

### 24.1 Naming Convention

Pattern: `enable_<feature>`

### 24.2 Implementation

Define in `variables.tf`:

```hcl
variable "enable_geo_replication" {
  type        = bool
  default     = false
  description = "Enable geo-replication (typically prod only)"
}
```

Set defaults in `terraform.tfvars`:

```hcl
enable_geo_replication = false
```

Override in environment files as needed:

```hcl
# environments/prod.tfvars
enable_geo_replication = true
```

### 24.3 Usage in Resources

```hcl
resource "azurerm_storage_account" "main" {
  # ...

  dynamic "blob_properties" {
    for_each = var.enable_geo_replication ? [1] : []
    content {
      # geo-replication settings
    }
  }
}
```

---

## 25. Secrets Handling

Sensitive values are managed via Azure Key Vault and pipeline secrets.

### 25.1 Two Patterns

| Pattern | Use Case | Example |
|---------|----------|---------|
| Key Vault | Infrastructure secrets consumed by resources | Database passwords, API keys |
| Pipeline secrets | Terraform variables passed at runtime | Service principal credentials |

### 25.2 Key Vault Integration

One Key Vault per project, created by bootstrap scripts (see Section 7.3).

**Reading secrets in Terraform:**

```hcl
data "azurerm_key_vault" "main" {
  name                = "kv-${var.project}-secrets-${var.region_short}-001"
  resource_group_name = "rg-${var.project}-tfstate-${var.region_short}-001"
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "db-admin-password"
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_mssql_server" "main" {
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value
  # ...
}
```

### 25.3 Pipeline Secrets

Sensitive Terraform variables passed via pipeline:

```bash
terraform apply -var="client_secret=$(ARM_CLIENT_SECRET)"
```

---

# Phase 5: CI/CD Pipeline

---

## 26. Pipeline Overview

Each project has its own Azure DevOps pipeline. Pipelines are manually triggered with environment selection.

### 26.1 Pipeline Platform

Azure DevOps Pipelines (YAML-based)

### 26.2 Trigger Model

| Trigger | Type |
|---------|------|
| Automatic | None |
| Manual | Operator triggers with environment parameter |

### 26.3 Trust Model

The operator triggering the pipeline is trusted. No approval gates — safeguards are:

- Manual trigger requires deliberate action
- Plan output visible before apply
- Pipeline logs provide audit trail
- Plan artifact ensures reviewed plan = applied plan

---

## 27. Pipeline Structure

### 27.1 Pipeline Parameters

| Parameter | Type | Values |
|-----------|------|--------|
| environment | dropdown | dev, test, stg, prod |

### 27.2 Pipeline Stages

```
Manual Trigger (with environment parameter):

  ┌─────────────────────────────────────────┐
  │ Stage: Validate                         │
  │  - terraform fmt -check                 │
  │  - terraform validate                   │
  │  - tflint                               │
  └─────────────────────────────────────────┘
                    ↓
  ┌─────────────────────────────────────────┐
  │ Stage: Plan                             │
  │  - terraform init (with backend config) │
  │  - terraform plan -out=tfplan           │
  │  - Publish plan artifact                │
  └─────────────────────────────────────────┘
                    ↓
  ┌─────────────────────────────────────────┐
  │ Stage: Apply                            │
  │  - Download plan artifact               │
  │  - terraform apply tfplan               │
  └─────────────────────────────────────────┘
```

---

## 28. Validation Stage

Automated checks run before planning.

### 28.1 Validation Steps

| Step | Tool | Purpose |
|------|------|---------|
| Format check | `terraform fmt -check` | Consistent formatting |
| Syntax validation | `terraform validate` | Catch syntax errors |
| Linting | `tflint` | Best practices, Azure-specific rules |

### 28.2 Failure Behavior

If any validation step fails, pipeline stops. No plan or apply runs.

---

## 29. Plan Stage

### 29.1 Plan Steps

1. Initialize Terraform with environment-specific backend:
   ```bash
   terraform init -backend-config=environments/${{ parameters.environment }}.backend.tfvars
   ```

2. Generate plan with environment-specific variables:
   ```bash
   terraform plan \
     -var-file=terraform.tfvars \
     -var-file=environments/${{ parameters.environment }}.tfvars \
     -out=tfplan
   ```

3. Publish plan file as pipeline artifact

### 29.2 Plan Artifact

| Setting | Value |
|---------|-------|
| Artifact name | `tfplan-${{ parameters.environment }}` |
| Retention | 7 days |
| Contents | `tfplan` binary file |

---

## 30. Apply Stage

### 30.1 Apply Steps

1. Download plan artifact from Plan stage
2. Initialize Terraform (same backend config)
3. Apply the saved plan:
   ```bash
   terraform apply tfplan
   ```

### 30.2 Plan Artifact Guarantee

Apply uses the exact plan file generated in Plan stage. No re-planning occurs — what was reviewed is what gets applied.

---

## 31. Pipeline Authentication

### 31.1 Service Connection

Each project uses a Managed Identity for Azure authentication.

| Scope | Identity |
|-------|----------|
| Per environment | `id-<project>-<env>-001` |
| Or per project | `id-<project>-tfstate-001` |

### 31.2 Required Permissions

| Resource | Role |
|----------|------|
| State Storage Account | Storage Blob Data Contributor |
| Key Vault | Key Vault Secrets User |
| Target subscription | Contributor (or scoped custom role) |

---

## 32. Pipeline File Location

Pipeline definitions live in the project repository under the `ops/` directory:

```
project-repo/
├── src/
├── infrastructures/
│   └── iac/
├── ops/
│   ├── infrastructure.yml
│   └── app.yml
└── README.md
```

---

# Phase 6: Governance & Onboarding

---

## 33. Module Contribution Model

### 33.1 Ownership

The Infrastructure team owns and maintains all shared modules.

### 33.2 Contribution Process

| Role | Action |
|------|--------|
| Dev teams | Request changes via ticket/issue |
| Infra team | Review request, implement, release |

Dev teams consume modules but do not contribute directly. This ensures consistent quality and patterns.

---

## 34. Code Review Requirements

### 34.1 Module Changes

| Requirement | Value |
|-------------|-------|
| Minimum reviewers | 1 |
| Reviewer criteria | Someone who didn't write the code |

### 34.2 Review Focus Areas

- Does it follow module interface standards?
- Are variables and outputs documented?
- Is CHANGELOG updated?
- Does it include/update examples?
- Are breaking changes flagged with major version bump?

---

## 35. Onboarding

### 35.1 Documentation

The framework specification (this document) serves as the primary reference.

### 35.2 Project Template Repository

A template repository provides the starting point for new projects:

```
terraform-project-template/
├── src/                          # App source code placeholder
│   └── .gitkeep
├── infrastructures/
│   └── iac/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── locals.tf
│       ├── data.tf
│       ├── versions.tf
│       ├── terraform.tfvars
│       ├── environments/
│       │   ├── dev.tfvars
│       │   ├── dev.backend.tfvars
│       │   ├── test.tfvars
│       │   ├── test.backend.tfvars
│       │   ├── stg.tfvars
│       │   ├── stg.backend.tfvars
│       │   ├── prod.tfvars
│       │   └── prod.backend.tfvars
│       ├── modules/
│       │   └── MODULES.md
│       ├── bootstrap/
│       │   ├── bootstrap.sh
│       │   ├── bootstrap.ps1
│       │   └── README.md
│       ├── .gitignore
│       ├── .terraform-version
│       └── README.md
├── ops/
│   ├── infrastructure.yml
│   └── app.yml
└── README.md
```

### 35.3 New Project Workflow

1. Clone/fork the template repository
2. Rename and configure for new project
3. Run bootstrap scripts to create state storage and Key Vault
4. Update `terraform.tfvars` and environment files
5. Start building infrastructure

---

## 36. Framework Versioning

### 36.1 Specification Versioning

The framework specification is versioned using semantic versioning:

| Version | Meaning |
|---------|---------|
| Major (v2.0.0) | Breaking changes to conventions or structure |
| Minor (v1.1.0) | New guidance, non-breaking additions |
| Patch (v1.0.1) | Clarifications, typo fixes |

### 36.2 Adoption Policy

| Policy | Description |
|--------|-------------|
| New projects | Use latest specification version |
| Existing projects | Voluntary adoption |
| Breaking changes | Documented with migration steps |

### 36.3 Changelog

Framework changes are documented in a changelog:

```markdown
# Framework Changelog

## [1.1.0] - 2024-03-01

### Added
- Security scanning guidance (optional)

### Changed
- Updated tflint rules

## [1.0.0] - 2024-02-01

### Added
- Initial framework release
```

---

## 37. Support Model

### 37.1 Questions and Issues

| Topic | Channel |
|-------|---------|
| Framework questions | Infra team (Teams/Slack channel) |
| Module issues | Module repo issues |
| Project-specific issues | Project team responsibility |

### 37.2 Feedback

Teams can suggest framework improvements via:

- Direct feedback to infra team
- Framework repo issues/discussions

---

## Appendix A: Region Codes

Standard 3-letter region abbreviations following Microsoft conventions.

| Azure Region | Code |
|--------------|------|
| West Europe | weu |
| North Europe | neu |
| East US | eus |
| East US 2 | eus2 |
| West US | wus |
| UK South | uks |

---

## Appendix B: CAF Resource Prefixes

Common Azure resource prefixes per Microsoft Cloud Adoption Framework. Full list available at [Microsoft documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).

| Resource Type | Prefix |
|---------------|--------|
| Resource Group | rg |
| Virtual Network | vnet |
| Subnet | snet |
| Network Security Group | nsg |
| Storage Account | st |
| Key Vault | kv |
| Virtual Machine | vm |
| App Service | app |
| SQL Database | sqldb |
| Log Analytics Workspace | log |
