# cosmosdb

**Complexity:** Medium

Creates an Azure Cosmos DB account with SQL API databases and optional private endpoint.

## Usage

```hcl
module "cosmosdb" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//cosmosdb?ref=cosmosdb/v1.0.0"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "cosmos-myapp-dev-weu-001"

  sql_databases = {
    appdb = {}
  }

  enable_private_endpoint = false
  enable_public_access    = true

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

## Features

- Cosmos DB account with SQL API (GlobalDocumentDB)
- SQL database management via for_each map
- Autoscale throughput support for databases
- Configurable consistency policy
- Multi-region geo-replication
- Automatic failover support
- Private endpoint with DNS zone integration
- Periodic and continuous backup policies
- IP firewall rules
- Free tier support
- Entra ID (AAD) and key-based authentication

## Security Defaults

- Public network access disabled by default
- Private endpoint enabled by default
- TLS 1.2 minimum
- Local authentication enabled by default (set `enable_local_auth = false` for AAD-only)

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **Free tier:** Only one Cosmos DB account per subscription can use free tier. Set `free_tier_enabled = true` to use it.
- **Consistency levels:** BoundedStaleness requires `max_interval_in_seconds` and `max_staleness_prefix`. Other levels ignore these fields.
- **Geo-locations:** If `geo_locations` is null, the account is created with a single region (the primary location). For multi-region, specify at least two locations with different failover priorities.
- **Backup:** Periodic backup is the default. For continuous backup (point-in-time restore), set `backup.type = "Continuous"`.
- **SQL API only:** This module creates SQL API databases. For MongoDB, Cassandra, Gremlin, or Table API, the account kind and database resources would need to be different.
- **Provisioning time:** Cosmos DB accounts can take 5-15 minutes to provision, especially with geo-replication.
