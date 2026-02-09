# Module: front-door

**Priority:** P3
**Status:** Complete
**Target Version:** v1.0.0

## What It Creates

- `azurerm_cdn_frontdoor_profile` — Front Door profile
- `azurerm_cdn_frontdoor_endpoint` — Endpoints (for_each)
- `azurerm_cdn_frontdoor_origin_group` — Origin groups (for_each)
- `azurerm_cdn_frontdoor_origin` — Origins (for_each)
- `azurerm_cdn_frontdoor_route` — Routes (for_each)

## v1.0.0 Scope

An Azure Front Door profile with endpoints, origin groups, origins, and routes for global content delivery and load balancing.

### In Scope

- Profile creation with configurable SKU (Standard, Premium)
- Endpoint management with for_each
- Origin group management with health probes and load balancing
- Origin management with weighted routing and priority
- Route management with pattern matching and protocol configuration
- Cross-reference between resources using map keys
- Secure defaults (HTTPS redirect, HttpsOnly forwarding, certificate name check)

### Out of Scope (Deferred)

- Custom domains and TLS certificates
- WAF policy association (Premium)
- Rule sets and rule engine
- Origin Private Link (connecting Front Door to private origins)
- Compression settings
- Caching configuration
- Diagnostic settings (use the standalone `diagnostic-settings` module)

## Feature Flags

No feature flags. Front Door is a global resource with no private endpoint or public access toggles.

## Private Endpoint Support

No private endpoint. Front Door is a global edge service. Origin Private Link is deferred to a future version.

## Variables

Beyond the standard interface (`resource_group_name`, `name`, `tags`). **No `location` variable** — Front Door is global.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `sku_name` | string | No | `"Standard_AzureFrontDoor"` | SKU: Standard or Premium |
| `response_timeout_seconds` | number | No | `60` | Response timeout (16-240) |
| `endpoints` | map(object) | No | `{}` | Map of endpoints |
| `origin_groups` | map(object) | No | `{}` | Map of origin groups with health probes and load balancing |
| `origins` | map(object) | No | `{}` | Map of origins referencing origin groups by key |
| `routes` | map(object) | No | `{}` | Map of routes referencing endpoints and origin groups by key |

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `resource_guid` | Front Door profile GUID |
| `endpoint_ids` | Map of endpoint names to resource IDs |
| `endpoint_host_names` | Map of endpoint names to host names |
| `origin_group_ids` | Map of origin group names to resource IDs |
| `origin_ids` | Map of origin names to resource IDs |
| `route_ids` | Map of route names to resource IDs |
| `public_frontdoor_id` | Profile ID (public output) |
| `public_frontdoor_name` | Profile name (public output) |
| `public_frontdoor_endpoint_host_names` | Endpoint host names (public output) |

## Notes

- **No location variable:** Front Door is a global resource.
- **Endpoint names must be globally unique:** They become part of the FQDN (`<name>.azurefd.net`).
- **Tags on profile and endpoints only:** Origin groups, origins, and routes don't support tags.
- **Cross-referencing:** Origins reference origin groups by map key. Routes reference endpoints and origin groups by map key.
- **Origin host header:** Defaults to hostname if not specified.
- **Load balancing always included:** AzureRM 4.x requires it. Module provides defaults.
- **Most complex P3 module:** Five interconnected resources with cross-references.
