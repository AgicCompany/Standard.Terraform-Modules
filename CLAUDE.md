# CLAUDE.md

## What this is

Reusable Terraform module library for Azure (~40 modules). Consumed by downstream projects via Git source references with per-module version tags.

## Architecture

Monorepo of independent modules under `modules/`. Each module creates one Azure resource (or a tightly coupled set) with secure defaults. Modules do NOT generate resource names -- consumers pass CAF-compliant names from their own `locals.tf`.

Downstream projects consume modules via:
```hcl
source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/<name>?ref=<name>/v<version>"
```

## Module Interface Contract

Every module follows this variable order in `variables.tf`:
1. **Required** -- `resource_group_name`, `location`, `name` (always these three)
2. **Required: Resource-Specific** -- additional mandatory inputs
3. **Optional: Configuration** -- SKUs, tiers, sizing (sensible defaults)
4. **Optional: Feature Flags** -- `enable_*` booleans (security features default `true`, functionality features default `false`)
5. **Tags** -- `tags = map(string)`, default `{}`

Every module outputs at minimum: `id`, `name`. Never output secrets (keys, connection strings, passwords).

## Module File Structure

```
modules/<name>/
├── versions.tf      # Terraform >= 1.9.0, AzureRM >= 4.0.0
├── variables.tf     # Grouped with comment headers (=== Required ===, etc.)
├── locals.tf        # Computed values
├── data.tf          # Data sources
├── main.tf          # Resource definitions
├── outputs.tf       # id + name + resource-specific
├── CHANGELOG.md     # Keep a Changelog format
├── README.md        # terraform-docs auto-generated between markers
└── examples/
    ├── basic/       # Minimum viable usage (required)
    └── complete/    # All features demonstrated (recommended)
```

## Conventions

- **Secure defaults**: TLS 1.2, HTTPS-only, public access disabled, soft delete enabled. Consumers opt in to less restrictive settings, not out of secure ones.
- **Feature flags**: `enable_<feature>` booleans. Security flags default `true`, functionality flags default `false`.
- **Validation**: Inline `validation {}` blocks on variables with constrained values.
- **Conditional resources**: `dynamic` blocks gated by feature flags, or `count = var.enable_x ? 1 : 0`.
- **No provider blocks** in modules -- consumers pass providers via meta-argument if needed.
- **terraform-docs**: README sections between `<!-- BEGIN_TF_DOCS -->` markers are auto-generated. Don't hand-edit those.

## Versioning

Per-module semantic versioning via git tags: `<module-name>/v<major>.<minor>.<patch>`

- **MAJOR**: Breaking changes (renamed variable, removed output, changed default behavior). Changing a default value IS a major bump.
- **MINOR**: New optional variable, new output, backward-compatible feature.
- **PATCH**: Bug fix, doc fix, no interface change.

Update `CHANGELOG.md` before tagging.

## Commands

```bash
# Validate a single module (fmt + validate + examples)
make validate MODULE=<name>

# Validate all modules
make validate-all

# Lint a single module (requires tflint)
make lint MODULE=<name>

# Format a module (fixes files)
make fmt MODULE=<name>

# Generate docs (from repo root)
make docs

# Manual validation (without Make)
cd modules/<name>
terraform fmt -check
terraform validate

# Test a module (manual, pre-release)
cd modules/<name>/examples/complete
terraform init && terraform plan
```

## Don't touch

- Don't change module variable names or remove outputs without flagging it as a breaking change -- downstream projects depend on the interface.
- Don't change default values without a major version bump.
- Integration test stacks in `tests/integration/` are for validation -- don't modify them to fix a module; fix the module.

## Reference

- `docs/MODULE_STANDARDS.md` -- complete standards document
- `docs/IMPLEMENTATION_PLAN.md` -- module priority matrix and build order
- `docs/terraform-framework-spec.md` -- how consuming projects are structured
- `docs/TESTING.md` -- pre-release testing checklist
