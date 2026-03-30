# PE Naming Override Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Change PE default naming from `pe-{name}` to `pep-{name}` (CAF-compliant), add `custom_network_interface_name`, and add override variables across all 14 modules with PE resources.

**Architecture:** Each module gets three new optional variables (`private_endpoint_name`, `private_service_connection_name`, `private_endpoint_nic_name`) with `null` defaults. The PE resource uses `coalesce()` to fall back to the new `pep-` prefix. Storage account uses map-based overrides since it creates multiple PEs via `for_each`. Major version bump on all 14 modules.

**Tech Stack:** Terraform >= 1.9.0, AzureRM >= 4.0.0

**Spec:** `docs/specs/2026-03-30-module-upgrades-design.md` (Stream 1)

---

## Shared Pattern

Every module (except storage-account) gets the **exact same three variables** added to `variables.tf` before the `# === Tags ===` section:

```hcl
# === Optional: Private Endpoint Overrides ===
variable "private_endpoint_name" {
  type        = string
  default     = null
  description = "Override the private endpoint resource name. Defaults to pep-{name}."
}

variable "private_service_connection_name" {
  type        = string
  default     = null
  description = "Override the private service connection name. Defaults to psc-{name}."
}

variable "private_endpoint_nic_name" {
  type        = string
  default     = null
  description = "Override the PE network interface name. Defaults to pep-{name}-nic."
}
```

And every module's PE resource in `main.tf` gets these three changes:

1. `name = "pe-${var.name}"` becomes `name = coalesce(var.private_endpoint_name, "pep-${var.name}")`
2. Add `custom_network_interface_name = coalesce(var.private_endpoint_nic_name, "pep-${var.name}-nic")` after `subnet_id`
3. `name = "psc-${var.name}"` becomes `name = coalesce(var.private_service_connection_name, "psc-${var.name}")`

---

### Task 1: redis-cache (reference implementation)

**Files:**
- Modify: `modules/redis-cache/variables.tf` (add 3 variables before `# === Tags ===`)
- Modify: `modules/redis-cache/main.tf` (PE resource block, ~line 66-92)
- Modify: `modules/redis-cache/CHANGELOG.md`

- [ ] **Step 1: Add PE override variables to variables.tf**

In `modules/redis-cache/variables.tf`, insert the three new variables **before** the `# === Tags ===` section:

```hcl
# === Optional: Private Endpoint Overrides ===
variable "private_endpoint_name" {
  type        = string
  default     = null
  description = "Override the private endpoint resource name. Defaults to pep-{name}."
}

variable "private_service_connection_name" {
  type        = string
  default     = null
  description = "Override the private service connection name. Defaults to psc-{name}."
}

variable "private_endpoint_nic_name" {
  type        = string
  default     = null
  description = "Override the PE network interface name. Defaults to pep-{name}-nic."
}

# === Tags ===
```

- [ ] **Step 2: Update PE resource in main.tf**

In `modules/redis-cache/main.tf`, update the `azurerm_private_endpoint.this` resource. Change:

```hcl
  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
```

To:

```hcl
  name                          = coalesce(var.private_endpoint_name, "pep-${var.name}")
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_id
  custom_network_interface_name = coalesce(var.private_endpoint_nic_name, "pep-${var.name}-nic")
```

And change:

```hcl
    name                           = "psc-${var.name}"
```

To:

```hcl
    name                           = coalesce(var.private_service_connection_name, "psc-${var.name}")
```

- [ ] **Step 3: Update CHANGELOG.md**

Add a new version section at the top of `modules/redis-cache/CHANGELOG.md`, after `## [Unreleased]`:

```markdown
## [2.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default name changed from `pe-{name}` to `pep-{name}` (Azure CAF). Pass `private_endpoint_name = "pe-{name}"` to preserve old behavior.
- **BREAKING**: Private endpoint NIC now uses deterministic name `pep-{name}-nic` instead of Azure auto-generated name. Pass `private_endpoint_nic_name` to override.

### Added

- `private_endpoint_name` variable to override PE resource name
- `private_service_connection_name` variable to override PSC name
- `private_endpoint_nic_name` variable to override PE NIC name
```

- [ ] **Step 4: Validate**

```bash
cd modules/redis-cache && terraform fmt -check && terraform init -backend=false && terraform validate
```

Expected: All pass with no errors.

- [ ] **Step 5: Commit**

```bash
git add modules/redis-cache/
git commit -m "redis-cache v2.0.0: PE naming override with pep- default (CAF)"
```

---

### Task 2: key-vault, mssql-server, function-app

Apply the same PE naming pattern to three modules. Each follows the identical variable addition and PE resource edit.

**Files:**
- Modify: `modules/key-vault/variables.tf`, `modules/key-vault/main.tf`, `modules/key-vault/CHANGELOG.md`
- Modify: `modules/mssql-server/variables.tf`, `modules/mssql-server/main.tf`, `modules/mssql-server/CHANGELOG.md`
- Modify: `modules/function-app/variables.tf`, `modules/function-app/main.tf`, `modules/function-app/CHANGELOG.md`

**For each of these three modules, do steps 1-5:**

- [ ] **Step 1: key-vault — Add PE override variables to variables.tf**

Insert the three PE override variables before `# === Tags ===` (same code block as Task 1 Step 1).

- [ ] **Step 2: key-vault — Update PE resource in main.tf**

The PE resource is at ~line 38. Apply the same three edits:
- `name = "pe-${var.name}"` -> `name = coalesce(var.private_endpoint_name, "pep-${var.name}")`
- Add `custom_network_interface_name = coalesce(var.private_endpoint_nic_name, "pep-${var.name}-nic")` after `subnet_id`
- `name = "psc-${var.name}"` -> `name = coalesce(var.private_service_connection_name, "psc-${var.name}")`

- [ ] **Step 3: key-vault — Update CHANGELOG.md**

Same CHANGELOG pattern as Task 1 Step 3. Version: `## [2.0.0] - 2026-03-30`.

- [ ] **Step 4: key-vault — Validate**

```bash
cd modules/key-vault && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 5: key-vault — Commit**

```bash
git add modules/key-vault/
git commit -m "key-vault v2.0.0: PE naming override with pep- default (CAF)"
```

- [ ] **Step 6: mssql-server — Add PE override variables to variables.tf**

Insert the three PE override variables before `# === Tags ===`.

- [ ] **Step 7: mssql-server — Update PE resource in main.tf**

PE resource at ~line 38. Same three edits as above.

- [ ] **Step 8: mssql-server — Update CHANGELOG.md**

Same pattern. Version: `## [2.0.0] - 2026-03-30`.

- [ ] **Step 9: mssql-server — Validate**

```bash
cd modules/mssql-server && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 10: mssql-server — Commit**

```bash
git add modules/mssql-server/
git commit -m "mssql-server v2.0.0: PE naming override with pep- default (CAF)"
```

- [ ] **Step 11: function-app — Add PE override variables to variables.tf**

Insert the three PE override variables before `# === Tags ===`.

- [ ] **Step 12: function-app — Update PE resource in main.tf**

PE resource at ~line 66. Same three edits.

- [ ] **Step 13: function-app — Update CHANGELOG.md**

Same pattern. Version: `## [2.0.0] - 2026-03-30`.

- [ ] **Step 14: function-app — Validate**

```bash
cd modules/function-app && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 15: function-app — Commit**

```bash
git add modules/function-app/
git commit -m "function-app v2.0.0: PE naming override with pep- default (CAF)"
```

---

### Task 3: container-registry, cosmosdb, event-hub

**Files:**
- Modify: `modules/container-registry/{variables.tf,main.tf,CHANGELOG.md}`
- Modify: `modules/cosmosdb/{variables.tf,main.tf,CHANGELOG.md}`
- Modify: `modules/event-hub/{variables.tf,main.tf,CHANGELOG.md}`

**For each module, repeat the same 5-step pattern (add variables, update PE resource, update CHANGELOG, validate, commit).**

- [ ] **Step 1-5: container-registry**

PE resource at ~line 44. Same three edits. CHANGELOG version: `## [2.0.0] - 2026-03-30`.

```bash
cd modules/container-registry && terraform fmt -check && terraform init -backend=false && terraform validate
git add modules/container-registry/
git commit -m "container-registry v2.0.0: PE naming override with pep- default (CAF)"
```

- [ ] **Step 6-10: cosmosdb**

PE resource at ~line 89. Same three edits. CHANGELOG version: `## [2.0.0] - 2026-03-30`.

```bash
cd modules/cosmosdb && terraform fmt -check && terraform init -backend=false && terraform validate
git add modules/cosmosdb/
git commit -m "cosmosdb v2.0.0: PE naming override with pep- default (CAF)"
```

- [ ] **Step 11-15: event-hub**

PE resource at ~line 79. Same three edits. CHANGELOG version: `## [2.0.0] - 2026-03-30`.

```bash
cd modules/event-hub && terraform fmt -check && terraform init -backend=false && terraform validate
git add modules/event-hub/
git commit -m "event-hub v2.0.0: PE naming override with pep- default (CAF)"
```

---

### Task 4: service-bus, linux-web-app, static-web-app

**Files:**
- Modify: `modules/service-bus/{variables.tf,main.tf,CHANGELOG.md}`
- Modify: `modules/linux-web-app/{variables.tf,main.tf,CHANGELOG.md}`
- Modify: `modules/static-web-app/{variables.tf,main.tf,CHANGELOG.md}`

- [ ] **Step 1-5: service-bus**

PE resource at ~line 75. Same three edits. CHANGELOG version: `## [2.0.0] - 2026-03-30`.

```bash
cd modules/service-bus && terraform fmt -check && terraform init -backend=false && terraform validate
git add modules/service-bus/
git commit -m "service-bus v2.0.0: PE naming override with pep- default (CAF)"
```

- [ ] **Step 6-10: linux-web-app**

PE resource at ~line 71. Same three edits. CHANGELOG version: `## [2.0.0] - 2026-03-30`.

```bash
cd modules/linux-web-app && terraform fmt -check && terraform init -backend=false && terraform validate
git add modules/linux-web-app/
git commit -m "linux-web-app v2.0.0: PE naming override with pep- default (CAF)"
```

- [ ] **Step 11-15: static-web-app**

PE resource at ~line 33. Same three edits. CHANGELOG version: `## [2.0.0] - 2026-03-30`.

```bash
cd modules/static-web-app && terraform fmt -check && terraform init -backend=false && terraform validate
git add modules/static-web-app/
git commit -m "static-web-app v2.0.0: PE naming override with pep- default (CAF)"
```

---

### Task 5: api-management, mysql-flexible-server, postgresql-flexible-server

**Files:**
- Modify: `modules/api-management/{variables.tf,main.tf,CHANGELOG.md}`
- Modify: `modules/mysql-flexible-server/{variables.tf,main.tf,CHANGELOG.md}`
- Modify: `modules/postgresql-flexible-server/{variables.tf,main.tf,CHANGELOG.md}`

- [ ] **Step 1-5: api-management**

PE resource at ~line 71. Same three edits. CHANGELOG version: `## [2.0.0] - 2026-03-30`.

```bash
cd modules/api-management && terraform fmt -check && terraform init -backend=false && terraform validate
git add modules/api-management/
git commit -m "api-management v2.0.0: PE naming override with pep- default (CAF)"
```

- [ ] **Step 6-10: mysql-flexible-server**

PE resource at ~line 67. Same three edits. CHANGELOG version: **`## [3.0.0] - 2026-03-30`** (currently at v2.0.0).

```bash
cd modules/mysql-flexible-server && terraform fmt -check && terraform init -backend=false && terraform validate
git add modules/mysql-flexible-server/
git commit -m "mysql-flexible-server v3.0.0: PE naming override with pep- default (CAF)"
```

- [ ] **Step 11-15: postgresql-flexible-server**

PE resource at ~line 72. Same three edits. CHANGELOG version: **`## [3.0.0] - 2026-03-30`** (currently at v2.0.0).

```bash
cd modules/postgresql-flexible-server && terraform fmt -check && terraform init -backend=false && terraform validate
git add modules/postgresql-flexible-server/
git commit -m "postgresql-flexible-server v3.0.0: PE naming override with pep- default (CAF)"
```

---

### Task 6: storage-account (map-based overrides)

**Files:**
- Modify: `modules/storage-account/variables.tf`
- Modify: `modules/storage-account/main.tf`
- Modify: `modules/storage-account/CHANGELOG.md`

- [ ] **Step 1: Add map-based PE override variables to variables.tf**

In `modules/storage-account/variables.tf`, insert before `# === Tags ===`:

```hcl
# === Optional: Private Endpoint Overrides ===
variable "private_endpoint_names" {
  type        = map(string)
  default     = {}
  description = "Override PE names per subresource key (blob, file, table, queue). Defaults to pep-{name}-{subresource}."
}

variable "private_service_connection_names" {
  type        = map(string)
  default     = {}
  description = "Override PSC names per subresource key. Defaults to psc-{name}-{subresource}."
}

variable "private_endpoint_nic_names" {
  type        = map(string)
  default     = {}
  description = "Override PE NIC names per subresource key. Defaults to pep-{name}-{subresource}-nic."
}
```

- [ ] **Step 2: Update PE resource in main.tf**

The PE resource uses `for_each`. Change:

```hcl
  name                = "pe-${var.name}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
```

To:

```hcl
  name                          = lookup(var.private_endpoint_names, each.key, "pep-${var.name}-${each.key}")
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_id
  custom_network_interface_name = lookup(var.private_endpoint_nic_names, each.key, "pep-${var.name}-${each.key}-nic")
```

And change:

```hcl
    name                           = "psc-${var.name}-${each.key}"
```

To:

```hcl
    name                           = lookup(var.private_service_connection_names, each.key, "psc-${var.name}-${each.key}")
```

- [ ] **Step 3: Update CHANGELOG.md**

```markdown
## [2.0.0] - 2026-03-30

### Changed

- **BREAKING**: Private endpoint default names changed from `pe-{name}-{sub}` to `pep-{name}-{sub}` (Azure CAF). Pass `private_endpoint_names` map to preserve old behavior.
- **BREAKING**: Private endpoint NICs now use deterministic names `pep-{name}-{sub}-nic` instead of Azure auto-generated names. Pass `private_endpoint_nic_names` map to override.

### Added

- `private_endpoint_names` map variable to override PE resource names per subresource
- `private_service_connection_names` map variable to override PSC names per subresource
- `private_endpoint_nic_names` map variable to override PE NIC names per subresource
```

- [ ] **Step 4: Validate**

```bash
cd modules/storage-account && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 5: Commit**

```bash
git add modules/storage-account/
git commit -m "storage-account v2.0.0: PE naming override with pep- default (CAF)"
```

---

### Task 7: Regenerate READMEs and final validation

- [ ] **Step 1: Regenerate docs for all 14 modules**

```bash
cd /mnt/c/Github/framework-terraform
./scripts/generate-docs.sh
```

If the script doesn't exist or fails, regenerate manually per module:

```bash
for mod in api-management container-registry cosmosdb event-hub function-app key-vault linux-web-app mssql-server mysql-flexible-server postgresql-flexible-server redis-cache service-bus static-web-app storage-account; do
  cd modules/$mod && terraform-docs markdown table --output-file README.md --output-mode inject . && cd ../..
done
```

- [ ] **Step 2: Verify all READMEs updated**

Check that the new variables appear in the README tables for all 14 modules.

- [ ] **Step 3: Commit README changes**

```bash
git add modules/*/README.md
git commit -m "Regenerate READMEs for PE naming override across 14 modules"
```
