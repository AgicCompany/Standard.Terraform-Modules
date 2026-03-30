# Front Door Module Upgrade — v2.0.0 Spec

## Problem

The public `front-door` module (v1.0.0) at `AgicCompany/Standard.Terraform-Modules` only supports a minimal feature set: profile, endpoints, origin groups, origins, and routes. It has no support for custom domains, WAF policies, rule sets, Private Link on origins, or security policies.

Production use cases — including the DTQ deployment — require all of these features. Today the DTQ stack works around this by using raw `azurerm_cdn_frontdoor_*` resources directly in `infrastructure/edge.tf`. That implementation is the reference for this upgrade.

## Scope of v2.0.0

### 1. Custom Domains

Add `azurerm_cdn_frontdoor_custom_domain` via a `for_each` map input.

```hcl
variable "custom_domains" {
  type = map(object({
    hostname         = string
    certificate_type = optional(string, "ManagedCertificate")
  }))
  default     = {}
  description = "Map of custom domains to attach to the Front Door profile."
}
```

Resource pattern:

```hcl
resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  for_each                 = var.custom_domains
  name                     = replace(each.value.hostname, ".", "-")
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  host_name                = each.value.hostname

  tls {
    certificate_type = each.value.certificate_type
  }
}
```

Outputs to add:

```hcl
output "custom_domain_ids" {
  value = { for k, v in azurerm_cdn_frontdoor_custom_domain.this : k => v.id }
}

output "custom_domain_validation_tokens" {
  value = { for k, v in azurerm_cdn_frontdoor_custom_domain.this : k => v.validation_token }
}
```

Validation tokens are needed by consumers to create DNS TXT records for domain ownership verification.

### 2. WAF Policy

Add `azurerm_cdn_frontdoor_firewall_policy` with configurable managed rules.

```hcl
variable "waf" {
  type = object({
    name = string
    mode = optional(string, "Detection")   # Detection | Prevention
    managed_rules = optional(list(object({
      type    = string
      version = string
      action  = string
    })), [])
  })
  default     = null
  description = "WAF firewall policy configuration. Null disables WAF."
}
```

Resource pattern:

```hcl
resource "azurerm_cdn_frontdoor_firewall_policy" "this" {
  count               = var.waf != null ? 1 : 0
  name                = var.waf.name
  resource_group_name = var.resource_group_name
  sku_name            = azurerm_cdn_frontdoor_profile.this.sku_name
  mode                = var.waf.mode

  dynamic "managed_rule" {
    for_each = var.waf.managed_rules
    content {
      type    = managed_rule.value.type
      version = managed_rule.value.version
      action  = managed_rule.value.action
    }
  }
}
```

### 3. Rule Sets and Rules

Add `azurerm_cdn_frontdoor_rule_set` and `azurerm_cdn_frontdoor_rule` via a nested map structure.

```hcl
variable "rule_sets" {
  type = map(object({
    rules = map(object({
      order = number
      conditions = optional(object({
        url_file_extension = optional(object({
          operator     = string
          match_values = list(string)
        }))
        request_header = optional(object({
          operator     = string
          header_name  = string
          match_values = list(string)
        }))
      }))
      actions = object({
        request_header_actions = optional(list(object({
          header_action = string   # Delete | Overwrite | Append
          header_name   = string
          value         = optional(string)
        })), [])
        response_header_actions = optional(list(object({
          header_action = string
          header_name   = string
          value         = optional(string)
        })), [])
        url_rewrite = optional(object({
          source_pattern          = string
          destination             = string
          preserve_unmatched_path = optional(bool, true)
        }))
        url_redirect = optional(object({
          redirect_type        = string
          redirect_protocol    = optional(string, "Https")
          destination_hostname = optional(string)
          destination_path     = optional(string)
        }))
      })
    }))
  }))
  default     = {}
  description = "Map of rule sets. Each rule set contains a map of rules."
}
```

Rule sets and rules use `for_each` on the outer and inner maps respectively. Rule order is specified per-rule in the `order` field.

### 4. Private Link on Origins

Extend the origin object to accept an optional `private_link` block.

```hcl
# Inside the origins object definition:
private_link = optional(object({
  target_id       = string
  location        = string   # Must match PLS region; westeurope for Italy North deployments
  request_message = optional(string, "AFD Private Link connection")
}))
```

Resource snippet:

```hcl
dynamic "private_link" {
  for_each = origin.value.private_link != null ? [origin.value.private_link] : []
  content {
    private_link_target_id = private_link.value.target_id
    location               = private_link.value.location
    request_message        = private_link.value.request_message
  }
}
```

**Important**: AFD Private Link connections are not auto-approved even if the subscription is listed in `auto_approval_subscription_ids` on the PLS, because the AFD private endpoint lives in Microsoft's subscription. Consumers must approve the connection manually via the Portal or CLI after `terraform apply`.

The `location` field must reflect where the Private Link Service is deployed, not the AFD profile region. For Azure Italy North PLS deployments, use `westeurope` — Italy North is not supported as an AFD Private Link location.

### 5. Route Enhancements

Extend the route object with:

- `cdn_frontdoor_rule_set_ids` — list of rule set keys to associate (resolved from `azurerm_cdn_frontdoor_rule_set.this`)
- `cdn_frontdoor_custom_domain_ids` — list of custom domain keys to associate (resolved from `azurerm_cdn_frontdoor_custom_domain.this`)
- `compression_enabled` — bool, default `false`
- `content_types_to_compress` — list of MIME types, only used when `compression_enabled = true`

```hcl
# Inside the route object definition:
rule_set_keys       = optional(list(string), [])
custom_domain_keys  = optional(list(string), [])
compression_enabled = optional(bool, false)
content_types_to_compress = optional(list(string), [])
```

### 6. Security Policy

Add `azurerm_cdn_frontdoor_security_policy` associating the WAF policy with the endpoint and all custom domains.

```hcl
resource "azurerm_cdn_frontdoor_security_policy" "this" {
  count                    = var.waf != null ? 1 : 0
  name                     = "${var.profile_name}-waf-sp"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.this[0].id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.this.id
        }

        dynamic "domain" {
          for_each = var.custom_domains
          content {
            cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.this[domain.key].id
          }
        }

        patterns_to_match = ["/*"]
      }
    }
  }

  depends_on = [azurerm_cdn_frontdoor_route.this]
}
```

## Breaking Changes from v1.0.0

This is a major version bump. The variable structure changes significantly:

| Area | v1.0.0 | v2.0.0 |
|------|--------|--------|
| Custom domains | Not supported | New `custom_domains` map variable |
| WAF | Not supported | New `waf` object variable |
| Rule sets | Not supported | New `rule_sets` map variable |
| Origins | Simple host/port object | Extended with optional `private_link` block |
| Routes | `rule_set_ids` list of strings | `rule_set_keys` referencing internal rule sets |
| Routes | `custom_domain_ids` not present | `custom_domain_keys` referencing internal domains |

Consumers upgrading from v1.0.0 must update their variable inputs.

## Reference Implementation

`infrastructure/edge.tf` in this repository (`deghi-dtq`) is the working reference for all features above. All resources described in this spec are deployed and verified in production as of 2026-03-12.

## Priority

High — required before DTQ infrastructure can be migrated from raw resources to the module. Also a prerequisite for any future project that needs AFD with WAF or custom domains.
