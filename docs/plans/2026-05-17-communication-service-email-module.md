---
title: communication-service-email module v1.0.0 — implementation plan
date: 2026-05-17
status: draft
---

# `communication-service-email` Module v1.0.0 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `modules/communication-service-email/` v1.0.0 implementing the `communication-service-email` design from `docs/specs/2026-05-17-ai-foundry-and-acs-email-modules.md`.

**Architecture:** Single Terraform module composing `azurerm_communication_service`, `azurerm_email_communication_service`, `azurerm_email_communication_service_domain` (Azure-managed or customer-managed), N × `azurerm_email_communication_service_domain_sender_username`, `azurerm_communication_service_email_domain_association`, and optional `azurerm_monitor_diagnostic_setting` on the communication service. Mirrors `modules/application-insights/` for variable layout and `modules/storage-account/` for the `diagnostic_settings` pattern.

**Tech Stack:** Terraform >= 1.10.0, AzureRM >= 4.0.0. No additional providers.

**Reference modules to mirror:** `modules/application-insights/` (variable grouping), `modules/storage-account/` (diagnostic_settings).

---

## File Structure

```
modules/communication-service-email/
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
- `versions.tf` — provider pin.
- `variables.tf` — five standard groups; `location` accepted but documented as not passed to ACS resources.
- `data.tf` — `azurerm_monitor_diagnostic_categories` on the communication service, gated by `count`.
- `locals.tf` — computed email service name, domain name (`AzureManagedDomain` literal when managed; `var.domain_name` when custom), effective sender domain string used in the `sender_usernames` output.
- `main.tf` — communication service + email service + domain + sender usernames (`for_each`) + association + diagnostic setting (count-gated).
- `outputs.tf` — standard + ACS-specific outputs; `verification_records` flattened.
- `CHANGELOG.md` — initial `[1.0.0] - 2026-05-17` entry.
- `README.md` — terraform-docs marker block + Notes section (no `location` on ACS resources, ForceNew foot-guns, custom domain DNS verification workflow).
- `examples/basic/main.tf` — Azure-managed domain, no senders.
- `examples/complete/main.tf` — custom domain, two senders, engagement tracking enabled, diagnostics to LAW.

---

## Task 1: Scaffold the module skeleton

**Files:**
- Create: `modules/communication-service-email/versions.tf`
- Create: `modules/communication-service-email/data.tf`
- Create: `modules/communication-service-email/locals.tf`
- Create: `modules/communication-service-email/main.tf` (placeholder)
- Create: `modules/communication-service-email/outputs.tf` (placeholder)
- Create: `modules/communication-service-email/CHANGELOG.md`
- Create: `modules/communication-service-email/README.md` (terraform-docs markers + notes)

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
  resource_id = azurerm_communication_service.this.id
}
```

- [ ] **Step 3: Create `locals.tf`**

```hcl
locals {
  effective_email_service_name = coalesce(var.email_service_name, "${var.name}-email")
  effective_domain_name        = var.enable_custom_domain ? var.domain_name : "AzureManagedDomain"
  domain_management            = var.enable_custom_domain ? "CustomerManaged" : "AzureManaged"
}
```

- [ ] **Step 4: Create placeholder `main.tf` and `outputs.tf`**

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

- Initial release of `communication-service-email` module.
- Composes `azurerm_communication_service`, `azurerm_email_communication_service`, `azurerm_email_communication_service_domain`, `azurerm_email_communication_service_domain_sender_username` (per-entry `for_each`), and `azurerm_communication_service_email_domain_association`.
- Toggleable Azure-managed (`AzureManagedDomain`) vs customer-managed custom domain via `enable_custom_domain`.
- DNS verification records (domain, SPF, DKIM, DKIM2, DMARC) exposed as the `verification_records` output for custom-domain workflows.
- Optional diagnostic settings on the Communication Service (multi-sink, auto-enumerated categories). Email Communication Service does not currently expose diagnostic categories.
- `sender_usernames` output returns each sender's resource ID, local-part username, and computed `from_address` (`<username>@<effective_domain>`).
- No secret outputs. `primary_connection_string` deliberately not exported.
```

- [ ] **Step 6: Create `README.md`**

```markdown
# communication-service-email

Provisions an Azure Communication Service plus an Email Communication Service, a single Email Domain (Azure-managed by default, customer-managed when `enable_custom_domain = true`), an arbitrary set of sender usernames, and the association between communication service and domain.

## Conventions deviating from the typical module

- `location` is required (module convention) but **not passed to the resources**. Neither `azurerm_communication_service` nor `azurerm_email_communication_service` accepts a `location` argument — Azure deploys them globally. The variable is kept on the module so consumers' standard `module "x" { location = local.location, ... }` pattern works unchanged.
- The module does not expose a private endpoint — AzureRM 4.x has no first-class private-endpoint support for Communication Services.
- The module does not export `primary_connection_string`. Use `data "azurerm_communication_service"` in the consumer if you need it, and write the result to Key Vault rather than to a Terraform output.

## Custom domain workflow

When `enable_custom_domain = true`, set `domain_name = "<your verified domain>"` (e.g. `mail.example.com`). After the first apply, Azure surfaces five DNS verification records (`domain` TXT, `spf` TXT, `dkim` TXT/CNAME, `dkim2` TXT/CNAME, `dmarc` TXT). The module exposes them as the `verification_records` output. Provision them at your DNS registrar, then re-apply to advance verification. The records also exist on the Azure-managed flow but are auto-managed and rarely needed.

## ForceNew foot-guns

- `data_location` on both the communication service and the email service is ForceNew. Changing it destroys and recreates both, which also recreates the domain and senders.
- `name` on `azurerm_email_communication_service_domain_sender_username` is ForceNew. The map keys in `sender_usernames` should be stable.
- Switching `enable_custom_domain` between true and false changes the domain name (`AzureManagedDomain` vs `<custom>`) and the `domain_management` mode, both of which are ForceNew on the domain resource. Plan accordingly.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

- [ ] **Step 7: Verify scaffold loads**

Run: `cd modules/communication-service-email && terraform init -backend=false && terraform validate`
Expected: `Error: Reference to undeclared input variable` (variables file missing) — added next.

- [ ] **Step 8: Commit**

```bash
git checkout -b communication-service-email/v1.0.0
git add modules/communication-service-email/
git commit -m "feat(communication-service-email): scaffold module skeleton"
```

---

## Task 2: Implement `variables.tf` with validations

**Files:**
- Create: `modules/communication-service-email/variables.tf`

- [ ] **Step 1: Write the full variables file**

```hcl
# === Required ===

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region. Required by module convention but NOT passed to the underlying Communication Service or Email Communication Service resources (they are global). Kept on the module so consumers' standard wiring works unchanged."
}

variable "name" {
  type        = string
  description = "Communication Service name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===

variable "data_location" {
  type        = string
  description = "Region where the Communication Service and Email Communication Service store data at rest. Applied to both resources. ForceNew — cannot be changed in place. No default; consumers must choose explicitly because of data-residency policy implications."

  validation {
    condition = contains([
      "Africa", "Asia Pacific", "Australia", "Brazil", "Canada", "Europe",
      "France", "Germany", "India", "Japan", "Korea", "Norway",
      "Switzerland", "UAE", "UK", "United States", "usgov",
    ], var.data_location)
    error_message = "data_location must be one of the Azure-published values (see AzureRM docs for the current list)."
  }
}

# === Optional: Configuration ===

variable "email_service_name" {
  type        = string
  default     = null
  description = "Override the email service resource name. Defaults to <name>-email."
}

variable "domain_name" {
  type        = string
  default     = null
  description = "Fully qualified custom domain (e.g. mail.example.com). Required when enable_custom_domain = true. Ignored when enable_custom_domain = false (Azure-managed flow uses the literal AzureManagedDomain)."

  validation {
    condition     = var.domain_name == null || can(regex("^[a-z0-9.-]+\\.[a-z]{2,}$", var.domain_name))
    error_message = "domain_name must be a lowercase DNS name (e.g. mail.example.com)."
  }
}

variable "user_engagement_tracking_enabled" {
  type        = bool
  default     = false
  description = "Enable user engagement tracking on the email domain."
}

variable "sender_usernames" {
  type = map(object({
    username     = string
    display_name = optional(string)
  }))
  default     = {}
  description = "Map of sender usernames to provision. Keys are arbitrary identifiers used for for_each (changing a key replaces the sender). username is the local-part (e.g. no-reply). display_name is optional."

  validation {
    condition     = alltrue([for s in values(var.sender_usernames) : can(regex("^[a-zA-Z0-9._-]+$", s.username))])
    error_message = "Each sender username must be a non-empty local-part matching ^[a-zA-Z0-9._-]+$."
  }
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
  description = "Optional diagnostic settings attached to the Communication Service (the Email service does not currently expose diagnostic categories). At least one destination is required when non-null."

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

variable "enable_custom_domain" {
  type        = bool
  default     = false
  description = "Use a customer-managed custom domain (CustomerManaged) instead of an Azure-managed *.azurecomm.net subdomain. Requires domain_name to be set."
}

# === Tags ===

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resources"
}
```

- [ ] **Step 2: Validate**

Run: `cd modules/communication-service-email && terraform init -backend=false && terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Commit**

```bash
git add modules/communication-service-email/variables.tf
git commit -m "feat(communication-service-email): add variables with validations"
```

---

## Task 3: Implement `main.tf`

**Files:**
- Modify: `modules/communication-service-email/main.tf`

- [ ] **Step 1: Replace the placeholder with the full main.tf**

```hcl
resource "azurerm_communication_service" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  data_location       = var.data_location

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !var.enable_custom_domain || var.domain_name != null
      error_message = "domain_name is required when enable_custom_domain = true."
    }
  }
}

resource "azurerm_email_communication_service" "this" {
  name                = local.effective_email_service_name
  resource_group_name = var.resource_group_name
  data_location       = var.data_location

  tags = var.tags
}

resource "azurerm_email_communication_service_domain" "this" {
  name              = local.effective_domain_name
  email_service_id  = azurerm_email_communication_service.this.id
  domain_management = local.domain_management

  user_engagement_tracking_enabled = var.user_engagement_tracking_enabled

  tags = var.tags
}

resource "azurerm_email_communication_service_domain_sender_username" "this" {
  for_each = var.sender_usernames

  name                    = each.value.username
  email_service_domain_id = azurerm_email_communication_service_domain.this.id
  display_name            = each.value.display_name
}

resource "azurerm_communication_service_email_domain_association" "this" {
  communication_service_id = azurerm_communication_service.this.id
  email_service_domain_id  = azurerm_email_communication_service_domain.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_communication_service.this.id

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

Run: `terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Format**

Run: `terraform fmt`
Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add modules/communication-service-email/main.tf
git commit -m "feat(communication-service-email): implement resources and association"
```

---

## Task 4: Implement `outputs.tf`

**Files:**
- Modify: `modules/communication-service-email/outputs.tf`

- [ ] **Step 1: Replace the placeholder**

```hcl
# === Standard Outputs ===
output "id" {
  value       = azurerm_communication_service.this.id
  description = "Communication Service resource ID"
}

output "name" {
  value       = azurerm_communication_service.this.name
  description = "Communication Service name"
}

# === Resource-Specific Outputs ===
output "communication_service_id" {
  value       = azurerm_communication_service.this.id
  description = "Alias of id, named for clarity when consumers later add SMS/chat wiring"
}

output "email_service_id" {
  value       = azurerm_email_communication_service.this.id
  description = "Email Communication Service resource ID"
}

output "domain_id" {
  value       = azurerm_email_communication_service_domain.this.id
  description = "Email Communication Service Domain resource ID"
}

output "from_sender_domain" {
  value       = azurerm_email_communication_service_domain.this.from_sender_domain
  description = "P2 sender domain shown to recipients (RFC 5322)"
}

output "mail_from_sender_domain" {
  value       = azurerm_email_communication_service_domain.this.mail_from_sender_domain
  description = "P1 envelope sender domain (RFC 5321)"
}

output "hostname" {
  value       = azurerm_communication_service.this.hostname
  description = "Communication Service hostname (e.g. for SDK configuration)"
}

output "sender_usernames" {
  value = {
    for k, s in azurerm_email_communication_service_domain_sender_username.this :
    k => {
      id           = s.id
      username     = s.name
      from_address = "${s.name}@${azurerm_email_communication_service_domain.this.mail_from_sender_domain}"
    }
  }
  description = "Map of sender keys to { id, username, from_address }. from_address is computed as <username>@<mail_from_sender_domain>."
}

output "verification_records" {
  value = var.enable_custom_domain ? {
    domain = try(one(azurerm_email_communication_service_domain.this.verification_records[*].domain[0]), null)
    spf    = try(one(azurerm_email_communication_service_domain.this.verification_records[*].spf[0]), null)
    dkim   = try(one(azurerm_email_communication_service_domain.this.verification_records[*].dkim[0]), null)
    dkim2  = try(one(azurerm_email_communication_service_domain.this.verification_records[*].dkim2[0]), null)
    dmarc  = try(one(azurerm_email_communication_service_domain.this.verification_records[*].dmarc[0]), null)
  } : null
  description = "DNS verification records required when enable_custom_domain = true. null when using the Azure-managed domain. Each non-null sub-block contains { name, type, value, ttl }."
}
```

- [ ] **Step 2: Validate**

Run: `terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 3: Commit**

```bash
git add modules/communication-service-email/outputs.tf
git commit -m "feat(communication-service-email): add outputs"
```

---

## Task 5: Build `examples/basic`

**Files:**
- Create: `modules/communication-service-email/examples/basic/main.tf`
- Create: `modules/communication-service-email/examples/basic/README.md`

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

resource "azurerm_resource_group" "example" {
  name     = "rg-acsmail-basic-dev-weu-001"
  location = "westeurope"
}

module "acs_email" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "acs-mail-basic-dev-weu-001"
  data_location       = "Europe"

  tags = {
    project     = "acs-email"
    environment = "dev"
    managed_by  = "terraform"
  }
}

output "from_address" {
  value = module.acs_email.mail_from_sender_domain
}
```

- [ ] **Step 2: Create the basic README**

```markdown
# basic

Azure-managed email domain on an `*.azurecomm.net` subdomain. No senders configured, no engagement tracking, no diagnostics. After apply, ACS exposes the auto-generated `donotreply@<managed>.azurecomm.net` MailFrom — that's what `output.from_address` returns.
```

- [ ] **Step 3: Validate the example**

Run: `cd modules/communication-service-email/examples/basic && terraform init -backend=false && terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 4: Format and commit**

```bash
cd /mnt/c/Github/framework-terraform
terraform fmt modules/communication-service-email/examples/basic/
git add modules/communication-service-email/examples/basic/
git commit -m "feat(communication-service-email): add basic example"
```

---

## Task 6: Build `examples/complete`

**Files:**
- Create: `modules/communication-service-email/examples/complete/main.tf`
- Create: `modules/communication-service-email/examples/complete/README.md`

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

resource "azurerm_resource_group" "example" {
  name     = "rg-acsmail-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-acsmail-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "acs_email" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "acs-mail-complete-dev-weu-001"
  data_location       = "Europe"

  enable_custom_domain             = true
  domain_name                      = "mail.example.com"
  user_engagement_tracking_enabled = true

  sender_usernames = {
    no_reply = {
      username     = "no-reply"
      display_name = "Do Not Reply"
    }
    notifications = {
      username     = "notifications"
      display_name = "Notifications"
    }
  }

  diagnostic_settings = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  tags = {
    project     = "acs-email"
    environment = "dev"
    managed_by  = "terraform"
  }
}

output "verification_records" {
  value       = module.acs_email.verification_records
  description = "Provision these at your DNS registrar to complete domain verification"
}

output "sender_addresses" {
  value = {
    for k, s in module.acs_email.sender_usernames : k => s.from_address
  }
}
```

- [ ] **Step 2: Create the complete README**

```markdown
# complete

Demonstrates the full feature surface of `communication-service-email`:

- Customer-managed custom domain (`mail.example.com`).
- Two sender usernames (`no-reply`, `notifications`) with display names.
- User engagement tracking enabled.
- Diagnostic settings sent to a Log Analytics workspace.

After first apply, take the `verification_records` output and provision the matching DNS records at your registrar (`domain` TXT, `spf` TXT, `dkim` TXT/CNAME, `dkim2` TXT/CNAME, `dmarc` TXT). Re-apply to let Azure complete verification.

`output.sender_addresses` returns the ready-to-use `<username>@<mail_from_sender_domain>` strings for each sender, which is what consumers usually wire into their SMTP/SDK configuration.
```

- [ ] **Step 3: Validate the example**

Run: `cd modules/communication-service-email/examples/complete && terraform init -backend=false && terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 4: Format and commit**

```bash
cd /mnt/c/Github/framework-terraform
terraform fmt modules/communication-service-email/examples/complete/
git add modules/communication-service-email/examples/complete/
git commit -m "feat(communication-service-email): add complete example"
```

---

## Task 7: Generate README docs and verify the whole-module pipeline

**Files:**
- Modify: `modules/communication-service-email/README.md` (terraform-docs block)

- [ ] **Step 1: Generate docs**

Run: `make docs` (from repo root)
Expected: README updated between `<!-- BEGIN_TF_DOCS -->` markers.

- [ ] **Step 2: Run module validation**

Run: `make validate MODULE=communication-service-email`
Expected: fmt clean; module + both examples validate.

- [ ] **Step 3: Run lint (if tflint installed)**

Run: `make lint MODULE=communication-service-email`
Expected: no errors.

- [ ] **Step 4: Commit docs**

```bash
git add modules/communication-service-email/README.md
git commit -m "docs(communication-service-email): generate terraform-docs"
```

---

## Task 8: Open PR

- [ ] **Step 1: Push the branch**

```bash
git push -u origin communication-service-email/v1.0.0
```

- [ ] **Step 2: Open PR**

```bash
gh pr create --title "feat(communication-service-email): v1.0.0" --body "$(cat <<'EOF'
## Summary

- New module `communication-service-email` composing Communication Service, Email Communication Service, domain (Azure-managed or customer-managed), sender usernames, and the email domain association
- Diagnostic settings on the Communication Service (the email-side resource doesn't expose categories)
- Outputs include flattened DNS verification records and ready-to-use `from_address` per sender

Spec: `docs/specs/2026-05-17-ai-foundry-and-acs-email-modules.md`

## Test plan

- [x] `make validate MODULE=communication-service-email` clean
- [x] `examples/basic` and `examples/complete` both `terraform validate` cleanly
- [ ] Real apply against `examples/complete` in sandbox subscription (custom domain stays unverified without DNS work — that's expected)
- [ ] `terraform destroy` cleanly on the same
EOF
)"
```

- [ ] **Step 3: After PR merges, tag the release**

```bash
git checkout main && git pull
git tag communication-service-email/v1.0.0
git push origin communication-service-email/v1.0.0
```
