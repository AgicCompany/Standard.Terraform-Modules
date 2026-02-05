# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Terraform Infrastructure-as-Code Framework** specification for Microsoft Azure. It defines standards, naming conventions, module architecture, and CI/CD patterns for organization-wide Terraform adoption.

**Current Status:** Specification phase (v1.0 draft). Documentation is complete; module implementation has not yet begun.

## Repository Structure

```
docs/
├── terraform-framework-spec.md         # Master framework specification (6 phases)
├── MODULE_STANDARDS.md                 # Module development standards
├── IMPLEMENTATION_PLAN.md              # Module delivery roadmap (21 modules)
└── p1-spec-*.md                        # Individual module specifications (5 P1 modules)
```

## Key Specifications

### Naming Convention (CAF-based)
Pattern: `<resource-prefix>-<project>-<env>-<region>-<instance>`
Example: `rg-payments-dev-weu-001`

### Required Tags (all resources)
- `project`, `environment`, `owner`, `managed_by`

### Module Standard Interface
All modules must accept: `resource_group_name`, `location`, `name`, `tags`

### Design Principles
- **Secure defaults** — most restrictive configuration unless explicitly overridden
- **Private by default** — private endpoints enabled; public access requires explicit flag
- **Environment consistency** — all environments structurally identical (dev/test/stg/prod)

## CI/CD Pipeline Pattern (Planned)

```
Validate Stage:
  terraform fmt -check
  terraform validate
  tflint

Plan Stage:
  terraform init -backend-config=...
  terraform plan -var-file=common.tfvars -var-file=<env>.tfvars -out=plan.tfplan

Apply Stage:
  terraform apply plan.tfplan
```

## Module Implementation Priority

| Tier | Modules |
|------|---------|
| P0 | storage-account, key-vault, virtual-network |
| P1 | network-security-group, log-analytics-workspace, diagnostic-settings, user-assigned-identity, private-dns-zone |
| P2 | app-service-plan, linux-web-app, function-app, container-app-environment, container-app, container-registry, mssql-server, mssql-database, aks |
| P3 | virtual-machine, service-bus, redis-cache, front-door |

## When Working in This Repository

1. **Follow MODULE_STANDARDS.md** when creating or modifying module specifications
2. **Reference terraform-framework-spec.md** for architectural decisions and rationale
3. **Check IMPLEMENTATION_PLAN.md** for module dependencies and priority ordering
4. **Use existing p1-spec-*.md files** as templates for new module specifications
5. **Maintain consistency** with established naming conventions and standard interfaces
