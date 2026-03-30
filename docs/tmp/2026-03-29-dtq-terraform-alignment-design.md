# DTQ Terraform Alignment — Design Spec

## Goal

Rewrite the DTQ Terraform codebase to manage all Azure resources across 5 resource groups using public modules from [AgicCompany/Standard.Terraform-Modules](https://github.com/AgicCompany/Standard.Terraform-Modules) where possible, with raw resources where module gaps exist. The config must:

1. Be importable against the existing dev environment without recreation
2. Be reusable for deploying a production environment via separate tfvars

## Deliverables

1. **Main Terraform config** — single root module managing all DTQ Azure resources
2. **Spec doc: Front Door module upgrade** — Private Link, custom domains, WAF, rule sets (upstream contribution, parallel implementation)
3. **Spec doc: Function App module FC1 support** — Flex Consumption hosting plan (upstream contribution, parallel implementation)

## Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Environment parameterization | Separate tfvars (`dev.tfvars`, `prod.tfvars`) | Simpler than separate root dirs; differences are in values not structure |
| State | Single state file per environment | ~50 resources is manageable; avoids cross-state data source complexity |
| Module source | Public git modules with version tags | `git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/<name>?ref=<name>/v<version>` |
| Gaps | Raw `azurerm_*` resources | For Bastion Developer SKU, Flex Consumption function apps, and full AFD stack |
| Monitoring | Out of scope | AKS add-ons configure Prometheus/Container Insights; LAW referenced as data source |
| Function app settings | Not managed | Infrastructure shell only; app config is dev team's responsibility |
| ACR | Feature-flagged | `create_acr = true` in dev; prod may share the same registry |

## File Structure

```
infrastructure/
├── versions.tf         # terraform block, required providers, backend "azurerm" {}
├── locals.tf           # naming, common tags, LAW data source
├── variables.tf        # all input variables, grouped by domain
├── outputs.tf          # key operational outputs
├── resource-groups.tf  # 4x azurerm_resource_group (MC_ RG is AKS-managed)
├── network.tf          # VNet (8 subnets), 2 private DNS zones
├── compute.tf          # AKS + node pools, ACR (feature-flagged), Bastion (raw resource)
├── data.tf             # PostgreSQL Flexible Server + databases, Redis Cache + PE
├── edge.tf             # AFD raw resources (profile, WAF, endpoint, origins, route, rule set, custom domains, security policy), PLS
├── integration.tf      # Service Bus, 2x Function App (raw FC1), 2x App Service Plan (raw), 2x Storage Account, User Assigned Identity
├── backend.hcl         # azurerm backend partial config
├── dev.tfvars          # dev environment values
└── prod.tfvars         # prod environment values (created when needed)
```

## Resource Inventory

### Resource Groups (`resource-groups.tf`)

| Name | Purpose | Managed by |
|------|---------|------------|
| `rg-aks-dtq-itn-01` | Core infra | Terraform |
| `MC_rg-aks-dtq-itn-01_aks-dtq-itn-01_italynorth` | AKS node resources | AKS (not in Terraform) |
| `rg-psql-dtq-itn-01` | PostgreSQL | Terraform |
| `rg-bcintegration-dtq-itn-001` | BC integration | Terraform |
| `rg-shopintegration-dtq-itn-001` | Shop integration | Terraform |

### Network Layer (`network.tf`)

**VNet** — `virtual-network` module (v1.1.0):
- Name: `vnet-web-dtq-itn-01`
- Address space: `10.150.128.0/21`
- Resource group: `rg-aks-dtq-itn-01`
- 8 subnets:

| Subnet | Prefix | Delegation | Special flags |
|--------|--------|------------|---------------|
| `snet-aks` | `10.150.128.0/24` | — | PrivateLinkServiceNetworkPolicies: Disabled |
| `snet-pe` | `10.150.129.0/24` | — | — |
| `snet-management` | `10.150.135.0/27` | — | — |
| `snet-prvendpoint` | `10.150.135.32/27` | `Microsoft.DBforPostgreSQL/flexibleServers` | — |
| `snet-prvendpointfuncapp` | `10.150.135.64/27` | — | — |
| `snet-outboundfuncapp` | `10.150.135.96/27` | `Microsoft.App/environments` | — |
| `snet-prvendpointfuncapp-uat` | `10.150.135.128/27` | — | — |
| `snet-outboundfuncapp-uat` | `10.150.135.160/27` | `Microsoft.App/environments` | — |

UAT subnets are included (they exist today; omitting would cause deletion on apply). Prod tfvars will not include them.

**Private DNS Zones** — `private-dns-zone` module (v1.1.0):
- `privatelink.redis.cache.windows.net` — linked to VNet
- `privatelink.azurewebsites.net` — linked to VNet

Note: the PostgreSQL DNS zone (`psql-site-tdq-itn-001.private.postgres.database.azure.com`) is instance-specific and managed by the PostgreSQL Flexible Server resource via VNet integration, not as a separate resource.

### Compute Layer (`compute.tf`)

**AKS** — `aks` module (v1.5.0):
- Name: `aks-dtq-itn-01`
- Kubernetes version: `1.32`
- SKU tier: Standard
- Identity: SystemAssigned
- Network: Azure CNI, pod CIDR `10.244.0.0/16`, service CIDR `172.16.0.0/16`
- Outbound: loadBalancer
- Public cluster (not private)
- AAD: managed, admin group `d033e558-024a-48c7-a45a-e59c81fb5041`, Azure RBAC disabled
- OIDC / Workload Identity: disabled
- Monitoring: OMS agent enabled → existing LAW (data source from `DefaultResourceGroup-ITN`)
- Node resource group: `MC_rg-aks-dtq-itn-01_aks-dtq-itn-01_italynorth`

Default node pool (inline):

| Setting | Value |
|---------|-------|
| Name | `system` |
| Mode | System |
| VM Size | `Standard_D2s_v5` |
| Count | 2 |
| Autoscaling | No |
| Max pods | 110 |
| OS disk | 128GB Managed |
| Zones | 1, 2, 3 |

Additional node pool — `aks-node-pool` module (v1.1.0):

| Setting | Value |
|---------|-------|
| Name | `userpool04` |
| Mode | User |
| VM Size | `Standard_D2s_v5` |
| Count | 3 |
| Autoscaling | No |
| Max pods | 250 |
| OS disk | 128GB Managed |
| Zones | 1, 2, 3 |

**ACR** — `container-registry` module (v1.1.0):
- Name: `crdtitn001`
- SKU: Standard
- Admin: disabled
- Public access: enabled
- Feature flag: `create_acr` variable (default true in dev, false in prod if sharing)

**Bastion** — raw `azurerm_bastion_host` resource:
- Name: `vnet-web-dtq-itn-01-bastion`
- SKU: Developer
- No public IP, no dedicated subnet (attaches to VNet directly via `virtual_network_id`)
- Raw resource because public module only supports Basic/Standard SKU

### Data Layer (`data.tf`)

**PostgreSQL Flexible Server** — `postgresql-flexible-server` module (v1.1.0):
- Name: `psql-site-tdq-itn-001`
- Version: 17
- SKU: `Standard_B2s` (Burstable)
- Storage: 32GB, auto-grow disabled
- HA: disabled
- Backup: 7-day retention, no geo-redundant
- Auth: password + Entra ID
- Admin login: `psqladmin`
- Admin password: sensitive variable (not in tfvars)
- Network: VNet integration via delegated subnet `snet-prvendpoint`
- Private DNS zone: instance-specific (created by the resource)
- Databases:

| Database | Charset | Collation |
|----------|---------|-----------|
| `medusa_db` | UTF8 | en_US.utf8 |
| `payload_db` | UTF8 | en_US.utf8 |
| `order_legacy_db` | UTF8 | en_US.utf8 |
| `middleware_db` | UTF8 | en_US.utf8 |

System databases (`postgres`, `azure_maintenance`, `azure_sys`) are not managed.

**Redis Cache** — `redis-cache` module (v1.1.0):
- Name: `redis-deghi-dtq-itn-01`
- SKU: Premium, family P, capacity 1
- Version: 6.0
- TLS: 1.2 minimum
- Non-SSL port: disabled
- Public access: disabled
- Memory policy: `noeviction`
- Replicas per master: 1
- Private endpoint: `redis-deghi-dtq-itn-01-pe` in `snet-pe`
- DNS zone: `privatelink.redis.cache.windows.net`

### Edge Layer (`edge.tf`)

All raw `azurerm_cdn_frontdoor_*` resources (public module lacks custom domains, WAF, rule sets, Private Link):

**AFD Profile**:
- Name: `fd-dtq-itn-01-fdp`
- SKU: `Premium_AzureFrontDoor`

**WAF Policy**:
- Name: `waffddtqitn01`
- Mode: Detection (dev) / Prevention (prod)
- Managed rule: DefaultRuleSet v1.0, action Block

**Endpoint**: `dtq-endpoint`

**Origin Group**: `og-aks`
- Health probe: `/healthz`, HTTP, 30s interval
- Load balancing: sample 4, require 3

**Origin**: `aks-origin`
- Host: `10.150.128.250` (internal LB)
- HTTP port 80, HTTPS port 443
- Private Link to PLS
- `lifecycle { ignore_changes }` on `origin_host_header`, `private_link`, `certificate_name_check_enabled`

**Custom Domains** (managed TLS, `for_each`):
- `dev-store.deghi.it`
- `dev-store-admin.deghi.it`
- `dev-store-api.deghi.it`
- `dev-desk.deghi.it`
- `dev-cms.deghi.it`

**Route**: `route-default`
- Pattern: `/*`
- HTTP→HTTPS redirect
- Forwarding: HttpOnly
- Cache: IgnoreQueryString
- Linked to all custom domains

**Rule Set**: `ForwardHostHeader`
- Rule: `StripAcceptEncoding` — deletes `Accept-Encoding` header from requests to origin

**Security Policy**: WAF attached to endpoint + all custom domains

**Private Link Service** — raw `azurerm_private_link_service`:
- Name: `pls-aks-dtq-itn-01`
- Subnet: `snet-aks`
- Fronts `kubernetes-internal` LB
- Location: `westeurope` (Italy North not supported for AFD Private Link)

### Integration Layer (`integration.tf`)

**Service Bus** — `service-bus` module (v1.1.0):
- Namespace: `bcintdtqitn001`
- SKU: Standard
- Zone redundant: true
- Local auth: enabled
- Public access: enabled
- 16 topics (all 1024MB max size):

```
bc_response_to_deghilogistic    bc_to_deghilogistic
bc_response_to_easystock        bc_to_easystock
bc_response_to_medusa           bc_to_medusa
deghilogistic_response_to_bc    deghilogistic_to_bc
easystock_response_to_bc        easystock_to_bc
easystock_response_to_medusa    easystock_to_medusa
medusa_response_to_bc           medusa_to_bc
medusa_response_to_easystock    medusa_to_easystock
```

**Function Apps** — raw `azurerm_function_app_flex_consumption` resources (module doesn't support FC1):

| Setting | `func-bcint-dtq-itn-001` | `func-shopint-dtq-itn-001` |
|---------|--------------------------|----------------------------|
| Resource group | `rg-bcintegration-dtq-itn-001` | `rg-shopintegration-dtq-itn-001` |
| Runtime | Linux | Linux |
| Hosting plan | Flex Consumption (FC1) | Flex Consumption (FC1) |
| Identity | None | UserAssigned |
| Private endpoint | `prv-funcapp-dtq-int-001` in `snet-prvendpointfuncapp` | `prv-funcapp-dtq-int-002` in `snet-pe` |
| App settings | Not managed | Not managed |

**App Service Plans** — raw `azurerm_service_plan`:
- `ASP-rgbcintegrationdtqitn001-8502` — FC1, Linux, in `rg-bcintegration-dtq-itn-001`
- `ASP-rgshopintegrationdtqitn001-bbc4` — FC1, Linux, in `rg-shopintegration-dtq-itn-001`

**User Assigned Identity** — `user-assigned-identity` module (v1.1.0):
- Name: `func-shopint-dtq-itn-001-uami`
- Resource group: `rg-shopintegration-dtq-itn-001`

**Storage Accounts** — `storage-account` module (v1.1.0):
- `stgaccfadtqitn001` — Standard_LRS, in `rg-bcintegration-dtq-itn-001` (BC func app storage)
- `stgaccfadtqitn002` — Standard_LRS, in `rg-shopintegration-dtq-itn-001` (shop func app storage)

Note: `stgacctfdtqitn001` (Terraform state backend) is NOT managed by Terraform.

### Locals (`locals.tf`)

```hcl
locals {
  environment = var.environment  # "dev" or "prod"
  common_tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
  })
}

data "azurerm_log_analytics_workspace" "default" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_rg
}
```

LAW name and resource group are variables so prod can reference a different workspace if needed.

### State Backend

- Storage account: `stgacctfdtqitn001` (pre-existing, not managed)
- Container: `tfstate`
- Key: `dtq/terraform.tfstate` (new key; old `frontdoor/terraform.tfstate` is abandoned or migrated)
- Configured via `backend.hcl` + `terraform init -backend-config=backend.hcl`

### Outputs (`outputs.tf`)

Key operational values:
- AKS cluster ID and name
- ACR login server (conditional on `create_acr`)
- PostgreSQL FQDN
- Redis hostname
- AFD endpoint FQDN
- Custom domain validation tokens
- PLS alias

## Import Strategy

After writing the Terraform config:

1. `terraform init -backend-config=backend.hcl`
2. `terraform import` each existing resource using its Azure resource ID and the Terraform address (e.g., `module.aks.azurerm_kubernetes_cluster.this`)
3. `terraform plan` to verify zero diff (or minimal expected drift)
4. Resolve any drift, iterate until clean

Import order follows dependency order: resource groups → network → data → compute → edge → integration.

The exact import commands will be generated as part of the implementation plan.

## Module Gaps — Upstream Specs

### 1. Front Door Module (v1.0.0 → v2.0.0)

The public `front-door` module needs:
- Custom domains with managed TLS
- WAF firewall policy + security policy
- Rule sets and rules
- Private Link on origins
- Route compression and rule set association

Separate spec doc to be written. Implementation is parallel — DTQ uses raw resources until the module is upgraded.

### 2. Function App Module — Flex Consumption

The public `function-app` module uses `azurerm_linux_function_app` which doesn't support FC1. Needs:
- `azurerm_function_app_flex_consumption` resource support
- Instance memory, always-ready instances, per-function scaling config
- Different storage configuration (managed identity-based)

Separate spec doc to be written. Implementation is parallel — DTQ uses raw resources until the module is upgraded.

### 3. Bastion Module — Developer SKU

The public `bastion` module only supports Basic/Standard. Developer SKU needs:
- Conditional public IP creation
- `virtual_network_id` instead of `subnet_id`
- No `ip_configuration` block

Low priority — Developer SKU is ~8 lines of HCL. Can be upstreamed later.
