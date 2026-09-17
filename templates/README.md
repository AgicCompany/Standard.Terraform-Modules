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

## Validating

```bash
cd templates/<name>
terraform init -backend=false
terraform validate
```

`init` fetches the pinned module tags over git, so it needs read access to
this repository.
