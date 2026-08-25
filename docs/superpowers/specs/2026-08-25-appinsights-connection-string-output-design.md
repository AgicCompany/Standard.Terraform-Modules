# Design: expose `connection_string` from `modules/application-insights` (issue #72)

**Date:** 2026-08-25
**Issue:** [#72](https://github.com/AgicCompany/Standard.Terraform-Modules/issues/72) — required by AgicCompany/IP.infrastructure-as-a-platform#15
**Module version:** 2.0.0 → **2.1.0** (MINOR: new backward-compatible output)

## Problem

The module creates a workspace-based Application Insights resource but exposes only
`id`, `name`, `app_id`, and `public_app_insights_id`. Configuring application telemetry
(Azure Monitor OpenTelemetry) requires the resource's **connection string**, which today
the README tells consumers to fetch out-of-band (portal / `az monitor app-insights
component show`).

Terraform modules are strict encapsulation boundaries: a sibling module or root config
can only consume values a module declares as outputs. Without this output, a consumer
composing App Insights + an application in one configuration has no clean path:

- A `data "azurerm_application_insights"` lookup fails on first apply (resource doesn't
  exist yet); the `depends_on` workaround defers the read to apply time and causes
  perpetual "(known after apply)" churn on everything downstream.
- Declaring the resource directly bypasses the module library and its secure defaults.
- Forking/wrapping the module duplicates maintenance.

## History and standards conflict

- **v2.0.0 of this module deliberately removed** `connection_string`,
  `instrumentation_key`, and `public_connection_string` as a breaking change, pointing
  consumers at data sources / Key Vault.
- `docs/MODULE_STANDARDS.md` §4 forbids outputs of "connection strings **containing
  secrets**"; the repo `CLAUDE.md` contract line reads bluntly "Never output secrets
  (keys, connection strings, passwords)".

**Why re-adding is nevertheless correct:** with `local_authentication_disabled = true`
(this module's default), the Application Insights connection string is a telemetry
*destination identifier*, not a credential — ingestion requires a Microsoft Entra ID
token authorized via RBAC, and Microsoft's documentation states the connection string is
not a security token. The value already resides in Terraform state as a resource
attribute whether or not it is output, so the output moves zero secrets. To prevent this
from re-reading as a violation (and being "cleaned up" again by a future security
sweep), the standards documents are amended in the same change (see below).

## Decision test for the standards carve-out

An output remains **forbidden** if **possessing the value grants access** to the
resource or its data. Storage account keys, SAS tokens, and SQL connection strings with
embedded passwords all fail this test regardless of `sensitive` marking. The App
Insights connection string with Entra-only auth passes it: possession grants nothing
without a separately authorized identity.

**Known conditional case:** the module permits opting in to local authentication
(`local_authentication_disabled = false`); in that configuration the embedded
`InstrumentationKey` *is* a usable ingestion credential. Marginal exposure is limited to
a consumer who both enables local auth and re-exports the output carelessly (the value
is in their state either way, and the output is sensitive-marked either way). Handled by
documentation, not by a `precondition` — failing the output when local auth is enabled
would break legitimate opt-in consumers.

## Changes

### 1. `modules/application-insights/outputs.tf`

Add under `# === Resource-Specific Outputs ===`:

```hcl
output "connection_string" {
  value       = azurerm_application_insights.this.connection_string
  description = "Application Insights connection string (telemetry destination). Not a credential while local_authentication_disabled = true (the default); treat as a secret if you enable local authentication."
  sensitive   = true
}
```

### 2. `modules/application-insights/README.md` (hand-written sections only)

- **Security Defaults** — correct to the real defaults from `variables.tf`:
  - IP masking enabled by default (client IPs anonymized)
  - Local authentication **disabled** by default (`local_authentication_disabled = true`; API-key auth requires opt-out)
  - Internet ingestion **disabled** by default (`internet_ingestion_enabled = false`)
  - Internet query **disabled** by default (`internet_query_enabled = false`)
- **Notes** — replace the "retrieve via portal / `az monitor app-insights component
  show`" guidance with declarative wiring:

  ```hcl
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = module.application_insights.connection_string
  }
  ```

  plus two caveats: (a) Terraform's sensitivity taint propagates — a map containing the
  value renders wholly as `(sensitive value)` in plans; scope deliberately with
  `nonsensitive()` only where justified; (b) if local authentication is enabled, treat
  the value as a secret.
- **Features** list: mention the connection string output.
- The `<!-- BEGIN_TF_DOCS -->` block is regenerated, not hand-edited.

### 3. `modules/application-insights/examples/complete/main.tf`

Re-export the output, demonstrating pass-through-without-display:

```hcl
output "connection_string" {
  value     = module.application_insights.connection_string
  sensitive = true
}
```

(Terraform *requires* `sensitive = true` on any output derived from a sensitive value —
the example doubles as documentation of that.) A full web-app wiring example would
bloat the example; the README snippet covers it. The `basic` example is unchanged.

### 4. `docs/MODULE_STANDARDS.md` §4 Forbidden Outputs

Amend with the possession test:

- Keep the forbidden list (access keys, connection strings containing secrets,
  passwords, certificates/private keys).
- Add: the governing test is whether **possession of the value grants access**. Values
  that merely identify a destination and cannot authenticate on their own (e.g. the
  Application Insights connection string when local authentication is disabled) may be
  exposed as outputs and **must** be marked `sensitive = true`.

### 5. Repo `CLAUDE.md`

Align the Module Interface Contract line so it no longer contradicts the standards doc,
e.g.: "Never output credentials (keys, passwords, secret-bearing connection strings).
Non-credential identifiers may be exposed as `sensitive` outputs per
MODULE_STANDARDS.md §4."

### 6. `modules/application-insights/manifest.yaml`

- Bump `metadata.module_version` to `2.1.0` (and `schema_last_updated` to 2026-08-25).
- **Deliberately do NOT add** `connection_string` to `outputs_display`: llamalab
  `lint.8` hard-errors when a sensitive output is displayed. This is the existing
  platform guardrail against rendering the value in the vending-machine UI.

### 7. `modules/application-insights/CHANGELOG.md`

`[2.1.0]` Added entry: `connection_string` sensitive output; note it reverses part of
the v2.0.0 removal, with the rationale (non-credential under default Entra-only auth,
sensitive-marked). Also note the README Security Defaults correction (doc fix) and fold
in the currently `[Unreleased]` azurerm `< 5.0.0` cap note per Keep-a-Changelog flow.

## Out of scope

- `instrumentation_key` / `public_connection_string` (also removed in v2.0.0) stay
  removed — the issue asks only for `connection_string`, and the instrumentation key
  alone has no non-credential reading.
- No changes to module security defaults or variables.
- No `outputs_display` / platform-side changes beyond the version bump.
- No git tag in this change; `application-insights/v2.1.0` is tagged at release per
  repo convention (CHANGELOG updated before tagging).

## Verification

- `make fmt MODULE=application-insights` / `make validate MODULE=application-insights`
  (fmt + validate + examples)
- `make lint MODULE=application-insights` (tflint)
- `make docs` — regenerate terraform-docs; confirm the new output appears in the
  generated table
- llamalab lint (`tools/llamalab_lint`) against the module, confirming lint.8 stays
  green with the sensitive output absent from `outputs_display`
- `pre-commit run` on touched files
