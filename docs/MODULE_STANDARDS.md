# Terraform Module Standards

**Version:** 1.0  
**Status:** Draft  
**Maintainer:** Infrastructure Team

This document defines the standards for building and maintaining Terraform modules within the organization. All modules in the `terraform-modules` repository must follow these standards.

This document is a companion to the **Terraform Framework Specification**, which defines project structure, naming conventions, and environment management. Modules built to these standards are consumed by projects following that specification.

## Table of Contents

1. [Module Complexity](#1-module-complexity)
2. [Variable Organization](#2-variable-organization)
3. [Defaults Philosophy](#3-defaults-philosophy)
4. [Output Standards](#4-output-standards)
5. [Documentation Requirements](#5-documentation-requirements)
6. [Example Requirements](#6-example-requirements)
7. [Testing Approach](#7-testing-approach)
8. [Versioning Workflow](#8-versioning-workflow)
9. [Module File Structure](#9-module-file-structure)
10. [Interface Standards](#10-interface-standards)
- [Appendix A: Quick Reference](#appendix-a-quick-reference)

---

## 1. Module Complexity

Modules are not formally tiered by complexity. Each module follows the same structural standards regardless of size or scope.

Complexity is communicated through:

- Number of required vs optional variables
- Documentation in the README (including a Complexity indicator: Low / Medium / High)
- Presence of feature flags

Start simple. A module that creates one resource well is more valuable than one that creates ten resources poorly.

---

## 2. Variable Organization

Variables in `variables.tf` are grouped logically with comment headers, in this order:

```hcl
# === Required ===
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "name" {
  type        = string
  description = "Resource name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===
# (Only if the resource has additional mandatory inputs)

# === Optional: Configuration ===
variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "Storage account tier"
}

# === Optional: Feature Flags ===
variable "enable_versioning" {
  type        = bool
  default     = false
  description = "Enable blob versioning"
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
```

### Variable Naming Conventions

| Pattern | Use For | Example |
|---------|---------|---------|
| `enable_<feature>` | Boolean feature flags | `enable_soft_delete` |
| `<resource>_name` | Names of related resources | `subnet_name` |
| `<resource>_id` | IDs of related resources | `subnet_id` |
| `<setting>` | Configuration values | `sku`, `tier`, `capacity` |

---

## 3. Defaults Philosophy

Modules use **secure defaults**. The most restrictive, secure configuration is applied unless explicitly overridden by the consumer.

### Standard Secure Defaults

| Setting | Default | Rationale |
|---------|---------|-----------|
| `min_tls_version` | `"TLS1_2"` | Enforce modern TLS |
| `https_only` | `true` | No unencrypted traffic |
| `public_network_access_enabled` | `false` | Private by default |
| `allow_blob_public_access` | `false` | No anonymous access |
| `enable_soft_delete` | `true` | Protect against accidental deletion |

When a consumer needs a less restrictive setting (e.g., for prototyping), they explicitly set it. This ensures security is intentional, not accidental.

Document secure defaults in each module's README under a **Security Defaults** section.

### Security vs Functionality Flags

Not all `enable_*` flags are security-related. Apply different default strategies:

| Flag Type | Default | Examples |
|-----------|---------|----------|
| **Security features** (protect data, restrict access) | `true` | `enable_soft_delete`, `enable_https_only` |
| **Functionality features** (add capabilities, cost implications) | `false` | `enable_versioning`, `enable_geo_replication` |

When in doubt: if disabling it creates a security risk, default to `true`. If enabling it adds cost or complexity, default to `false`.

---

## 4. Output Standards

Outputs are organized by category. Secrets are never exposed as outputs.

### Required Outputs

Every module must output:

| Output | Description |
|--------|-------------|
| `id` | Resource ID |
| `name` | Resource name |

### Conditional Outputs

Include when applicable:

| Category | Output Pattern | Example |
|----------|----------------|---------|
| Endpoints | `*_fqdn`, `*_uri`, `*_endpoint` | `primary_blob_endpoint` |
| Managed Identity | `principal_id`, `tenant_id` | `principal_id` |
| Companion Resources | `<resource>_id` | `private_endpoint_id` |

### Forbidden Outputs

Never output:

- Access keys
- Connection strings containing secrets
- Passwords
- Certificates or private keys

If a consumer needs secrets, they retrieve them via data source or Key Vault reference.

### Output Naming

Use descriptive names that indicate the resource when multiple exist:

```hcl
# Good
output "primary_blob_endpoint" { ... }
output "private_endpoint_id" { ... }

# Bad
output "endpoint" { ... }
output "pe_id" { ... }
```

---

## 5. Documentation Requirements

Every module includes a `README.md` following this template:

```markdown
# Module Name

**Complexity:** Low | Medium | High

One-line description of what this module creates.

## Usage

\```hcl
module "example" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//<module>?ref=<module>/v1.0.0"

  resource_group_name = "rg-example-dev-weu-001"
  location            = "westeurope"
  name                = "stexampledevweu001"
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

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- Gotcha 1
- Azure quirk to be aware of
- Things that will bite you at 3am
```

The `Requirements`, `Inputs`, and `Outputs` sections are auto-generated by terraform-docs between the markers.

### terraform-docs Integration

Use terraform-docs to generate Inputs and Outputs tables. Place this config file at the `terraform-modules` repository root as `.terraform-docs.yml` — it applies to all modules in the repo:

```yaml
formatter: markdown table

sections:
  show:
    - requirements
    - inputs
    - outputs

output:
  file: ""
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

sort:
  enabled: true
  by: required

settings:
  default: true
  required: true
  type: true
  description: true
```

To generate documentation, run from the module directory:

```bash
terraform-docs markdown table --output-file README.md .
```

The tool injects content between the `BEGIN_TF_DOCS` and `END_TF_DOCS` markers, preserving handwritten sections above and below.

---

## 6. Example Requirements

Every module includes at minimum a `basic/` example. A `complete/` example is recommended.

| Example | Purpose | Contents |
|---------|---------|----------|
| `examples/basic/` | Minimum viable usage (required) | Only required variables, copy-paste ready |
| `examples/complete/` | All features demonstrated (recommended) | Every feature flag enabled, all options shown |

### Example Structure

```
examples/
├── basic/
│   ├── main.tf
│   └── README.md
└── complete/
    ├── main.tf
    └── README.md
```

### Example Standards

Each example must:

- Be self-contained (provider configuration included)
- Actually work when applied
- Include a README explaining what it demonstrates
- Use realistic values (not `"foo"` or `"test123"`)

The `complete/` example doubles as the primary test case for the module.

### Example README Template

Each example's `README.md` should follow this structure (adapt title and description for `basic/` vs `complete/`):

```markdown
# Example: [Basic Usage | Complete Usage]

[One sentence describing what this example demonstrates.]

## Usage

\```bash
terraform init
terraform plan
terraform apply
\```

## Prerequisites

- Azure subscription
- Azure CLI authenticated
- Existing resource group (or modify example to create one)

## What This Creates

- [List resources created by this example]

## Clean Up

\```bash
terraform destroy
\```
```

---

## 7. Testing Approach

Testing follows a layered approach, starting simple and adding automation as needed.

### Current State

| Method | When | Who |
|--------|------|-----|
| Manual deployment of `examples/complete/` | Before tagging any release | Module author |
| `terraform fmt -check` | Every PR (local) | Module author |
| `terraform validate` | Every PR (local) | Module author |

### Near-Term Goal

Add CI pipeline that runs on every PR:

- `terraform fmt -check`
- `terraform validate`
- `tflint` with Azure rules

### Future State

When scale demands it, add integration tests for critical modules using Terratest or similar.

### Pre-Release Checklist

Before tagging a new version:

1. Run `terraform fmt -recursive`
2. Run `terraform validate` in `examples/complete/`
3. Deploy `examples/complete/` to dev subscription
4. Verify resources created correctly
5. Run `terraform destroy`
6. Update `CHANGELOG.md`
7. Create Git tag

---

## 8. Versioning Workflow

Modules are versioned independently using Git tags with semantic versioning.

### Tag Format

```
<module-name>/v<major>.<minor>.<patch>
```

Examples:
- `storage-account/v1.0.0`
- `storage-account/v1.1.0`
- `key-vault/v2.0.0`

### Semantic Versioning Rules

| Bump | When | Examples |
|------|------|----------|
| **MAJOR** | Breaking change — consumers must modify code | Rename variable, remove output, change default behavior |
| **MINOR** | New feature, backward compatible | Add optional variable, add new output |
| **PATCH** | Bug fix, backward compatible | Fix typo, correct logic without interface change |

**Note on default changes:** Changing a default value is a breaking change even if it improves security. Consumers may have relied on the old behavior. For example, changing `public_network_access_enabled` from `true` to `false` requires a MAJOR bump — existing deployments would suddenly lose public access.

### Current Workflow

1. Make changes to module
2. Update `CHANGELOG.md` with changes under appropriate section
3. Commit and push to `main`
4. Create and push Git tag:

```bash
git tag storage-account/v1.2.0
git push origin storage-account/v1.2.0
```

### Future Workflow

Migrate to PR-based changelog enforcement:

- Every PR that changes a module must update that module's `CHANGELOG.md`
- CI validates changelog was updated
- Tagging remains manual or semi-automated

### Changelog Format

Each module maintains `CHANGELOG.md` following Keep a Changelog format:

```markdown
# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.1.0] - YYYY-MM-DD

### Added
- New variable `enable_soft_delete` for blob soft delete

## [1.0.1] - YYYY-MM-DD

### Fixed
- Corrected default value for `min_tls_version`

## [1.0.0] - YYYY-MM-DD

### Added
- Initial release
```

---

## 9. Module File Structure

Every module follows this structure:

```
<module-name>/
├── versions.tf       # Terraform and provider version constraints
├── variables.tf      # Input variables (grouped as per section 2)
├── locals.tf         # Local values (keep even if empty)
├── data.tf           # Data sources (keep even if empty)
├── main.tf           # Resource definitions
├── outputs.tf        # Output definitions (as per section 4)
├── examples/
│   ├── basic/
│   │   ├── main.tf
│   │   └── README.md
│   └── complete/
│       ├── main.tf
│       └── README.md
├── CHANGELOG.md      # Version history
└── README.md         # Module documentation (as per section 5)
```

The file order above reflects a typical development workflow: define constraints, then inputs, then locals, then data lookups, then resources, then outputs.

**Empty files:** Always include `locals.tf` and `data.tf` even if empty. Use a comment header for consistency:

```hcl
# locals.tf - Local values
# (No local values defined for this module)
```

```hcl
# data.tf - Data sources
# (No data sources defined for this module)
```

**`.gitignore`:** A single `.gitignore` file at the repository root covers all modules. Individual modules do not need their own `.gitignore`.

Example `.gitignore` content:

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
*.tfplan

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db
```

### versions.tf Standard

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

Use `>=` constraints. Consuming projects can pin higher versions but not lower.

---

## 10. Interface Standards

All modules accept a consistent set of common variables (defined in the Terraform Framework Specification).

### Required Common Variables

| Variable | Type | Description |
|----------|------|-------------|
| `resource_group_name` | string | Target resource group |
| `location` | string | Azure region |
| `name` | string | Full resource name (CAF-compliant, provided by consumer) |

### Optional Common Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | map(string) | `{}` | Tags to apply |

### Canonical Variable Names

Certain variables appear across many modules with a fixed name, type, and semantics. Always use these exact names — do not invent synonyms.

| Variable | Type | Purpose | Notes |
|----------|------|---------|-------|
| `min_tls_version` | string | Minimum TLS version | Default `"TLS1_2"`. Validated to reject older values. |
| `enable_private_endpoint` | bool | Enable `azurerm_private_endpoint` creation | Security flag — defaults `true`. |
| `administrator_password` | string (sensitive) | Admin credential for database modules | Required on MySQL/PostgreSQL/MSSQL flex servers. |
| `diagnostic_settings` | object | Optional. Enables `azurerm_monitor_diagnostic_setting` creation with multi-sink support (Log Analytics Workspace, storage account, Event Hub). | Default `null` (disabled). When non-null, at least one destination must be set. `enabled_log_categories` / `enabled_metrics` default to "all supported by the resource" via the `azurerm_monitor_diagnostic_categories` data source. |

The `diagnostic_settings` variable is REQUIRED on every new compute, data, messaging, or storage module built after Phase 2 (2026-04-18). Pure-networking or pure-identity modules (e.g., `virtual-network`, `user-assigned-identity`, `private-dns-zone`) do not need it — consumers can use the standalone `diagnostic-settings` module when they want to attach diagnostics to those resource types.

### Naming Responsibility

Modules do **not** generate resource names. The consuming project generates CAF-compliant names in `locals.tf` and passes the full name to the module.

This keeps modules simple and gives consumers full control over naming conventions.

### Provider Configuration

Modules use the default provider configuration. They do not declare `provider` blocks internally — this would prevent consumers from passing custom configurations.

For multi-region scenarios where a module needs a specific provider alias, document this in the module's README and accept it via the `providers` meta-argument:

```hcl
module "storage_secondary" {
  source    = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/storage-account?ref=storage-account/v1.0.0"
  providers = {
    azurerm = azurerm.secondary
  }
  # ...
}
```

This is an advanced pattern — most modules won't need it.

---

## Appendix A: Quick Reference

### New Module Checklist

- [ ] Create folder structure per section 9
- [ ] Set version constraints in `versions.tf`
- [ ] Define input variables in `variables.tf` per section 2
- [ ] Create empty `locals.tf` and `data.tf` with comment headers
- [ ] Implement resources in `main.tf` with secure defaults
- [ ] Define outputs in `outputs.tf` per section 4
- [ ] Create `examples/basic/` and `examples/complete/` with READMEs
- [ ] Write module README per section 5 template
- [ ] Initialize `CHANGELOG.md`
- [ ] Test `examples/complete/` deployment
- [ ] Tag initial release `<module>/v1.0.0`

### Release Checklist

- [ ] Update `CHANGELOG.md`
- [ ] Run `terraform fmt -recursive`
- [ ] Validate examples
- [ ] Deploy and destroy `examples/complete/`
- [ ] Determine version bump (major/minor/patch)
- [ ] Create and push Git tag

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | YYYY-MM-DD | Initial release |
