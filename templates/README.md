# Starter templates

Ready-to-use Terraform roots composing modules from this repository into
common Azure architecture patterns. Each directory is a self-contained root
(`main.tf`, `versions.tf`, `terraform.tfvars.example.json`, `README.md`)
with module sources pinned to released tags. They are deliberately minimal
(no private endpoints / VNet integration / diagnostics unless the pattern
needs them) so they work as a starting point rather than a hardened
reference.

| Template | Pattern |
|----------|---------|
| [web-app-db](web-app-db/) | PaaS web app + PostgreSQL + Redis + Key Vault + App Insights |
| [aks-microservices](aks-microservices/) | AKS cluster with user node pool, ACR, workload identity, Key Vault, Log Analytics |
| [serverless-event-driven](serverless-event-driven/) | Flex Consumption Function App + Service Bus + Cosmos DB + Storage + App Insights |
| [networking-hub-baseline](networking-hub-baseline/) | VNet with NSG, route table, NAT gateway, Bastion, private DNS zone |
| [container-apps-basic](container-apps-basic/) | VNet-integrated Container Apps environment + app, ACR, workload identity, Log Analytics |
| [linux-vm-jumpbox](linux-vm-jumpbox/) | Single Linux VM behind Bastion with its own VNet and NSG, SSH key only |
| [static-web-api](static-web-api/) | Static Web App + Flex Consumption Function App API, Storage, App Insights |
| [sql-web-app](sql-web-app/) | App Service web app + Azure SQL (Entra-only), Key Vault, App Insights — SQL twin of web-app-db |
| [windows-vm-jumpbox](windows-vm-jumpbox/) | Single Windows VM behind Bastion with its own VNet and NSG |
| [container-apps-jobs](container-apps-jobs/) | Container Apps environment with a cron-triggered job, ACR, workload identity |
| [hub-spoke-peering](hub-spoke-peering/) | Hub + spoke VNets peered both ways, route table and NSG for the spoke |

## Validating

```bash
cd templates/<name>
terraform init -backend=false
terraform validate
```

`init` fetches the pinned module tags over git, so it needs read access to
this repository.
