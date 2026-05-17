---
title: ai-foundry module v1.0.0 — implementation plan
date: 2026-05-17
status: draft
---

# `ai-foundry` Module v1.0.0 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `modules/ai-foundry/` v1.0.0 implementing the `ai-foundry` design from `docs/specs/2026-05-17-ai-foundry-and-acs-email-modules.md`.

**Architecture:** Single Terraform module wrapping `azurerm_ai_foundry` (hub) + `azurerm_ai_foundry_project` (default project) with optional private endpoint and diagnostic settings. Mirrors the structure and conventions of `modules/key-vault/` and `modules/application-insights/`. AzureRM-only — no AzAPI dependency. Connections are intentionally out of scope.

**Tech Stack:** Terraform >= 1.10.0, AzureRM >= 4.0.0. No additional providers.

**Reference modules to mirror:** `modules/key-vault/` (PE pattern, output structure), `modules/storage-account/` (diagnostic_settings pattern), `modules/application-insights/` (variable-grouping comment headers).

---

## File Structure

```
modules/ai-foundry/
├── versions.tf
├── variables.tf
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── CHANGELOG.md
├── README.md
└── examples/
    ├── basic/
    │   ├── main.tf
    │   └── README.md
    └── complete/
        ├── main.tf
        └── README.md
```

Responsibilities:
- `versions.tf` — provider pin (matches every other module).
- `variables.tf` — grouped under `# === Required ===`, `# === Required: Resource-Specific ===`, `# === Optional: Configuration ===`, `# === Optional: Feature Flags ===`, `# === Tags ===`.
- `data.tf` — `azurerm_monitor_diagnostic_categories` keyed on the hub ID, gated by `count`.
- `locals.tf` — computed project name (`coalesce(var.project_name, ...)`) and `subresource_names = ["amlworkspace"]` (the AML hub subresource name).
- `main.tf` — `azurerm_ai_foundry.this`, `azurerm_ai_foundry_project.this`, `azurerm_private_endpoint.this` (count-gated), `azurerm_monitor_diagnostic_setting.this` (count-gated).
- `outputs.tf` — standard + project + identity + PE outputs. No secret outputs.
- `CHANGELOG.md` — Keep a Changelog, initial `[1.0.0] - 2026-05-17` entry.
- `README.md` — terraform-docs marker block + Notes section covering ForceNew foot-guns, required role assignments, and the `amlworkspace`-vs-Cognitive-Services distinction.
- `examples/basic/main.tf` — RG + KV + storage + hub + default project, SystemAssigned identity, no PE.
- `examples/complete/main.tf` — adds App Insights, ACR, UAMI, `managed_network_isolation_mode`, PE with two zones (`privatelink.api.azureml.ms` and `privatelink.notebooks.azure.net`), diagnostic settings.

---

## Task 1: Scaffold the module skeleton

**Files:**
- Create: `modules/ai-foundry/versions.tf`
- Create: `modules/ai-foundry/data.tf`
- Create: `modules/ai-foundry/locals.tf`
- Create: `modules/ai-foundry/main.tf` (empty placeholder)
- Create: `modules/ai-foundry/outputs.tf` (empty placeholder)
- Create: `modules/ai-foundry/CHANGELOG.md`
- Create: `modules/ai-foundry/README.md` (terraform-docs marker only)

- [ ] **Step 1: Create `versions.tf`**

```hcl
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}
```

- [ ] **Step 2: Create `data.tf`**

```hcl
data "azurerm_monitor_diagnostic_categories" "this" {
  count       = var.diagnostic_settings == null ? 0 : 1
  resource_id = azurerm_ai_foundry.this.id
}
```

- [ ] **Step 3: Create `locals.tf`** (computed values; PE subresource is the AML workspace subresource)

```hcl
locals {
  effective_project_name = coalesce(var.project_name, "${var.name}-proj")
  pe_subresource_names   = ["amlworkspace"]
}
```

- [ ] **Step 4: Create empty `main.tf` and `outputs.tf` placeholders** (so `terraform init` doesn't choke later)

```hcl
# main.tf — populated in Task 3
```

```hcl
# outputs.tf — populated in Task 4
```

- [ ] **Step 5: Create `CHANGELOG.md`**

```markdown
# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.0.0] - 2026-05-17

### Added

- Initial release of `ai-foundry` module.
- Wraps `azurerm_ai_foundry` (hub) + `azurerm_ai_foundry_project` (one default project).
- BYO dependencies: `storage_account_id`, `key_vault_id` required; `application_insights_id`, `container_registry_id` optional.
- Managed identity: defaults to `SystemAssigned`; supports `UserAssigned` and `SystemAssigned, UserAssigned`.
- Optional managed network isolation, customer-managed encryption, and high business impact mode.
- Optional private endpoint targeting the `amlworkspace` subresource.
- Optional diagnostic settings using the standard module object pattern (multi-sink, auto-enumerated categories).
- Outputs: `id`, `name`, `workspace_id`, `discovery_url`, `principal_id`, `tenant_id`, `project_id`, `project_name`, `project_workspace_id`, `private_endpoint_id`, `private_endpoint_ip_address`.
- No secret outputs.
```

- [ ] **Step 6: Create `README.md` skeleton with terraform-docs markers**

```markdown
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
```

- [ ] **Step 7: Verify scaffold loads**

Run: `cd modules/ai-foundry && terraform init -backend=false && terraform validate`
Expected: `Error: Reference to undeclared input variable` (variables file missing) — this is expected; we add it next.

- [ ] **Step 8: Commit**

```bash
git checkout -b ai-foundry/v1.0.0
git add modules/ai-foundry/
git commit -m "feat(ai-foundry): scaffold module skeleton"
```

---

## Task 2: Implement `variables.tf` with validations

**Files:**
- Create: `modules/ai-foundry/variables.tf`

- [ ] **Step 1: Write the full variables file**

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
  description = "AI Foundry hub name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===

variable "storage_account_id" {
  type        = string
  description = "Resource ID of the storage account backing the hub"
}

variable "key_vault_id" {
  type        = string
  description = "Resource ID of the Key Vault backing the hub"
}

# === Optional: Configuration ===

variable "application_insights_id" {
  type        = string
  default     = null
  description = "Optional Application Insights resource ID linked to the hub"
}

variable "container_registry_id" {
  type        = string
  default     = null
  description = "Optional Container Registry resource ID linked to the hub"
}

variable "description" {
  type        = string
  default     = null
  description = "Description of the hub"
}

variable "friendly_name" {
  type        = string
  default     = null
  description = "Display name of the hub"
}

variable "project_name" {
  type        = string
  default     = null
  description = "Name of the default project. Required (no default derived from var.name to avoid silently exceeding Azure project name length limits). Alphanumeric + hyphens, ~32 char max."
}

variable "project_description" {
  type        = string
  default     = null
  description = "Description of the default project"
}

variable "project_friendly_name" {
  type        = string
  default     = null
  description = "Display name of the default project"
}

variable "identity_type" {
  type        = string
  default     = "SystemAssigned"
  description = "Managed identity type. One of: SystemAssigned, UserAssigned, \"SystemAssigned, UserAssigned\" (note the literal space after the comma; AzureRM is strict)."

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be exactly one of: SystemAssigned, UserAssigned, \"SystemAssigned, UserAssigned\"."
  }
}

variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "User-assigned managed identity resource IDs. Required when identity_type includes UserAssigned."
}

variable "primary_user_assigned_identity" {
  type        = string
  default     = null
  description = "UAMI resource ID representing the hub identity for encryption purposes (set when using CMK with a user-assigned identity)"
}

variable "managed_network_isolation_mode" {
  type        = string
  default     = null
  description = "Optional managed network isolation. One of: null (omit the managed_network block), Disabled, AllowOnlyApprovedOutbound, AllowInternetOutbound."

  validation {
    condition     = var.managed_network_isolation_mode == null || contains(["Disabled", "AllowOnlyApprovedOutbound", "AllowInternetOutbound"], var.managed_network_isolation_mode)
    error_message = "managed_network_isolation_mode must be null, Disabled, AllowOnlyApprovedOutbound, or AllowInternetOutbound."
  }
}

variable "high_business_impact_enabled" {
  type        = bool
  default     = false
  description = "Enable High Business Impact mode on the hub and project. ForceNew — changing rebuilds both."
}

variable "encryption" {
  type = object({
    key_id                    = string
    key_vault_id              = string
    user_assigned_identity_id = optional(string)
  })
  default     = null
  description = "Customer-managed encryption key configuration. null disables (Microsoft-managed key). ForceNew — changing rebuilds the hub."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet resource ID for the private endpoint. Required when enable_private_endpoint = true."
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = []
  description = "Private DNS zone IDs to link to the private endpoint. AI Foundry typically needs two: privatelink.api.azureml.ms and privatelink.notebooks.azure.net."
}

variable "private_endpoint_name" {
  type        = string
  default     = null
  description = "Override the private endpoint name. Defaults to pep-<name>."
}

variable "diagnostic_settings" {
  type = object({
    name                           = optional(string)
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
    log_analytics_destination_type = optional(string)
    enabled_log_categories         = optional(list(string))
    enabled_metrics                = optional(list(string))
  })
  default     = null
  description = "Optional diagnostic settings. null disables. Supports multi-sink (Log Analytics, storage account, Event Hub). enabled_log_categories = null -> all categories the resource supports. enabled_metrics = null -> all metrics the resource supports. At least one of log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id is required when the object is non-null."

  validation {
    condition = (
      var.diagnostic_settings == null ? true
      : (var.diagnostic_settings.log_analytics_workspace_id != null
        || var.diagnostic_settings.storage_account_id != null
      || var.diagnostic_settings.eventhub_authorization_rule_id != null)
    )
    error_message = "At least one destination (log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id) is required when diagnostic_settings is set."
  }

  validation {
    condition = (
      var.diagnostic_settings == null ? true
      : (var.diagnostic_settings.log_analytics_destination_type == null
      || contains(["Dedicated", "AzureDiagnostics"], var.diagnostic_settings.log_analytics_destination_type))
    )
    error_message = "log_analytics_destination_type must be \"Dedicated\" or \"AzureDiagnostics\" when set."
  }
}

# === Optional: Feature Flags ===

variable "enable_public_network_access" {
  type        = bool
  default     = false
  description = "Enable public network access on the hub. Disabled by default for security; set true to allow public access."
}

variable "enable_private_endpoint" {
  type        = bool
  default     = false
  description = "Create a private endpoint to the hub. Requires subnet_id."
}

# === Tags ===

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resources"
}
```

- [ ] **Step 2: Validate variables compile**

Run: `cd modules/ai-foundry && terraform init -backend=false && terraform validate`
Expected: `Success! The configuration is valid.` (main.tf is empty so no resource errors)

- [ ] **Step 3: Commit**

```bash
git add modules/ai-foundry/variables.tf
git commit -m "feat(ai-foundry): add variables with validations"
```

---

## Task 3: Implement `main.tf`

**Files:**
- Modify: `modules/ai-foundry/main.tf`

- [ ] **Step 1: Replace the placeholder with the full main.tf**

```hcl
resource "azurerm_ai_foundry" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  storage_account_id = var.storage_account_id
  key_vault_id       = var.key_vault_id

  application_insights_id = var.application_insights_id
  container_registry_id   = var.container_registry_id

  description   = var.description
  friendly_name = var.friendly_name

  high_business_impact_enabled = var.high_business_impact_enabled
  public_network_access        = var.enable_public_network_access ? "Enabled" : "Disabled"

  primary_user_assigned_identity = var.primary_user_assigned_identity

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  dynamic "managed_network" {
    for_each = var.managed_network_isolation_mode == null ? [] : [var.managed_network_isolation_mode]

    content {
      isolation_mode = managed_network.value
    }
  }

  dynamic "encryption" {
    for_each = var.encryption == null ? [] : [var.encryption]

    content {
      key_id                    = encryption.value.key_id
      key_vault_id              = encryption.value.key_vault_id
      user_assigned_identity_id = encryption.value.user_assigned_identity_id
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) || length(var.identity_ids) > 0
      error_message = "identity_ids must be non-empty when identity_type includes UserAssigned."
    }

    precondition {
      condition     = !var.enable_private_endpoint || var.subnet_id != null
      error_message = "subnet_id is required when enable_private_endpoint = true."
    }
  }
}

resource "azurerm_ai_foundry_project" "this" {
  name               = local.effective_project_name
  location           = var.location
  ai_services_hub_id = azurerm_ai_foundry.this.id

  description                  = var.project_description
  friendly_name                = var.project_friendly_name
  high_business_impact_enabled = var.high_business_impact_enabled

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.project_name != null
      error_message = "project_name is required (no derived default — see variable description)."
    }
  }
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = coalesce(var.private_endpoint_name, "pep-${var.name}")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_ai_foundry.this.id
    subresource_names              = local.pe_subresource_names
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_ai_foundry.this.id

  log_analytics_workspace_id     = var.diagnostic_settings.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_settings.storage_account_id
  eventhub_authorization_rule_id = var.diagnostic_settings.eventhub_authorization_rule_id
  eventhub_name                  = var.diagnostic_settings.eventhub_name
  log_analytics_destination_type = var.diagnostic_settings.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = coalesce(
      var.diagnostic_settings.enabled_log_categories,
      try(data.azurerm_monitor_diagnostic_categories.this[0].log_category_types, [])
    )
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = coalesce(
      var.diagnostic_settings.enabled_metrics,
      try(data.azurerm_monitor_diagnostic_categories.this[0].metrics, [])
    )
    content {
      category = enabled_metric.value
    }
  }
}
```

- [ ] **Step 2: Validate**

Run: `cd modules/ai-foundry && terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Format**

Run: `terraform fmt`
Expected: no output (already formatted).

- [ ] **Step 4: Commit**

```bash
git add modules/ai-foundry/main.tf
git commit -m "feat(ai-foundry): implement hub, project, private endpoint, diagnostics"
```

---

## Task 4: Implement `outputs.tf`

**Files:**
- Modify: `modules/ai-foundry/outputs.tf`

- [ ] **Step 1: Replace the placeholder**

```hcl
# === Standard Outputs ===
output "id" {
  value       = azurerm_ai_foundry.this.id
  description = "AI Foundry hub resource ID"
}

output "name" {
  value       = var.name
  description = "AI Foundry hub name (echo of var.name; resource does not export it)"
}

# === Resource-Specific Outputs ===
output "workspace_id" {
  value       = azurerm_ai_foundry.this.workspace_id
  description = "Immutable workspace ID of the hub"
}

output "discovery_url" {
  value       = azurerm_ai_foundry.this.discovery_url
  description = "Discovery URL for regional service endpoints"
}

output "principal_id" {
  value       = try(azurerm_ai_foundry.this.identity[0].principal_id, null)
  description = "System-assigned identity principal ID (null when not enabled)"
}

output "tenant_id" {
  value       = try(azurerm_ai_foundry.this.identity[0].tenant_id, null)
  description = "System-assigned identity tenant ID (null when not enabled)"
}

# === Project Outputs ===
output "project_id" {
  value       = azurerm_ai_foundry_project.this.id
  description = "Default project resource ID"
}

output "project_name" {
  value       = azurerm_ai_foundry_project.this.name
  description = "Default project name"
}

output "project_workspace_id" {
  value       = azurerm_ai_foundry_project.this.project_id
  description = "Default project immutable workspace ID"
}

# === Private Endpoint Outputs ===
output "private_endpoint_id" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
  description = "Private endpoint resource ID (null when disabled)"
}

output "private_endpoint_ip_address" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address : null
  description = "Private endpoint NIC primary IP (null when disabled)"
}
```

- [ ] **Step 2: Validate**

Run: `terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Commit**

```bash
git add modules/ai-foundry/outputs.tf
git commit -m "feat(ai-foundry): add module outputs"
```

---

## Task 5: Build `examples/basic`

**Files:**
- Create: `modules/ai-foundry/examples/basic/main.tf`
- Create: `modules/ai-foundry/examples/basic/README.md`

- [ ] **Step 1: Create the basic example**

```hcl
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-aif-basic-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_storage_account" "this" {
  name                     = "staifbasicdev001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = false
  shared_access_key_enabled     = true
  min_tls_version               = "TLS1_2"
}

resource "azurerm_key_vault" "this" {
  name                       = "kv-aif-basic-dev-001"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  enable_rbac_authorization = true
}

module "ai_foundry" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "aif-basic-dev-weu-001"

  storage_account_id = azurerm_storage_account.this.id
  key_vault_id       = azurerm_key_vault.this.id

  project_name = "aif-basic-proj"

  tags = {
    project     = "ai-foundry"
    environment = "dev"
    managed_by  = "terraform"
  }
}

output "hub_id" {
  value = module.ai_foundry.id
}

output "project_id" {
  value = module.ai_foundry.project_id
}
```

- [ ] **Step 2: Create the basic README**

```markdown
# basic

Minimum-viable AI Foundry hub + default project on Microsoft-managed encryption with a SystemAssigned identity, public network access disabled, no private endpoint, no diagnostics.

To deploy you'll also need to grant the hub MSI `Storage Blob Data Contributor` on the storage account and `Key Vault Administrator` on the Key Vault — see the module README.
```

- [ ] **Step 3: Validate the example**

Run: `cd modules/ai-foundry/examples/basic && terraform init -backend=false && terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 4: Format and commit**

```bash
cd /mnt/c/Github/framework-terraform
terraform fmt modules/ai-foundry/examples/basic/
git add modules/ai-foundry/examples/basic/
git commit -m "feat(ai-foundry): add basic example"
```

---

## Task 6: Build `examples/complete`

**Files:**
- Create: `modules/ai-foundry/examples/complete/main.tf`
- Create: `modules/ai-foundry/examples/complete/README.md`

- [ ] **Step 1: Create the complete example**

```hcl
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-aif-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-aif-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "this" {
  name                          = "staifcompletedev001"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
  shared_access_key_enabled     = true
  min_tls_version               = "TLS1_2"
}

resource "azurerm_key_vault" "this" {
  name                       = "kv-aif-complete-dev-001"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true
}

resource "azurerm_application_insights" "this" {
  name                = "appi-aif-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
}

resource "azurerm_container_registry" "this" {
  name                = "craifcompletedev001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Premium"
  admin_enabled       = false
}

resource "azurerm_user_assigned_identity" "this" {
  name                = "uami-aif-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-aif-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "pe" {
  name                              = "snet-pe"
  resource_group_name               = azurerm_resource_group.example.name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = ["10.20.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_private_dns_zone" "api" {
  name                = "privatelink.api.azureml.ms"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "notebooks" {
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "api" {
  name                  = "vnet-link-api"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.api.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "notebooks" {
  name                  = "vnet-link-notebooks"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.notebooks.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

module "ai_foundry" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "aif-complete-dev-weu-001"

  storage_account_id      = azurerm_storage_account.this.id
  key_vault_id            = azurerm_key_vault.this.id
  application_insights_id = azurerm_application_insights.this.id
  container_registry_id   = azurerm_container_registry.this.id

  project_name = "aif-complete-proj"

  identity_type                  = "SystemAssigned, UserAssigned"
  identity_ids                   = [azurerm_user_assigned_identity.this.id]
  primary_user_assigned_identity = azurerm_user_assigned_identity.this.id

  managed_network_isolation_mode = "AllowOnlyApprovedOutbound"
  high_business_impact_enabled   = true

  enable_private_endpoint = true
  subnet_id               = azurerm_subnet.pe.id
  private_dns_zone_ids = [
    azurerm_private_dns_zone.api.id,
    azurerm_private_dns_zone.notebooks.id,
  ]

  diagnostic_settings = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  tags = {
    project     = "ai-foundry"
    environment = "dev"
    managed_by  = "terraform"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.api,
    azurerm_private_dns_zone_virtual_network_link.notebooks,
  ]
}

output "hub_id" {
  value = module.ai_foundry.id
}

output "project_id" {
  value = module.ai_foundry.project_id
}

output "private_endpoint_ip" {
  value = module.ai_foundry.private_endpoint_ip_address
}
```

- [ ] **Step 2: Create the complete README**

```markdown
# complete

Demonstrates the full feature surface of `ai-foundry`:

- BYO storage, Key Vault, Application Insights, Container Registry.
- Combined SystemAssigned + UserAssigned identity.
- `managed_network_isolation_mode = "AllowOnlyApprovedOutbound"`.
- Private endpoint with both required private DNS zones (`privatelink.api.azureml.ms`, `privatelink.notebooks.azure.net`).
- Diagnostic settings to a Log Analytics workspace.
- High Business Impact mode enabled.

You still need to grant RBAC to the UAMI on the storage account and Key Vault — not shown here to keep the example focused on the module surface.
```

- [ ] **Step 3: Validate the example**

Run: `cd modules/ai-foundry/examples/complete && terraform init -backend=false && terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 4: Format and commit**

```bash
cd /mnt/c/Github/framework-terraform
terraform fmt modules/ai-foundry/examples/complete/
git add modules/ai-foundry/examples/complete/
git commit -m "feat(ai-foundry): add complete example"
```

---

## Task 7: Generate README docs and verify whole-module pipeline

**Files:**
- Modify: `modules/ai-foundry/README.md` (terraform-docs auto-generated block)

- [ ] **Step 1: Generate docs**

Run: `make docs` (from repo root)
Expected: `modules/ai-foundry/README.md` updated between the `<!-- BEGIN_TF_DOCS -->` markers. No errors.

- [ ] **Step 2: Run module validation**

Run: `make validate MODULE=ai-foundry`
Expected: fmt clean, terraform validate succeeds for the module and both examples.

- [ ] **Step 3: Run lint (if tflint installed)**

Run: `make lint MODULE=ai-foundry`
Expected: no errors. Warnings about provider-version pinning in examples are acceptable.

- [ ] **Step 4: Commit docs**

```bash
git add modules/ai-foundry/README.md
git commit -m "docs(ai-foundry): generate terraform-docs"
```

---

## Task 8: Open PR

- [ ] **Step 1: Push the branch**

```bash
git push -u origin ai-foundry/v1.0.0
```

- [ ] **Step 2: Open PR**

```bash
gh pr create --title "feat(ai-foundry): v1.0.0" --body "$(cat <<'EOF'
## Summary

- New module `ai-foundry` wrapping `azurerm_ai_foundry` (hub) + `azurerm_ai_foundry_project` (default project)
- Optional private endpoint (`amlworkspace` subresource) and diagnostic settings via the established Phase 2 object pattern
- AzureRM-only; connections deliberately out of scope (no native AzureRM resource yet)

Spec: `docs/specs/2026-05-17-ai-foundry-and-acs-email-modules.md`

## Test plan

- [x] `make validate MODULE=ai-foundry` clean
- [x] `examples/basic` and `examples/complete` both `terraform validate` cleanly
- [ ] Real apply against `examples/complete` in sandbox subscription
- [ ] `terraform destroy` cleanly on the same
EOF
)"
```

- [ ] **Step 3: After PR merges, tag the release**

```bash
git checkout main && git pull
git tag ai-foundry/v1.0.0
git push origin ai-foundry/v1.0.0
```
