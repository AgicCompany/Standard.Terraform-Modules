# Function App Flex v1.0.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a new `function-app-flex` module for Azure Function Apps on Flex Consumption (FC1) hosting plans, using `azurerm_function_app_flex_consumption` with private endpoint support and `pep-` naming from day one.

**Architecture:** Standalone module, separate from the existing `function-app` module (different Terraform resource type, different schema). Follows standard module file structure. PE defaults to enabled with CAF-compliant naming. App settings managed by lifecycle ignore_changes (infra shell pattern).

**Tech Stack:** Terraform >= 1.9.0, AzureRM >= 4.0.0

**Spec:** `docs/specs/2026-03-30-module-upgrades-design.md` (Stream 3)

---

## File Map

All files are new, under `modules/function-app-flex/`:

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider version constraints |
| `variables.tf` | All input variables, grouped per module interface contract |
| `main.tf` | Function App resource + Private Endpoint |
| `outputs.tf` | id, name, default_hostname, identity, private_endpoint_id |
| `CHANGELOG.md` | Initial release |
| `README.md` | Auto-generated via terraform-docs |
| `examples/basic/main.tf` | Minimal FC1 function app, PE disabled |
| `examples/basic/outputs.tf` | Basic example outputs |
| `examples/complete/main.tf` | Full features: identity, VNet, PE, always-ready |
| `examples/complete/outputs.tf` | Complete example outputs |

---

### Task 1: Create module skeleton (versions.tf + variables.tf)

**Files:**
- Create: `modules/function-app-flex/versions.tf`
- Create: `modules/function-app-flex/variables.tf`

- [ ] **Step 1: Create versions.tf**

```bash
mkdir -p modules/function-app-flex
```

Write `modules/function-app-flex/versions.tf`:

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

- [ ] **Step 2: Create variables.tf**

Write `modules/function-app-flex/variables.tf`:

```hcl
# === Required ===
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "name" {
  type        = string
  description = "Name of the Function App (full CAF-compliant name, provided by consumer)."
}

# === Required: Resource-Specific ===
variable "service_plan_id" {
  type        = string
  description = "ID of the FC1 (sku_name = FC1) App Service Plan."
}

variable "runtime_name" {
  type        = string
  description = "Runtime stack: dotnet-isolated, python, node, java, powershell, or custom."

  validation {
    condition     = contains(["dotnet-isolated", "python", "node", "java", "powershell", "custom"], var.runtime_name)
    error_message = "runtime_name must be one of: dotnet-isolated, python, node, java, powershell, custom."
  }
}

variable "runtime_version" {
  type        = string
  description = "Runtime version (e.g. '8.0' for dotnet-isolated, '3.11' for python)."
}

variable "storage_container_endpoint" {
  type        = string
  description = "URL of the blob container for deployment package storage."
}

# === Optional: Configuration ===
variable "instance_memory_in_mb" {
  type        = number
  default     = 2048
  description = "Memory per instance in MB."

  validation {
    condition     = contains([512, 2048, 4096], var.instance_memory_in_mb)
    error_message = "Allowed values: 512, 2048, 4096."
  }
}

variable "maximum_instance_count" {
  type        = number
  default     = 10
  description = "Maximum number of instances for scaling."
}

variable "always_ready_instances" {
  type = map(object({
    instance_count = number
  }))
  default     = {}
  description = "Map of always-ready instance configurations keyed by function name."
}

variable "storage_container_type" {
  type        = string
  default     = "blobContainer"
  description = "Storage container type for FC1 deployment package."
}

variable "storage_authentication_type" {
  type        = string
  default     = "StorageAccountConnectionString"
  description = "Storage auth type: StorageAccountConnectionString, SystemAssignedIdentity, or UserAssignedIdentity."

  validation {
    condition     = contains(["StorageAccountConnectionString", "SystemAssignedIdentity", "UserAssignedIdentity"], var.storage_authentication_type)
    error_message = "Must be StorageAccountConnectionString, SystemAssignedIdentity, or UserAssignedIdentity."
  }
}

variable "storage_user_assigned_identity_id" {
  type        = string
  default     = null
  description = "Resource ID of the user-assigned identity for storage auth. Required when storage_authentication_type = UserAssignedIdentity."
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = "Application settings. Ignored on subsequent applies (managed by dev teams via CI/CD)."
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for VNet integration (outbound traffic)."
}

# === Optional: Identity ===
variable "identity_type" {
  type        = string
  default     = "None"
  description = "Managed identity type: None, SystemAssigned, or UserAssigned."

  validation {
    condition     = contains(["None", "SystemAssigned", "UserAssigned"], var.identity_type)
    error_message = "Must be None, SystemAssigned, or UserAssigned."
  }
}

variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "List of user-assigned identity resource IDs. Required when identity_type = UserAssigned."
}

# === Optional: Security ===
variable "https_only" {
  type        = bool
  default     = true
  description = "Require HTTPS connections."
}

variable "client_certificate_mode" {
  type        = string
  default     = "Required"
  description = "Client certificate mode: Required, Optional, or OptionalInteractiveUser."

  validation {
    condition     = contains(["Required", "Optional", "OptionalInteractiveUser"], var.client_certificate_mode)
    error_message = "Must be Required, Optional, or OptionalInteractiveUser."
  }
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  default     = false
  description = "Enable basic authentication for web deploy."
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for the Function App."
}

# === Optional: Private Endpoint ===
variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the private endpoint. Required when enable_private_endpoint = true."
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = []
  description = "Private DNS zone IDs for the PE DNS zone group."
}

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
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources."
}
```

- [ ] **Step 3: Commit**

```bash
git add modules/function-app-flex/
git commit -m "function-app-flex: add module skeleton with versions and variables"
```

---

### Task 2: Create main.tf (Function App resource + PE)

**Files:**
- Create: `modules/function-app-flex/main.tf`

- [ ] **Step 1: Create main.tf**

Write `modules/function-app-flex/main.tf`:

```hcl
resource "azurerm_function_app_flex_consumption" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  https_only                                     = var.https_only
  client_certificate_mode                        = var.client_certificate_mode
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled

  virtual_network_subnet_id = var.virtual_network_subnet_id
  maximum_instance_count    = var.maximum_instance_count

  runtime_name                      = var.runtime_name
  runtime_version                   = var.runtime_version
  storage_container_type            = var.storage_container_type
  storage_container_endpoint        = var.storage_container_endpoint
  storage_authentication_type       = var.storage_authentication_type
  storage_user_assigned_identity_id = var.storage_user_assigned_identity_id

  instance_memory_in_mb = var.instance_memory_in_mb

  dynamic "always_ready" {
    for_each = var.always_ready_instances
    content {
      name           = always_ready.key
      instance_count = always_ready.value.instance_count
    }
  }

  app_settings = var.app_settings

  site_config {}

  dynamic "identity" {
    for_each = var.identity_type != "None" ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config,
      storage_container_endpoint,
      storage_access_key,
    ]

    precondition {
      condition     = !var.enable_private_endpoint || var.private_endpoint_subnet_id != null
      error_message = "private_endpoint_subnet_id is required when enable_private_endpoint is true."
    }
  }
}

# Private endpoint
resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                          = coalesce(var.private_endpoint_name, "pep-${var.name}")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = coalesce(var.private_endpoint_nic_name, "pep-${var.name}-nic")

  private_service_connection {
    name                           = coalesce(var.private_service_connection_name, "psc-${var.name}")
    private_connection_resource_id = azurerm_function_app_flex_consumption.this.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
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
```

- [ ] **Step 2: Validate**

```bash
cd modules/function-app-flex && terraform fmt -check && terraform init -backend=false && terraform validate
```

Expected: Pass. If `azurerm_function_app_flex_consumption` is not recognized, check that the AzureRM provider version supports it (>= 4.14.0).

- [ ] **Step 3: Commit**

```bash
git add modules/function-app-flex/main.tf
git commit -m "function-app-flex: add main resource with PE support"
```

---

### Task 3: Create outputs.tf

**Files:**
- Create: `modules/function-app-flex/outputs.tf`

- [ ] **Step 1: Create outputs.tf**

Write `modules/function-app-flex/outputs.tf`:

```hcl
# === Standard Outputs ===
output "id" {
  value       = azurerm_function_app_flex_consumption.this.id
  description = "Function App resource ID."
}

output "name" {
  value       = azurerm_function_app_flex_consumption.this.name
  description = "Function App name."
}

# === Resource-Specific Outputs ===
output "default_hostname" {
  value       = azurerm_function_app_flex_consumption.this.default_hostname
  description = "Default hostname of the Function App."
}

output "identity" {
  value       = azurerm_function_app_flex_consumption.this.identity
  description = "Managed identity block (principal_id, tenant_id)."
}

output "private_endpoint_id" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
  description = "Private endpoint resource ID."
}

# === Public Outputs (Cross-Project Consumption) ===
output "public_function_app_flex_id" {
  value       = azurerm_function_app_flex_consumption.this.id
  description = "Function App resource ID (for cross-project consumption)."
}

output "public_function_app_flex_name" {
  value       = azurerm_function_app_flex_consumption.this.name
  description = "Function App name (for cross-project consumption)."
}
```

- [ ] **Step 2: Validate**

```bash
cd modules/function-app-flex && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 3: Commit**

```bash
git add modules/function-app-flex/outputs.tf
git commit -m "function-app-flex: add outputs"
```

---

### Task 4: Create basic example

**Files:**
- Create: `modules/function-app-flex/examples/basic/main.tf`
- Create: `modules/function-app-flex/examples/basic/outputs.tf`

- [ ] **Step 1: Create example directory**

```bash
mkdir -p modules/function-app-flex/examples/basic
```

- [ ] **Step 2: Create basic example main.tf**

Write `modules/function-app-flex/examples/basic/main.tf`:

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

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-funcflex-basic-example"
  location = "westeurope"
}

resource "azurerm_storage_account" "example" {
  name                     = "stfuncflexbasicex"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name               = "app-package"
  storage_account_id = azurerm_storage_account.example.id
}

resource "azurerm_service_plan" "example" {
  name                = "asp-funcflex-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "FC1"
}

module "function_app_flex" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "func-flex-basic-example"

  service_plan_id            = azurerm_service_plan.example.id
  runtime_name               = "python"
  runtime_version            = "3.11"
  storage_container_endpoint = "${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_container.example.name}"

  enable_private_endpoint = false

  tags = {
    environment = "example"
  }
}
```

- [ ] **Step 3: Create basic example outputs.tf**

Write `modules/function-app-flex/examples/basic/outputs.tf`:

```hcl
output "function_app_id" {
  value = module.function_app_flex.id
}

output "function_app_name" {
  value = module.function_app_flex.name
}

output "default_hostname" {
  value = module.function_app_flex.default_hostname
}
```

- [ ] **Step 4: Validate example**

```bash
cd modules/function-app-flex/examples/basic && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 5: Commit**

```bash
git add modules/function-app-flex/examples/basic/
git commit -m "function-app-flex: add basic example"
```

---

### Task 5: Create complete example

**Files:**
- Create: `modules/function-app-flex/examples/complete/main.tf`
- Create: `modules/function-app-flex/examples/complete/outputs.tf`

- [ ] **Step 1: Create example directory**

```bash
mkdir -p modules/function-app-flex/examples/complete
```

- [ ] **Step 2: Create complete example main.tf**

Write `modules/function-app-flex/examples/complete/main.tf`:

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

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-funcflex-complete-example"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-funcflex-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "outbound" {
  name                 = "snet-outbound"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.App/environments"
    }
  }
}

resource "azurerm_subnet" "pe" {
  name                 = "snet-pe"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "funcflex-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "id-funcflex-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_storage_account" "example" {
  name                     = "stfuncflexcmplex"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name               = "app-package"
  storage_account_id = azurerm_storage_account.example.id
}

resource "azurerm_service_plan" "example" {
  name                = "asp-funcflex-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "FC1"
}

module "function_app_flex" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "func-flex-complete-example"

  service_plan_id            = azurerm_service_plan.example.id
  runtime_name               = "dotnet-isolated"
  runtime_version            = "8.0"
  storage_container_endpoint = "${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_container.example.name}"

  instance_memory_in_mb  = 2048
  maximum_instance_count = 20

  storage_authentication_type       = "UserAssignedIdentity"
  storage_user_assigned_identity_id = azurerm_user_assigned_identity.example.id

  always_ready_instances = {
    "MyFunction" = {
      instance_count = 1
    }
  }

  identity_type = "UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.example.id]

  virtual_network_subnet_id = azurerm_subnet.outbound.id

  enable_private_endpoint    = true
  private_endpoint_subnet_id = azurerm_subnet.pe.id
  private_dns_zone_ids       = [azurerm_private_dns_zone.example.id]

  tags = {
    environment = "example"
  }
}
```

- [ ] **Step 3: Create complete example outputs.tf**

Write `modules/function-app-flex/examples/complete/outputs.tf`:

```hcl
output "function_app_id" {
  value = module.function_app_flex.id
}

output "function_app_name" {
  value = module.function_app_flex.name
}

output "default_hostname" {
  value = module.function_app_flex.default_hostname
}

output "identity" {
  value = module.function_app_flex.identity
}

output "private_endpoint_id" {
  value = module.function_app_flex.private_endpoint_id
}
```

- [ ] **Step 4: Validate example**

```bash
cd modules/function-app-flex/examples/complete && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 5: Commit**

```bash
git add modules/function-app-flex/examples/complete/
git commit -m "function-app-flex: add complete example with identity, VNet, PE"
```

---

### Task 6: CHANGELOG, README, final validation

**Files:**
- Create: `modules/function-app-flex/CHANGELOG.md`
- Create: `modules/function-app-flex/README.md`

- [ ] **Step 1: Create CHANGELOG.md**

Write `modules/function-app-flex/CHANGELOG.md`:

```markdown
# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.0.0] - 2026-03-30

### Added

- Initial release
- Flex Consumption (FC1) Function App via `azurerm_function_app_flex_consumption`
- Configurable runtime, memory, scaling, and always-ready instances
- Flexible storage authentication (connection string, system identity, user identity)
- Managed identity support (SystemAssigned, UserAssigned)
- VNet integration for outbound traffic
- Private endpoint with CAF-compliant naming (`pep-{name}`) and override variables
- Secure defaults (HTTPS-only, client certificates required, basic auth disabled)
- Lifecycle ignore_changes on app_settings and site_config (infra shell pattern)
```

- [ ] **Step 2: Generate README.md**

Create a minimal README with terraform-docs markers, then generate:

Write `modules/function-app-flex/README.md`:

```markdown
# Function App Flex Consumption Module

Terraform module for Azure Function App on Flex Consumption (FC1) hosting plan.

## Usage

See `examples/basic/` for minimum viable usage and `examples/complete/` for all features.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

Then generate:

```bash
cd modules/function-app-flex && terraform-docs markdown table --output-file README.md --output-mode inject .
```

- [ ] **Step 3: Final validation of all files**

```bash
cd modules/function-app-flex && terraform fmt -check && terraform init -backend=false && terraform validate
cd modules/function-app-flex/examples/basic && terraform init -backend=false && terraform validate
cd modules/function-app-flex/examples/complete && terraform init -backend=false && terraform validate
```

- [ ] **Step 4: Commit**

```bash
git add modules/function-app-flex/
git commit -m "function-app-flex v1.0.0: CHANGELOG, README, final validation"
```
