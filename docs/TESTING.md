# Terraform Modules Testing Guide

**Purpose:** Live testing of terraform modules using Claude Code against an MPN Azure subscription.
**Scope:** Module isolation tests and multi-module integration tests.

---

## 1. Environment Setup

### 1.1 Subscription Details

| Property | Value |
|----------|-------|
| Subscription type | MPN (Microsoft Partner Network) |
| Monthly budget | 130 EUR |
| Region | westeurope |
| Region short code | weu |
| Project name | tftest |

### 1.2 Authentication

Authentication is handled manually before launching Claude Code:

```bash
az login --use-device-code
az account set --subscription "<subscription-id>"
```

Claude Code assumes an active Azure CLI session. It does not manage authentication.

**Important (WSL):** The AzureRM Terraform provider cannot auto-detect the subscription in WSL environments. You must pass the subscription ID as an environment variable on every terraform command:

```bash
ARM_SUBSCRIPTION_ID=ac0ea687-800c-467f-a67a-c070396bda88 terraform plan
ARM_SUBSCRIPTION_ID=ac0ea687-800c-467f-a67a-c070396bda88 terraform apply -auto-approve
ARM_SUBSCRIPTION_ID=ac0ea687-800c-467f-a67a-c070396bda88 terraform destroy -auto-approve
```

Alternatively, export it once per session: `export ARM_SUBSCRIPTION_ID=ac0ea687-800c-467f-a67a-c070396bda88`

### 1.3 State Management

All test deployments use **local state**. No remote backend configuration is needed for testing. Local state files are excluded via `.gitignore`.

### 1.4 Working Directory

Claude Code runs from inside the `framework-terraform` repo. Tests execute from each module's `examples/complete/` or `examples/basic/` directory (isolation tests) or from a dedicated `tests/` directory (integration tests).

---

## 2. Naming Convention

All test resources use `tftest` as the project name, making them instantly identifiable as disposable.

| Resource | Name |
|----------|------|
| Resource Group | `rg-tftest-<purpose>-weu-001` |
| Virtual Network | `vnet-tftest-weu-001` |
| Storage Account | `sttftestweu001` |
| Key Vault | `kv-tftest-weu-001` |
| Other resources | Follow CAF convention with `tftest` project name |

Purpose suffixes for resource groups:

| Purpose | Resource Group Name |
|---------|-------------------|
| Shared prerequisites (networking, DNS) | `rg-tftest-shared-weu-001` |
| Module isolation test | `rg-tftest-<module>-weu-001` |
| Integration test | `rg-tftest-integration-weu-001` |

---

## 3. Budget Guardrails

Monthly budget: 130 EUR. Remaining budget varies -- check before testing expensive modules.

### 3.1 Cost Tiers

| Tier | Est. Daily Cost | Modules |
|------|----------------|---------|
| Free / negligible | ~0 EUR | virtual-network, network-security-group, private-dns-zone, user-assigned-identity |
| Low (<1 EUR/day) | <1 EUR | storage-account, key-vault, log-analytics-workspace (free tier), container-registry (Standard) |
| Medium (1-5 EUR/day) | 2-5 EUR | app-service-plan + linux-web-app, function-app, mssql-server + mssql-database, diagnostic-settings |
| High (5-20+ EUR/day) | 10-20 EUR | aks, redis-cache, front-door |

### 3.2 Budget Rules

1. **Always destroy after testing.** No resources should survive longer than a single test session.
2. **Check remaining budget** before testing Medium or High tier modules. Use the Azure portal **Cost Management + Billing** blade — the `az consumption usage list` CLI command has a 24-48 hour delay and is unreliable for same-day cost checking.
3. **High tier modules** (AKS, Redis, Front Door): only test when at least 30 EUR of budget remains. Deploy, verify, destroy in the same session.
4. **Use the cheapest viable SKUs** for testing. The goal is to validate module logic, not performance. Examples: Basic App Service Plan, Basic SQL DTU, Standard_B2s nodes for AKS.
5. **If a destroy fails**, fix and retry immediately. Orphaned resources are budget llamas eating your credits.

---

## 4. Test Matrix

### 4.1 Module Isolation Tests

Each module is tested independently with its prerequisites deployed inline. The "Prerequisites" column lists what Claude Code must create before the module under test can be deployed.

#### P0 - Foundational

| Module | Prerequisites | Test SKU / Config | Cost Tier |
|--------|--------------|-------------------|-----------|
| storage-account | Resource group | Standard_LRS | Low |
| key-vault | Resource group | Standard | Low |
| virtual-network | Resource group | N/A | Free |

#### P1 - Core Infrastructure

| Module | Prerequisites | Test SKU / Config | Cost Tier |
|--------|--------------|-------------------|-----------|
| network-security-group | Resource group | N/A | Free |
| log-analytics-workspace | Resource group | PerGB2018 (free tier: 5GB/day) | Low |
| diagnostic-settings | Resource group, log-analytics-workspace, target resource (e.g., key-vault) | N/A | Low |
| user-assigned-identity | Resource group | N/A | Free |
| private-dns-zone | Resource group, virtual-network | N/A | Free |

#### P2 - Application Layer

| Module | Prerequisites | Test SKU / Config | Cost Tier |
|--------|--------------|-------------------|-----------|
| app-service-plan | Resource group | B1 (Basic) Linux | Low |
| linux-web-app | Resource group, app-service-plan | On Basic plan, disable PE for isolation test | Medium |
| function-app | Resource group, app-service-plan, storage-account | Consumption or Basic plan | Medium |
| container-app-environment | Resource group, virtual-network (with subnet), log-analytics-workspace | Consumption | Medium |
| container-app | Resource group, container-app-environment | Consumption (single replica) | Medium |
| container-registry | Resource group | Standard | Low |
| mssql-server | Resource group | N/A (server is free, DB costs). **Region: use northeurope** (westeurope blocked for MPN) | Low |
| mssql-database | Resource group, mssql-server | Basic DTU (5 DTU). **Region: use northeurope** (westeurope blocked for MPN) | Medium |
| aks | Resource group, log-analytics-workspace | Standard_B2s, 1 node, no autoscaling, `zones = []` (MPN zone restrictions). See AKS notes in section 8 | High |

#### P3 - Situational

| Module | Prerequisites | Test SKU / Config | Cost Tier |
|--------|--------------|-------------------|-----------|
| virtual-machine | Resource group, virtual-network (with subnet) | Standard_B1s | Medium |
| service-bus | Resource group | Basic | Low |
| redis-cache | Resource group | Basic C0 | High |
| front-door | Resource group | Standard | High |

### 4.2 Integration Tests

Integration tests deploy multiple modules together to validate cross-module wiring. These are run after isolation tests pass.

#### Integration Test 1: Web App Stack

**Estimated cost:** 3-5 EUR per session (deploy + verify + destroy).

| Step | Module | Notes |
|------|--------|-------|
| 1 | virtual-network | Shared VNet with subnets for PE and VNet integration |
| 2 | private-dns-zone | `privatelink.azurewebsites.net` linked to VNet |
| 3 | log-analytics-workspace | For diagnostics |
| 4 | app-service-plan | B1 Linux |
| 5 | linux-web-app | With private endpoint, VNet integration |
| 6 | diagnostic-settings | Attached to web app |

**Validates:** Private endpoint wiring, DNS zone group creation, VNet integration, diagnostic settings attachment.

#### Integration Test 2: Database Stack

**Estimated cost:** 3-5 EUR per session.

| Step | Module | Notes |
|------|--------|-------|
| 1 | virtual-network | Shared VNet with PE subnet |
| 2 | private-dns-zone | `privatelink.database.windows.net` linked to VNet |
| 3 | key-vault | For SQL admin password |
| 4 | mssql-server | With private endpoint, AAD-only auth |
| 5 | mssql-database | Basic DTU tier |

**Validates:** Key Vault secret integration, private endpoint for SQL, AAD authentication.

#### Integration Test 3: Container Stack

**Estimated cost:** 5-8 EUR per session.

| Step | Module | Notes |
|------|--------|-------|
| 1 | virtual-network | With subnet for Container App Environment |
| 2 | log-analytics-workspace | Required by Container App Environment |
| 3 | container-registry | Standard SKU (no PE for this test) |
| 4 | container-app-environment | With VNet integration |
| 5 | container-app | Simple container from ACR |

**Validates:** Container App Environment VNet integration, ACR pull, container deployment.

#### Integration Test 4: AKS Stack

**Estimated cost:** 15-25 EUR per session. Only run with sufficient budget.

| Step | Module | Notes |
|------|--------|-------|
| 1 | virtual-network | With dedicated AKS subnet (minimum /24) |
| 2 | log-analytics-workspace | For Container Insights |
| 3 | container-registry | Standard SKU |
| 4 | aks | Private cluster, CNI Overlay, single node (Standard_B2s) |

**Validates:** Private AKS cluster, CNI Overlay networking, Container Insights, ACR integration.

---

## 5. Claude Code Workflow

### 5.1 Isolation Test Workflow

For each module under test, Claude Code executes:

```
1. Navigate to the module's examples/complete/ directory
2. Create prerequisite resources inline (or use a shared prerequisites config)
3. terraform init
4. terraform plan
5. Review plan output for correctness
6. terraform apply -auto-approve
7. Verify resources exist and are configured correctly (az CLI spot checks)
8. terraform destroy -auto-approve
9. Verify resource group is empty / deleted
10. Report: pass/fail with any issues found
```

### 5.2 Integration Test Workflow

Integration tests use a dedicated directory structure:

```
tests/
  integration/
    web-app-stack/
      main.tf
      variables.tf
      outputs.tf
      terraform.tfvars
    database-stack/
      ...
    container-stack/
      ...
    aks-stack/
      ...
```

Each integration test sources modules locally (relative paths):

```hcl
module "vnet" {
  source = "../../../virtual-network"
  # ...
}

module "web_app" {
  source = "../../../linux-web-app"
  # ...
}
```

Workflow:

```
1. Navigate to the integration test directory
2. terraform init
3. terraform plan
4. Review plan output
5. terraform apply -auto-approve
6. Verify cross-module wiring (private endpoints resolve, DNS works, connectivity)
7. terraform destroy -auto-approve
8. Verify all resources cleaned up
9. Report: pass/fail with details
```

### 5.3 Verification Checks

After `terraform apply`, Claude Code should verify:

| Check | Command / Method |
|-------|-----------------|
| Resource exists | `az resource show --ids <resource-id>` |
| Private endpoint connected | `az network private-endpoint show` -- check `privateLinkServiceConnections[0].privateLinkServiceConnectionState.status` is "Approved" |
| DNS resolution (private) | `az network private-dns record-set list` in the relevant zone |
| Tags applied | Check `tags` in resource JSON output |
| Secure defaults active | Verify TLS version, public access disabled, HTTPS only, etc. |

### 5.4 Failure Handling

If `terraform destroy` fails:

1. Retry: `terraform destroy -auto-approve`
2. If still failing, identify the stuck resource and delete manually: `az resource delete --ids <resource-id>`
3. Delete the resource group as a last resort: `az group delete --name <rg-name> --yes --no-wait`
4. Log the failure -- it may indicate a module bug (missing dependency ordering, lifecycle issues)

**Known destroy issue — AKS with Container Insights:** When an AKS cluster with OMS agent (Container Insights) is destroyed, Azure leaves an orphaned `ContainerInsights(<workspace-name>)` solution resource in the resource group. This causes `terraform destroy` to fail on the RG deletion with `prevent_deletion_if_contains_resources`. This is a guaranteed failure, not an edge case. Use `az group delete --name <rg-name> --yes` to clean up.

---

## 6. Test Execution Order

Recommended order, respecting dependencies and cost:

### Phase 1: Free/Low Cost (P0 + P1 foundations)

1. virtual-network
2. network-security-group
3. private-dns-zone (depends on virtual-network)
4. user-assigned-identity
5. storage-account
6. key-vault
7. log-analytics-workspace
8. diagnostic-settings (depends on log-analytics-workspace + a target resource)

### Phase 2: Medium Cost (P2 application layer)

9. app-service-plan
10. linux-web-app (depends on app-service-plan)
11. function-app (depends on app-service-plan + storage-account)
12. container-registry
13. container-app-environment (depends on virtual-network + log-analytics-workspace)
14. container-app (depends on container-app-environment)
15. mssql-server (depends on key-vault)
16. mssql-database (depends on mssql-server)

### Phase 3: High Cost (AKS and situational)

17. aks (depends on virtual-network + log-analytics-workspace) -- budget permitting

### Phase 4: Integration Tests

18. Web App Stack
19. Database Stack
20. Container Stack
21. AKS Stack -- budget permitting

---

## 7. Cleanup Checklist

Run after every test session:

```bash
# List all tftest resource groups
az group list --query "[?starts_with(name, 'rg-tftest')].{Name:name, State:properties.provisioningState}" --output table

# Also check for AKS node resource groups (MC_* prefix)
az group list --query "[?starts_with(name, 'MC_')].{Name:name, State:properties.provisioningState}" --output table

# Delete any survivors
az group delete --name <rg-name> --yes --no-wait

# Check for orphaned resources outside RGs (rare but possible)
az resource list --query "[?contains(name, 'tftest')]" --output table

# Nuclear option: delete all tftest resource groups
az group list --query "[?starts_with(name, 'rg-tftest')].name" --output tsv | xargs -I {} az group delete --name {} --yes --no-wait
```

---

## 8. Notes

- **Private endpoints in isolation tests:** For modules that default to `enable_private_endpoint = true`, isolation tests need a VNet and subnet as prerequisites. For cheaper/faster testing, you can set `enable_private_endpoint = false` and `enable_public_access = true` to skip the networking prerequisites. Test private endpoint wiring separately or in integration tests.
- **Key Vault soft delete:** Key Vault has a soft-delete retention period (default 90 days). Reusing the same name after destroy will fail. Either purge explicitly (`az keyvault purge --name <name>`) or use a unique suffix per test run.
- **SQL Server soft delete:** Similar to Key Vault. Server names are globally unique and may be retained briefly after deletion.
- **AKS cluster creation time:** AKS clusters take ~10 minutes to provision. Destroy takes ~5 minutes for the cluster itself, but the resource group cleanup (which must delete the orphaned ContainerInsights resource and the MC_ node resource group) takes an additional ~10 minutes. Total destroy cycle: ~15 minutes.
- **AKS availability zones on MPN:** MPN subscriptions may only support a subset of availability zones for certain VM SKUs in westeurope. The module default `zones = ["1", "2", "3"]` may fail. For testing, override with `zones = []` (no zone pinning). This is a subscription limitation, not a module bug.
- **AKS Container Insights cleanup:** See section 5.4 for the known destroy failure. Always use `az group delete` after AKS destroy to clean up the orphaned ContainerInsights solution resource.
- **Container App Environment:** Can take 4-6 minutes to provision when VNet-integrated.
- **SQL Server region restriction:** MPN subscriptions cannot provision SQL Server in westeurope (`ProvisioningDisabled`). Use northeurope for mssql-server and mssql-database tests. The modules are region-agnostic; this is purely a subscription limitation.
- **Log Analytics free tier:** The free tier allows 5 GB/day ingestion. Sufficient for testing.
