---
title: application-insights connection_string output — implementation plan (issue #72)
date: 2026-08-25
status: active
version: 1.0
---

# application-insights `connection_string` Output Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose the Application Insights connection string as a `sensitive` module output (issue #72), fix the README's wrong Security Defaults, and amend the repo standards so the output doesn't read as a violation.

**Architecture:** Pure interface addition to `modules/application-insights` (one output, MINOR bump to 2.1.0) plus documentation alignment across README, CHANGELOG, manifest, MODULE_STANDARDS, MODULE_CATALOG, and CLAUDE.md. The manifest `module_version` stays 2.0.0 in this PR — llamalab lint hard-fails on a pinned tag that doesn't exist; the bump is a post-tag follow-up (spec: Release sequencing).

**Tech Stack:** Terraform (azurerm >= 4.0.0, < 5.0.0), terraform-docs, Make, llamalab lint (Python).

**Spec:** `docs/specs/2026-08-25-appinsights-connection-string-output-design.md`

---

### Task 0: Tooling check

**Files:** none

- [ ] **Step 0.1: Install terraform-docs if missing** (needed by `make docs`; not currently on PATH)

```bash
command -v terraform-docs || {
  curl -sSLo /tmp/claude-1000/-home-dev-workspace-framework-terraform-issue72/ed2ed447-9a5d-40ed-9b1e-25e319054366/scratchpad/td.tar.gz \
    https://github.com/terraform-docs/terraform-docs/releases/download/v0.20.0/terraform-docs-v0.20.0-linux-amd64.tar.gz
  mkdir -p ~/.local/bin
  tar -xzf /tmp/claude-1000/-home-dev-workspace-framework-terraform-issue72/ed2ed447-9a5d-40ed-9b1e-25e319054366/scratchpad/td.tar.gz -C ~/.local/bin terraform-docs
  export PATH="$HOME/.local/bin:$PATH"
}
terraform-docs --version
```

Expected: `terraform-docs version v0.20.0` (or whatever is already installed).
If the download fails (no network), skip `make docs` steps and note in the final report that CI's docs job must regenerate; do NOT hand-edit the TF_DOCS blocks.

- [ ] **Step 0.2: Note tflint availability** — `command -v tflint`. It is likely absent; `make lint` then exits with its install message. That is acceptable: record it and rely on CI. Do not install unless trivially available.

### Task 1: Add the output (TDD via the complete example)

**Files:**
- Modify: `modules/application-insights/examples/complete/main.tf` (append at end)
- Modify: `modules/application-insights/outputs.tf:12-16` (Resource-Specific section)

- [ ] **Step 1.1: Write the "failing test" — reference the not-yet-existing output from the complete example.** Append to `modules/application-insights/examples/complete/main.tf`:

```hcl
# Demonstrates pass-through without display: Terraform requires sensitive = true
# on any output derived from a sensitive value, so the string is never printed.
output "connection_string" {
  value     = module.application_insights.connection_string
  sensitive = true
}
```

- [ ] **Step 1.2: Run validation, expect failure**

```bash
cd /home/dev/workspace/framework-terraform-issue72 && make validate MODULE=application-insights
```

Expected: FAIL in the complete example with `Unsupported attribute ... This object does not have an attribute named "connection_string"` (module validate itself passes; the example fails).

- [ ] **Step 1.3: Add the output.** In `modules/application-insights/outputs.tf`, under `# === Resource-Specific Outputs ===`, after the `app_id` output:

```hcl
output "connection_string" {
  value       = azurerm_application_insights.this.connection_string
  description = "Application Insights connection string (telemetry destination). Not a credential while local_authentication_disabled = true (the default); treat as a secret if you enable local authentication."
  sensitive   = true
}
```

- [ ] **Step 1.4: Run validation, expect pass**

```bash
make validate MODULE=application-insights
```

Expected: `=== application-insights OK ===` (fmt check, module validate, basic + complete example validate all green).

- [ ] **Step 1.5: Commit**

```bash
git add modules/application-insights/outputs.tf modules/application-insights/examples/complete/main.tf
git commit -m "feat(application-insights): add sensitive connection_string output

Closes #72. With local_authentication_disabled = true (the default) the
connection string identifies the telemetry destination and is not a
credential; ingestion requires Entra ID + RBAC. Marked sensitive; the
complete example demonstrates sensitive pass-through.

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_019uWYaoe9PojjKzuxTXQ7on"
```

### Task 2: Module README (hand-written sections) + CHANGELOG + regenerate docs

**Files:**
- Modify: `modules/application-insights/README.md` (Usage ref line 11; Features lines 22-29; Security Defaults lines 31-35; Notes line 108)
- Modify: `modules/application-insights/CHANGELOG.md:5-9`
- Regenerated: all `<!-- BEGIN_TF_DOCS -->` blocks via `make docs`

- [ ] **Step 2.1: Usage ref.** Line 11: change `?ref=application-insights/v1.0.0` → `?ref=application-insights/v2.1.0`.

- [ ] **Step 2.2: Features list.** Replace the last two bullets (`- Local authentication toggle` stays; replace `- App ID output for cross-project consumption`):

```markdown
- Local authentication toggle
- Sensitive `connection_string` output for declarative telemetry wiring
- Resource ID output for cross-project consumption
```

- [ ] **Step 2.3: Security Defaults section.** Replace the three bullets under `## Security Defaults` with:

```markdown
- IP masking enabled by default (client IPs are anonymized)
- Local authentication disabled by default (`local_authentication_disabled = true`); set it to `false` only if API key auth is required
- Internet ingestion disabled by default (`internet_ingestion_enabled = false`); enable it or use Private Link for telemetry ingestion
- Internet query disabled by default (`internet_query_enabled = false`)
```

- [ ] **Step 2.4: Notes section.** Replace the final bullet (`- **Function App / Web App integration:** ... az monitor app-insights component show`.) with:

````markdown
- **Function App / Web App integration:** Wire telemetry declaratively via the sensitive `connection_string` output:

  ```hcl
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = module.application_insights.connection_string
  }
  ```

  Terraform's sensitivity propagates automatically — any value containing the connection string renders as `(sensitive value)` in plans; use `nonsensitive()` only deliberately and where justified. The connection string identifies the telemetry destination and is not a credential while `local_authentication_disabled = true` (the default): ingestion requires a Microsoft Entra ID token authorized via RBAC. If you enable local authentication, treat this value as a secret.
````

- [ ] **Step 2.5: CHANGELOG.** Replace the current `## [Unreleased]` section (lines 5-9) with:

```markdown
## [2.1.0] - 2026-08-25

### Added

- `connection_string` sensitive output for declarative telemetry configuration (Azure Monitor OpenTelemetry). Partially reverses the 2.0.0 removal: with `local_authentication_disabled = true` (the default) the connection string identifies the telemetry destination and is not a credential (ingestion requires Entra ID + RBAC). The value resides in Terraform state regardless of the output; marking it `sensitive` keeps it out of plan/apply display. See MODULE_STANDARDS.md §4 (possession test).

### Changed

- Capped the `azurerm` provider constraint to `>= 4.x, < 5.0.0` in the module and its examples, pending a deliberate azurerm 5.x migration. No interface or behavior change.

### Fixed

- README **Security Defaults** section now describes the real defaults: local authentication disabled, internet ingestion disabled, internet query disabled.
```

- [ ] **Step 2.6: Regenerate terraform-docs**

```bash
export PATH="$HOME/.local/bin:$PATH" && make docs && git status --porcelain
```

Expected: "Done. All module and example READMEs updated." Changed files should be limited to `modules/application-insights/**` READMEs (module + examples — the complete example README gains the new output row). If OTHER modules' READMEs change, they were stale on main — leave them unstaged and flag in the final report.

- [ ] **Step 2.7: Verify the generated Outputs table** in `modules/application-insights/README.md` now contains a `connection_string` row. Run: `grep -n "output_connection_string" modules/application-insights/README.md` — expect one hit inside the TF_DOCS block.

- [ ] **Step 2.8: Commit**

```bash
git add modules/application-insights/README.md modules/application-insights/CHANGELOG.md modules/application-insights/examples/*/README.md
git commit -m "docs(application-insights): document connection_string, fix Security Defaults, changelog 2.1.0

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_019uWYaoe9PojjKzuxTXQ7on"
```

### Task 3: Manifest omission comment (version stays 2.0.0)

**Files:**
- Modify: `modules/application-insights/manifest.yaml:152` (top of `outputs_display`)

- [ ] **Step 3.1:** Inside `outputs_display:`, after the `public_app_insights_id` entry (end of the mapping), add — mirroring `modules/front-door/manifest.yaml`'s `custom_domain_validation_tokens` precedent:

```yaml
  # NOTE: connection_string is intentionally omitted. outputs.tf marks it
  # sensitive=true; T1 §7.1 check 8 (lint.8) forbids displaying sensitive
  # outputs. Consumers wire it module-to-module in Terraform; it must never
  # be rendered in the vending-machine UI.
```

Do NOT change `metadata.module_version` (stays `"2.0.0"`) or `schema_last_updated` — the 2.1.0 bump is a post-tag follow-up (spec: Release sequencing).

- [ ] **Step 3.2: Run llamalab lint as CI will**

```bash
python3 -m tools.llamalab_lint.cli --framework . modules/application-insights/manifest.yaml
```

Expected: exit 0, no ERROR findings (it introspects the pinned `application-insights/v2.0.0` tag, so the new output is invisible to it; this run proves the manifest still parses and the pinned tag resolves). If `python3` lacks a dependency (e.g. yaml), use `/home/dev/.venv/bin/python3`.

- [ ] **Step 3.3: Commit**

```bash
git add modules/application-insights/manifest.yaml
git commit -m "docs(manifest): record intentional omission of connection_string from outputs_display

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_019uWYaoe9PojjKzuxTXQ7on"
```

### Task 4: Standards + catalog alignment

**Files:**
- Modify: `docs/MODULE_STANDARDS.md:131` and the Forbidden Outputs subsection (~lines 159-167)
- Modify: `CLAUDE.md:25`
- Modify: `docs/MODULE_CATALOG.md:1031,1050`

- [ ] **Step 4.1: MODULE_STANDARDS.md opening sentence.** Line 131: `Outputs are organized by category. Secrets are never exposed as outputs.` → `Outputs are organized by category. Credentials are never exposed as outputs.`

- [ ] **Step 4.2: Forbidden Outputs subsection.** After the existing closing line `If a consumer needs secrets, they retrieve them via data source or Key Vault reference.`, append:

```markdown

The governing test is whether **possession of the value grants access** to the resource or its data. Access keys, SAS tokens, and connection strings with embedded credentials fail this test regardless of any `sensitive` marking and stay forbidden. Values that merely identify a destination and cannot authenticate on their own — for example, the Application Insights connection string while local authentication is disabled — may be exposed as outputs and **must** be marked `sensitive = true`. The module must document any configuration under which such a value becomes a credential (for Application Insights: enabling local authentication).
```

- [ ] **Step 4.3: CLAUDE.md line 25.** Replace:

`Every module outputs at minimum: \`id\`, \`name\`. Never output secrets (keys, connection strings, passwords).`

with:

`Every module outputs at minimum: \`id\`, \`name\`. Never output credentials (access keys, passwords, secret-bearing connection strings). Non-credential identifiers may be exposed as \`sensitive\` outputs per the possession test in MODULE_STANDARDS.md §4.`

- [ ] **Step 4.4: MODULE_CATALOG.md.** Line 1031 header: `### application-insights \`v2.0.0\`` → `### application-insights \`v2.1.0\``. Line 1050 outputs line, replace with:

```markdown
**Outputs:** `id`, `name`, `app_id`, `public_app_insights_id`, `connection_string` (sensitive; added in v2.1.0 for declarative telemetry wiring). `instrumentation_key` remains removed (v2.0.0) — with local authentication disabled (the default) the connection string is a destination identifier, not a credential.
```

- [ ] **Step 4.5: Commit**

```bash
git add docs/MODULE_STANDARDS.md docs/MODULE_CATALOG.md CLAUDE.md
git commit -m "docs(standards): possession test for sensitive non-credential outputs; catalog entry for application-insights 2.1.0

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_019uWYaoe9PojjKzuxTXQ7on"
```

### Task 5: Final verification

**Files:** none

- [ ] **Step 5.1:** `make validate MODULE=application-insights` — expect `=== application-insights OK ===`.
- [ ] **Step 5.2:** `make lint MODULE=application-insights` — expect tflint pass, or the "tflint is not installed" message (acceptable; note it).
- [ ] **Step 5.3:** `python3 -m tools.llamalab_lint.cli --framework . modules/application-insights/manifest.yaml` — expect exit 0.
- [ ] **Step 5.4:** `git status --porcelain` — expect empty (or only stale other-module docs deliberately left unstaged, flagged in report).
- [ ] **Step 5.5:** Re-read issue #72's checklist and confirm every box maps to a commit; report the mapping. Remaining post-merge items (tag `application-insights/v2.1.0`, then manifest bump follow-up) are called out explicitly as NOT done in this PR, per the spec's Release sequencing.
