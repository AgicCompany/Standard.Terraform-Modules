# Module Test Results

**Date:** 2026-02-09
**Terraform:** 1.13.0
**AzureRM Provider:** 4.59.0
**Subscription:** MPN (AGIC – MPN Mihai)
**Region:** westeurope (unless noted)

---

## Summary

| Phase | Modules Tested | Passed | Failed | Bugs Fixed |
|-------|---------------|--------|--------|------------|
| Phase 1 (Free/Low) | 8 | 8 | 0 | 2 |
| Phase 2 (Medium) | 8 | 8 | 0 | 4 |
| Phase 3 (High) | 1 | 1 | 0 | 1 |
| Phase 4 (Integration) | 4 stacks | 4 | 0 | 0 |
| **Total** | **17 + 4 stacks** | **All pass** | **0** | **7** |

---

## Phase 1: Free/Low Cost Modules

### 1. virtual-network

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 13 |
| Result | **PASS** (after fix) |

**Bugs found:**

1. **`for_each` unknown-value error (HIGH):** The `azurerm_subnet_network_security_group_association` and `azurerm_subnet_route_table_association` resources used `for_each` with a filter condition (`if v.network_security_group_id != null`) that depended on resource attributes unknown at plan time. Terraform 1.13.0 cannot determine the key set when the filter condition references values from resources being created in the same configuration.

   **Fix:** Removed `network_security_group_id` and `route_table_id` from the `subnets` object variable. Added separate `subnet_nsg_associations` and `subnet_route_table_associations` variables of type `map(string)`, where keys are always known at plan time.

   **Files changed:** `main.tf`, `variables.tf`, `README.md`, `examples/complete/main.tf`

2. **Invalid CIDR notation (MEDIUM):** The complete example used `10.0.5.0/23` for the container-apps subnet. A `/23` block must be aligned on a 2-address boundary; the correct notation is `10.0.4.0/23` or `10.0.6.0/23`. Azure rejected the request with `InvalidCIDRNotation`.

   **Fix:** Changed to `10.0.6.0/23` (avoiding overlap with `snet-appservice` at `10.0.4.0/24`).

   **Files changed:** `examples/complete/main.tf`

### 2. network-security-group

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 5 (1 RG, 1 NSG, 3 rules) |
| Result | **PASS** |

No issues found.

### 3. private-dns-zone

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 9 (1 RG, 2 VNets, 2 DNS zones, 4 VNet links) |
| Result | **PASS** |

No issues found.

### 4. user-assigned-identity

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 4 (1 RG, 1 identity, 2 role assignments) |
| Result | **PASS** |

No issues found.

### 5. storage-account

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 17 (1 RG, 1 VNet, 1 subnet, 2 storage accounts, 4 private endpoints, etc.) |
| Result | **PASS** |

No issues found.

### 6. key-vault

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 10 (1 RG, 1 VNet, 1 subnet, 1 DNS zone, 1 VNet link, 2 Key Vaults, 1 PE, 2 role assignments) |
| Result | **PASS** |

No issues found.

### 7. log-analytics-workspace

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 2 (1 RG, 1 workspace) |
| Result | **PASS** |

No issues found.

### 8. diagnostic-settings

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 6 (1 RG, 1 LAW, 2 Key Vaults, 2 diagnostic settings) |
| Result | **PASS** |

**Warning:** The `metric` block is deprecated in favor of `enabled_metric` and will be removed in AzureRM v5.0. Not blocking; will need updating when upgrading to v5.0.

---

## Phase 2: Medium Cost Modules

### 9. app-service-plan

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 2 (1 RG, 1 App Service Plan) |
| Result | **PASS** (after fix) |

**Bug found:**

1. **Incomplete example (MEDIUM):** The complete example was missing the `terraform {}` block with version constraints, an inline `azurerm_resource_group` resource (referenced a non-existent RG by name), and output blocks.

   **Fix:** Added `terraform {}` block, inline resource group creation, and outputs.

   **Files changed:** `examples/complete/main.tf`

### 10. linux-web-app

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 10 (1 RG, 1 VNet, 2 subnets, 1 DNS zone, 1 VNet link, 1 ASP, 1 web app, 1 PE) |
| Result | **PASS** (after fix) |

**Bug found:**

1. **Missing `health_check_eviction_time_in_min` (HIGH):** In AzureRM 4.x, setting `health_check_path` requires `health_check_eviction_time_in_min` to also be specified. The module set `health_check_path` but omitted the eviction time, causing a plan-time error.

   **Fix:** Added `health_check_eviction_time_in_min` variable (default: 2 minutes) and wired it into the `site_config` block, conditionally set only when `health_check_path` is non-null.

   **Files changed:** `main.tf`, `variables.tf`

### 11. function-app

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 12 (1 RG, 1 VNet, 2 subnets, 1 DNS zone, 1 VNet link, 1 storage, 1 ASP, 1 LAW, 1 App Insights, 1 function app, 1 PE) |
| Result | **PASS** (after fix) |

**Bug found:**

1. **application_stack runtime conflict (HIGH):** The `use_custom_runtime` field defaulted to `false` and `use_dotnet_isolated_runtime` defaulted to `true`. AzureRM 4.x treats these non-null boolean values as "specified", causing a conflict error when combined with `dotnet_version` — the provider requires exactly one runtime option to be set.

   **Fix:** Changed both `use_custom_runtime` and `use_dotnet_isolated_runtime` defaults from explicit values to `null` (`optional(bool)` without default). Null values are ignored by Terraform and don't trigger the provider's mutual exclusivity check.

   **Files changed:** `variables.tf`

### 12. container-registry

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 7 (1 RG, 1 VNet, 1 subnet, 1 DNS zone, 1 VNet link, 1 ACR, 1 PE) |
| Result | **PASS** |

No issues found.

### 13. container-app-environment

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 5 (1 RG, 1 VNet, 1 subnet, 1 LAW, 1 CAE) |
| Result | **PASS** |

No issues found. Note: Container App Environment takes ~4-6 minutes to provision when VNet-integrated.

### 14. container-app

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Resources created | 6 (1 RG, 1 VNet, 1 subnet, 1 LAW, 1 CAE, 1 container app) |
| Result | **PASS** |

No issues found.

### 15. mssql-server

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Region | **northeurope** (westeurope blocked for MPN) |
| Resources created | 7 (1 RG, 1 VNet, 1 subnet, 1 DNS zone, 1 VNet link, 1 SQL server, 1 PE) |
| Result | **PASS** |

**Note:** SQL Server provisioning is blocked in westeurope for MPN subscriptions (`ProvisioningDisabled`). Test was run in northeurope. The module itself is region-agnostic; this is a subscription limitation.

### 16. mssql-database

| Property | Value |
|----------|-------|
| Example | `examples/complete` |
| Region | **northeurope** (westeurope blocked for MPN) |
| Resources created | 3 (1 RG, 1 SQL server, 1 database) |
| Result | **PASS** (after fix) |

**Bugs found:**

1. **Incomplete example (MEDIUM):** Same issue as app-service-plan — missing `terraform {}` block, inline `azurerm_resource_group`, and output blocks. Additionally, the `azuread_administrator.object_id` used a placeholder `"00000000-0000-0000-0000-000000000000"` which Azure rejects.

   **Fix:** Added `terraform {}` block, inline resource group, `data.azurerm_client_config.current` for the AAD object_id, and outputs.

   **Files changed:** `examples/complete/main.tf`

**Note:** Zone redundancy (`enable_zone_redundancy = true`) and Premium SKU (`P1`) are not available for MPN subscriptions. Test used `S0` SKU with zone redundancy disabled. The complete example retains production-grade values for documentation purposes.

---

## Phase 3: High Cost Modules

### 17. aks

| Property | Value |
|----------|-------|
| Example | `examples/basic` (with cost-optimized overrides) |
| Resources created | 3 (1 RG, 1 LAW, 1 AKS cluster) |
| Provision time | ~10 minutes |
| Destroy time | ~5 minutes (AKS) + ~10 minutes (RG cleanup) |
| Result | **PASS** (after fix) |

**Test configuration:** Standard_B2s, 1 node, no autoscaling, no availability zones, Free tier SKU. Used basic example with node pool overrides to minimize cost.

**Bugs found:**

1. **Incomplete examples (MEDIUM):** Both `examples/basic/main.tf` and `examples/complete/main.tf` were missing the `terraform {}` block with version constraints, inline `azurerm_resource_group` resources (referenced non-existent RGs by name string), and output blocks. The complete example also used a placeholder `admin_group_object_ids = ["00000000-0000-0000-0000-000000000000"]` and a stale `kubernetes_version = "1.29"` (current default is 1.33).

   **Fix:** Added `terraform {}` blocks, inline resource groups, outputs. Complete example: replaced placeholder with `data.azurerm_client_config.current.object_id`, removed hardcoded `kubernetes_version` (let Azure select latest).

   **Files changed:** `examples/basic/main.tf`, `examples/complete/main.tf`

**Subscription limitations encountered:**

1. **AvailabilityZoneNotSupported:** MPN subscription only supports zone `3` for Standard_D2s_v3 in westeurope. The module default `zones = ["1", "2", "3"]` fails. This is a subscription limitation, not a module bug. Tested with `zones = []`.

2. **ContainerInsights orphaned resource:** When AKS with OMS agent is destroyed, Azure leaves a `ContainerInsights` solution resource in the RG that Terraform doesn't manage. This causes `terraform destroy` to fail on the RG deletion with `prevent_deletion_if_contains_resources`. Cleanup required `az group delete`.

**Verified configuration:**

| Setting | Expected | Verified |
|---------|----------|----------|
| Private cluster | true | true |
| Local accounts disabled | true | true |
| Azure RBAC | true | true |
| OIDC issuer | true | true |
| Kubernetes version | latest (1.33) | 1.33 |
| Network plugin | azure (overlay) | azure (overlay) |
| Network policy | azure | azure |
| Container Insights | enabled | enabled |
| Identity | SystemAssigned | SystemAssigned |
| Node pool OS | AzureLinux | AzureLinux |
| Tags | applied | applied |

---

## Phase 4: Integration Tests

Integration tests validate cross-module wiring by deploying multi-module stacks that mirror real-world architectures.

### Integration Test 1: Web App Stack

| Property | Value |
|----------|-------|
| Modules | virtual-network, private-dns-zone, log-analytics-workspace, app-service-plan, linux-web-app, diagnostic-settings |
| Resources created | 11 |
| Region | westeurope |
| Result | **PASS** |

**Cross-module wiring verified:**

| Check | Result |
|-------|--------|
| PE auto-approved | Yes |
| DNS A record (`privatelink.azurewebsites.net`) | `10.0.1.4` |
| VNet integration connected | Yes (`snet-integration`) |
| HTTPS only / public access disabled | Yes |
| Diagnostics flowing to LAW | Yes |
| Clean destroy | Yes (11/11) |

### Integration Test 2: Database Stack

| Property | Value |
|----------|-------|
| Modules | virtual-network, private-dns-zone, mssql-server, mssql-database |
| Resources created | 8 |
| Region | northeurope (SQL blocked in westeurope for MPN) |
| Result | **PASS** |

**Cross-module wiring verified:**

| Check | Result |
|-------|--------|
| PE auto-approved | Yes |
| DNS A record (`privatelink.database.windows.net`) | `10.0.1.4` |
| Public access disabled | Yes |
| TLS 1.2 enforced | Yes |
| AAD-only auth | Yes |
| Database SKU (S0) | Standard |
| Clean destroy | Yes (8/8) |

### Integration Test 3: Container Stack

| Property | Value |
|----------|-------|
| Modules | virtual-network, log-analytics-workspace, private-dns-zone, container-registry, container-app-environment, container-app |
| Resources created | 11 |
| Region | westeurope |
| Result | **PASS** (after test config fix) |

**Test config fix:** The CAE infrastructure subnet requires delegation to `Microsoft.App/environments`. This is an Azure requirement, not a module bug — the consumer must configure the subnet delegation.

**Cross-module wiring verified:**

| Check | Result |
|-------|--------|
| ACR PE auto-approved | Yes |
| ACR DNS records (`privatelink.azurecr.io`) | `10.0.1.5` / `10.0.1.4` (data) |
| CAE internal LB | Yes |
| CAE static IP in VNet | `10.0.2.190` (in `snet-cae`) |
| Container App running | Yes (quickstart image) |
| Ingress internal only | Yes |
| Clean destroy | Yes (11/11, ~18 min for CAE) |

### Integration Test 4: AKS Stack

| Property | Value |
|----------|-------|
| Modules | virtual-network, log-analytics-workspace, private-dns-zone, container-registry, aks |
| Resources created | 9 |
| Region | westeurope |
| Provision time | ~10 minutes (AKS) |
| Destroy time | ~5 min (AKS) + ~10 min (RG cleanup via `az group delete`) |
| Result | **PASS** |

**Cross-module wiring verified:**

| Check | Result |
|-------|--------|
| ACR PE auto-approved | Yes |
| ACR DNS records (`privatelink.azurecr.io`) | `10.0.1.5` / `10.0.1.4` (data) |
| AKS private cluster | Yes |
| AKS K8s version | 1.33 |
| Local accounts disabled | Yes |
| Azure RBAC | Yes |
| Container Insights → LAW | Yes |
| ContainerInsights orphan on destroy | Yes (expected, manual `az group delete` needed) |

---

## Subscription Limitations

| Limitation | Impact | Workaround |
|-----------|--------|------------|
| SQL Server blocked in westeurope | mssql-server, mssql-database examples fail | Test in northeurope |
| Zone redundant SQL not available | mssql-database complete example fails with Premium SKU | Test with Standard SKU (S0) |
| AKS zones limited in westeurope | Default `zones = ["1","2","3"]` fails for some VM SKUs | Test with `zones = []` |
| ContainerInsights orphan on destroy | RG deletion fails after AKS destroy with OMS agent | Use `az group delete` for cleanup |

---

## Commits

| Commit | Description |
|--------|-------------|
| `d356f98` | Fix virtual-network for_each unknown-value error and invalid CIDR |
| `dbad5b0` | Fix module bugs found during live testing (linux-web-app, function-app, app-service-plan, mssql-database) |
| `b99114a` | Fix AKS examples and update test results with Phase 3 |
