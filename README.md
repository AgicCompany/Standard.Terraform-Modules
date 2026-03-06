# Terraform Module Framework for Azure

A library of reusable, production-ready Terraform modules for Microsoft Azure. All modules follow the organization's [Module Standards](docs/MODULE_STANDARDS.md) with secure defaults, CAF naming conventions, and private-first networking.

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.9.0 |
| AzureRM Provider | >= 4.0.0 |

## Design Principles

- **Private by default** — Private endpoints enabled, public access disabled
- **Secure defaults** — TLS 1.2, managed identity, local auth disabled where applicable
- **CAF naming** — All resource names follow Cloud Adoption Framework conventions
- **Consistent interface** — Standardized variables, outputs, and feature flags across modules

## Modules

### Foundation

| Module | Description |
|--------|-------------|
| [virtual-network](modules/virtual-network) | Virtual network with subnets, delegation, and NSG/UDR associations |
| [network-security-group](modules/network-security-group) | Network security group with map-based security rules |
| [private-dns-zone](modules/private-dns-zone) | Private DNS zones with VNet links |
| [route-table](modules/route-table) | Route tables with configurable routes |
| [nat-gateway](modules/nat-gateway) | NAT gateway with public IP |
| [vnet-peering](modules/vnet-peering) | Bidirectional VNet peering |
| [storage-account](modules/storage-account) | Storage account with multi-subresource private endpoints |
| [key-vault](modules/key-vault) | Key Vault with RBAC authorization and private endpoint |
| [user-assigned-identity](modules/user-assigned-identity) | User-assigned managed identity |
| [log-analytics-workspace](modules/log-analytics-workspace) | Log Analytics workspace |
| [diagnostic-settings](modules/diagnostic-settings) | Diagnostic settings attachment for any resource |

### Compute

| Module | Description |
|--------|-------------|
| [aks](modules/aks) | Azure Kubernetes Service with private cluster, Azure AD auth, and default maintenance windows |
| [aks-node-pool](modules/aks-node-pool) | AKS node pool companion module with for_each support |
| [app-service-plan](modules/app-service-plan) | App Service plan (Linux/Windows) |
| [linux-web-app](modules/linux-web-app) | Linux Web App with VNet integration and private endpoint |
| [function-app](modules/function-app) | Linux Function App with VNet integration and private endpoint |
| [container-app-environment](modules/container-app-environment) | Container Apps environment with VNet integration |
| [container-app](modules/container-app) | Container App with ingress, secrets, and scaling rules |
| [container-registry](modules/container-registry) | Container Registry with geo-replication and private endpoint |
| [linux-virtual-machine](modules/linux-virtual-machine) | Linux VM with managed identity, SSH key or password auth |
| [windows-virtual-machine](modules/windows-virtual-machine) | Windows VM with managed identity |
| [bastion](modules/bastion) | Azure Bastion host for secure VM access |
| [static-web-app](modules/static-web-app) | Azure Static Web App with optional private endpoint |

### Data

| Module | Description |
|--------|-------------|
| [mssql-server](modules/mssql-server) | Azure SQL Server with Azure AD admin and private endpoint |
| [mssql-database](modules/mssql-database) | Azure SQL Database with configurable SKU and retention |
| [mysql-flexible-server](modules/mysql-flexible-server) | MySQL Flexible Server with private endpoint or VNet integration |
| [postgresql-flexible-server](modules/postgresql-flexible-server) | PostgreSQL Flexible Server with private endpoint or VNet integration |
| [cosmosdb](modules/cosmosdb) | Cosmos DB account with SQL databases and private endpoint |
| [redis-cache](modules/redis-cache) | Azure Cache for Redis with private endpoint |

### Networking

| Module | Description |
|--------|-------------|
| [application-gateway](modules/application-gateway) | Application Gateway v2 with WAF and SSL termination |
| [front-door](modules/front-door) | Azure Front Door with WAF policy and custom domains |
| [api-management](modules/api-management) | API Management with VNet integration and private endpoint |

### Messaging

| Module | Description |
|--------|-------------|
| [service-bus](modules/service-bus) | Service Bus namespace with queues, topics, and private endpoint |
| [event-hub](modules/event-hub) | Event Hub namespace with hubs, consumer groups, and private endpoint |

### Monitoring

| Module | Description |
|--------|-------------|
| [application-insights](modules/application-insights) | Application Insights with workspace-based configuration |
| [action-group](modules/action-group) | Action group with email, SMS, and webhook receivers |

## Documentation

- [Module Standards](docs/MODULE_STANDARDS.md) — Structure, conventions, and defaults
- [Implementation Plan](docs/IMPLEMENTATION_PLAN.md) — Build order and module specifications
- [Test Results](docs/TEST_RESULTS.md) — Live deployment test outcomes

## Usage

Modules are consumed via Git source references with version tags:

```hcl
module "vnet" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/virtual-network?ref=virtual-network/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "vnet-payments-dev-weu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-app = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }

  tags = local.common_tags
}
```

Each module follows independent semantic versioning: `<module-name>/v<major>.<minor>.<patch>`.
