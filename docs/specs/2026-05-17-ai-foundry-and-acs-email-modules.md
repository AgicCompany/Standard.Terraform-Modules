---
title: AI Foundry and Communication Services Email modules
date: 2026-05-17
status: draft
---

## Context

Two gaps in the module library identified while scoping a downstream consumer needing:

- AI Foundry (hub + project) for an LLM/agent workload.
- Azure Communication Services email for transactional mail.

Neither exists today. Both fit cleanly in the existing module pattern and the Phase 3 enhancement track (alongside the already-planned `role-assignment`, `entra-group`, `azure-firewall`). This spec covers only the two modules above; Phase 3 sub-modules remain in their own backlog.

Both modules follow the established module contract documented in `docs/MODULE_STANDARDS.md` and `CLAUDE.md`:

- Standard variable groups (Required / Required: Resource-Specific / Optional: Config / Optional: Feature Flags / Tags).
- Standard outputs (`id`, `name`, plus resource-specific).
- Secure defaults; consumers opt out, not in.
- `enable_<feature>` flags; `enable_private_endpoint` (singular).
- `diagnostic_settings` Phase 2 pattern where the underlying resource supports it.
- `examples/basic` + `examples/complete`.
- `versions.tf`: Terraform >= 1.10.0, AzureRM >= 4.0.0.

## Decisions out of scope

- **AI Foundry connections** (Azure OpenAI / Search / Storage links). AzureRM 4.x does not expose a `*_connection` resource for `ai_foundry`. Consumers wire connections via CLI / portal / AzAPI in their own root module. Reconsider when AzureRM ships native support.
- **AI Foundry deployments and compute** (model deployments, compute clusters/instances). Belong to separate, future modules.
- **ACS Phone numbers, SMS, Chat, Identity**. This module is email-only. A generic `communication-service` module can come later if needed.
- **ACS Custom domain DNS automation**. The module exposes the DNS records needed for verification; consumers manage their own DNS (often at a non-Azure registrar).

---

## Module 1: `ai-foundry`

### Resources

| Resource | Purpose |
|---|---|
| `azurerm_ai_foundry` | Hub workspace |
| `azurerm_ai_foundry_project` | One default project under the hub |
| `azurerm_private_endpoint` | Optional, gated by `enable_private_endpoint`; subresource `"amlworkspace"` |
| `azurerm_monitor_diagnostic_setting` | Optional, gated by `diagnostic_settings != null` |

### Variables

**Required**

| Name | Type | Notes |
|---|---|---|
| `resource_group_name` | string | |
| `location` | string | |
| `name` | string | Hub name. CAF-compliant; consumer-supplied. |

**Required: Resource-Specific**

| Name | Type | Notes |
|---|---|---|
| `storage_account_id` | string | Hub backing storage |
| `key_vault_id` | string | Hub backing key vault |

**Optional: Configuration**

| Name | Type | Default | Notes |
|---|---|---|---|
| `application_insights_id` | string | `null` | |
| `container_registry_id` | string | `null` | |
| `description` | string | `null` | Maps to hub `description` |
| `friendly_name` | string | `null` | Maps to hub `friendly_name` |
| `project_name` | string | `null` | Required; no default. Azure constraints on AML project names (alphanumeric + hyphens, ~32 char max) make a derived default unsafe when `var.name` is near the hub max length. Force consumers to choose. |
| `project_description` | string | `null` | |
| `project_friendly_name` | string | `null` | |
| `identity_type` | string | `"SystemAssigned"` | The hub `identity` block is **provider-required** — module always emits it. Validation: exactly one of `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (note the literal space after the comma in the third form — AzureRM is strict). |
| `identity_ids` | list(string) | `[]` | Required when `identity_type` includes `UserAssigned` |
| `primary_user_assigned_identity` | string | `null` | UAMI id for encryption when applicable |
| `managed_network_isolation_mode` | string | `null` (= omit block) | Validation: one of `null`, `Disabled`, `AllowOnlyApprovedOutbound`, `AllowInternetOutbound` |
| `high_business_impact_enabled` | bool | `false` | |
| `encryption` | object({ key_id, key_vault_id, user_assigned_identity_id }) | `null` | CMK; module wires the block when non-null |
| `private_endpoint_subnet_id` | string | `null` | Required when `enable_private_endpoint = true` |
| `private_dns_zone_ids` | list(string) | `[]` | Optional zone group |
| `private_endpoint_name` | string | `"${var.name}-pe"` | Override allowed |
| `diagnostic_settings` | object (per Phase 2 contract: `log_analytics_workspace_id`, `storage_account_id`, `eventhub_*`, `log_categories` optional override) | `null` | When non-null, module enumerates categories via `azurerm_monitor_diagnostic_categories` data source |
| `tags` | map(string) | `{}` | |

**Optional: Feature Flags**

| Name | Type | Default | Notes |
|---|---|---|---|
| `enable_public_network_access` | bool | `false` | Translated to `public_network_access = "Disabled"` (secure default) |
| `enable_private_endpoint` | bool | `false` | |

### Validation rules

- `identity_type` ∈ `{"SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"}`.
- When `identity_type` includes `UserAssigned`, `length(identity_ids) > 0` must hold.
- `managed_network_isolation_mode` validated as: `var.managed_network_isolation_mode == null || contains(["Disabled", "AllowOnlyApprovedOutbound", "AllowInternetOutbound"], var.managed_network_isolation_mode)` — `null` means the `managed_network` block is omitted entirely.
- When `enable_private_endpoint = true`, `private_endpoint_subnet_id != null`.

### Project linkage and ForceNew foot-guns

- The project resource is wired via `ai_services_hub_id = azurerm_ai_foundry.this.id` — implicit dependency, no `depends_on` needed.
- The following hub arguments are **ForceNew** and will destroy & recreate the hub (cascade-destroying the default project): `name`, `location`, `resource_group_name`, `key_vault_id`, `storage_account_id`, `high_business_impact_enabled`, the entire `encryption` block. Document in README. Consumers should not flip `high_business_impact_enabled` or `encryption` after first apply unless they accept the rebuild.
- Project `name`, `location`, and `high_business_impact_enabled` are also ForceNew on the project resource.

### Private endpoint subresource

`azurerm_ai_foundry` is `Microsoft.MachineLearningServices/workspaces` (kind = Hub), so the PE `subresource_names` value is `["amlworkspace"]` and the matching private DNS zones are `privatelink.api.azureml.ms` + `privatelink.notebooks.azure.net` — **not** the Cognitive Services zone (`privatelink.cognitiveservices.azure.com`). The newer Cognitive-Services-backed "AI Foundry account" is a different resource and out of scope for this module; document this in the README to prevent zone-misconfiguration.

### Required permissions (document in README)

The hub system-assigned (or user-assigned) MSI needs RBAC on the backing storage account and key vault to function correctly (notebook scratch, CMK access, etc.). The module does not grant these — consumers must use `azurerm_role_assignment` separately. README should list the minimum role set.

### Outputs

| Name | Notes |
|---|---|
| `id` | Hub resource ID |
| `name` | Hub name (echo of `var.name` — resource does not export it) |
| `workspace_id` | Hub immutable workspace ID |
| `discovery_url` | Hub discovery URL |
| `principal_id` | System-assigned identity principal ID (or `null` when not enabled) |
| `tenant_id` | System-assigned identity tenant ID (or `null` when not enabled) |
| `project_id` | Default project resource ID |
| `project_name` | Default project name (echo of computed name) |
| `project_workspace_id` | Default project immutable ID (the resource's exported `project_id`) |
| `private_endpoint_id` | `null` when PE disabled |
| `private_endpoint_ip_address` | First custom IP from the PE NIC, or `null` |

No secret outputs.

### Examples

- `examples/basic/` — minimum: RG, KV, storage account, hub + project. SystemAssigned identity. Public access disabled. No PE.
- `examples/complete/` — adds: App Insights, ACR, UserAssigned identity, `managed_network_isolation_mode = "AllowOnlyApprovedOutbound"`, PE in a sample subnet with a private DNS zone, `diagnostic_settings` to a Log Analytics workspace, CMK encryption.

---

## Module 2: `communication-service-email`

### Resources

| Resource | Purpose |
|---|---|
| `azurerm_communication_service` | Top-level ACS resource |
| `azurerm_email_communication_service` | Email-side resource |
| `azurerm_email_communication_service_domain` | Either `AzureManagedDomain` or a custom domain |
| `azurerm_email_communication_service_domain_sender_username` × N | One per entry in `sender_usernames` |
| `azurerm_communication_service_email_domain_association` | Links communication service to the domain |
| `azurerm_monitor_diagnostic_setting` | Optional, on the Communication Service |

### Variables

**Required**

| Name | Type | Notes |
|---|---|---|
| `resource_group_name` | string | |
| `location` | string | Required by module convention but **not passed to ACS resources** — `azurerm_communication_service` and `azurerm_email_communication_service` do not accept a `location` argument (Azure deploys them globally). Kept on the module so consumers' standard `module "x" { location = local.location, ... }` pattern works unchanged. |
| `name` | string | Communication Service name. CAF-compliant; consumer-supplied. |

**Required: Resource-Specific**

| Name | Type | Notes |
|---|---|---|
| `data_location` | string | Validation: one of `Africa`, `Asia Pacific`, `Australia`, `Brazil`, `Canada`, `Europe`, `France`, `Germany`, `India`, `Japan`, `Korea`, `Norway`, `Switzerland`, `UAE`, `UK`, `United States`, `usgov`. Applied to both Communication Service and Email Communication Service. |

**Optional: Configuration**

| Name | Type | Default | Notes |
|---|---|---|---|
| `email_service_name` | string | `"${var.name}-email"` | |
| `domain_name` | string | `null` | Required when `enable_custom_domain = true` (e.g., `mail.example.com`). Ignored otherwise (Azure-managed always uses literal `AzureManagedDomain`). |
| `user_engagement_tracking_enabled` | bool | `false` | |
| `sender_usernames` | `map(object({ username = string, display_name = optional(string) }))` | `{}` | Map keys are arbitrary identifiers used for `for_each`. `username` is the local-part (e.g. `no-reply`); `display_name` optional. |
| `diagnostic_settings` | object (Phase 2 contract) | `null` | Attached to the Communication Service resource (which supports diagnostics; Email Communication Service does not). |
| `tags` | map(string) | `{}` | |

**Optional: Feature Flags**

| Name | Type | Default | Notes |
|---|---|---|---|
| `enable_custom_domain` | bool | `false` | When `false`: `domain_management = "AzureManaged"`, domain name forced to `AzureManagedDomain`. When `true`: `domain_management = "CustomerManaged"`, domain name = `var.domain_name`; consumer is responsible for DNS verification using the records exposed as outputs. |

### Validation rules

- `data_location` ∈ the documented Azure list above.
- When `enable_custom_domain = true`, `domain_name != null` and matches `^[a-z0-9.-]+\\.[a-z]{2,}$`.
- Each entry in `sender_usernames` must have a non-empty `username` matching `^[a-zA-Z0-9._-]+$`.

### Ordering and ForceNew foot-guns

- Wire `azurerm_communication_service_email_domain_association` via attribute references (`communication_service_id`, `email_service_domain_id`) — implicit dependency only, no `depends_on` needed.
- `azurerm_email_communication_service_domain_sender_username.name` is ForceNew. Map keys in `sender_usernames` should map 1:1 to the desired `username` and be stable — renaming a key destroys and recreates the sender.
- `data_location` is ForceNew on both ACS resources. Document in README that changing region requires destroy/recreate.

### Diagnostic-settings note

`azurerm_email_communication_service` does not appear to support diagnostic settings as of AzureRM 4.x (no diagnostic categories returned by the Azure resource provider). v1.0.0 attaches diagnostics only to `azurerm_communication_service`. If a future provider release adds categories on the email-side resource, re-evaluate.

### Outputs

| Name | Notes |
|---|---|
| `id` | Communication Service ID |
| `name` | Communication Service name |
| `communication_service_id` | alias of `id` for clarity in consumers wiring SMS/chat later |
| `email_service_id` | |
| `domain_id` | |
| `from_sender_domain` | The P2 `from_sender_domain` attribute exported by the domain resource |
| `mail_from_sender_domain` | The P1 envelope sender domain |
| `hostname` | Communication Service hostname (useful for consumers wiring SDKs) |
| `sender_usernames` | `map(object({ id, username, from_address }))` — `from_address` computed as `"${username}@${domain_name_effective}"` where `domain_name_effective` is the managed subdomain or the custom domain. Lets consumers wire SMTP/SDK config directly without recomputing. |
| `verification_records` | When `enable_custom_domain = true`: object with `domain`, `spf`, `dkim`, `dkim2`, `dmarc` — each `{ name, type, value, ttl }`. The provider exposes `verification_records` as a list of single-block sets; module flattens via `try(one(...))` to a clean object. `null` when custom domain disabled. |
| `primary_connection_string` | **NOT EXPORTED.** Available on the underlying resource as a sensitive attribute, but emitting it as a module output would surface it in state diff and downstream module outputs. Consumers needing it should reference `azurerm_communication_service` via data source and write to Key Vault. |

### Examples

- `examples/basic/` — Azure-managed domain, no senders, default data_location `Europe`. Working email out of the box.
- `examples/complete/` — custom domain, two sender usernames (`no-reply`, `notifications`), `user_engagement_tracking_enabled = true`, `diagnostic_settings` to a Log Analytics workspace. README in the example shows how to use the `verification_records` output to provision DNS at the registrar.

---

## Conventions adhered to

- `min_tls_version` — N/A for both resources (Azure-managed TLS, no provider knob).
- `enable_private_endpoint` (singular) — used on AI Foundry; ACS does not currently expose private endpoints in AzureRM, so omitted there.
- `diagnostic_settings` — Phase 2 object pattern on both modules where supported.
- Identity defaults secure: AI Foundry defaults `SystemAssigned`; public access defaults disabled.
- No secret outputs.
- No provider blocks inside the modules.

## Versioning

Both ship as v1.0.0 under their own tags: `ai-foundry/v1.0.0`, `communication-service-email/v1.0.0`. CHANGELOG.md initialized per Keep a Changelog.

## Testing checklist (per `docs/TESTING.md`)

For each module, before tagging:

- `make validate MODULE=<name>` passes.
- `make lint MODULE=<name>` clean (or known-acceptable warnings documented).
- `examples/basic` and `examples/complete` both `terraform validate` cleanly.
- One real `terraform apply` in a sandbox subscription against `examples/complete`, followed by `terraform destroy`.
- README regenerated via `make docs`.
