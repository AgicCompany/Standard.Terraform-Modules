# Front Door v1.1.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add custom domains, WAF (managed rules), rule sets, Private Link on origins, route enhancements, and security policies to the front-door module as a non-breaking minor version bump.

**Architecture:** All new features are additive optional variables with sensible defaults. Existing consumers are not affected. New resources are conditionally created via `for_each` (custom domains, rule sets) or `count` (WAF, security policy). Routes and origins are extended with optional fields that resolve internal resource keys to IDs.

**Tech Stack:** Terraform >= 1.9.0, AzureRM >= 4.0.0

**Spec:** `docs/specs/2026-03-30-module-upgrades-design.md` (Stream 2)

---

## File Map

All changes are in `modules/front-door/`:

| File | Changes |
|------|---------|
| `variables.tf` | Add `custom_domains`, `waf`, `rule_sets` variables. Extend `origins` and `routes` object types. |
| `main.tf` | Add 5 new resources. Add `private_link` dynamic block to origins. Extend routes with rule set/domain IDs and compression. |
| `outputs.tf` | Add `custom_domain_ids`, `custom_domain_validation_tokens`, `firewall_policy_id`, `rule_set_ids`. |
| `CHANGELOG.md` | New v1.1.0 section. |
| `examples/basic/main.tf` | Minor update if needed. |
| `examples/complete/main.tf` | Add custom domain, WAF, rule set, Private Link usage. |

---

### Task 1: Add custom domains variable + resource + outputs

**Files:**
- Modify: `modules/front-door/variables.tf`
- Modify: `modules/front-door/main.tf`
- Modify: `modules/front-door/outputs.tf`

- [ ] **Step 1: Add custom_domains variable to variables.tf**

Insert before `# === Tags ===`:

```hcl
# === Optional: Custom Domains ===
variable "custom_domains" {
  type = map(object({
    hostname         = string
    certificate_type = optional(string, "ManagedCertificate")
  }))
  default     = {}
  description = "Map of custom domains to attach to the Front Door profile. Key is used as the domain resource name."
}
```

- [ ] **Step 2: Add custom domain resource to main.tf**

Append after the `azurerm_cdn_frontdoor_origin` resource block:

```hcl
resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  for_each = var.custom_domains

  name                     = replace(each.value.hostname, ".", "-")
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  host_name                = each.value.hostname

  tls {
    certificate_type = each.value.certificate_type
  }
}
```

- [ ] **Step 3: Add custom domain outputs to outputs.tf**

Append before the `# === Public Outputs` section:

```hcl
output "custom_domain_ids" {
  value       = { for k, v in azurerm_cdn_frontdoor_custom_domain.this : k => v.id }
  description = "Map of custom domain keys to their resource IDs"
}

output "custom_domain_validation_tokens" {
  value       = { for k, v in azurerm_cdn_frontdoor_custom_domain.this : k => v.validation_token }
  description = "Map of custom domain keys to their DNS validation tokens"
}
```

- [ ] **Step 4: Validate**

```bash
cd modules/front-door && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 5: Commit**

```bash
git add modules/front-door/
git commit -m "front-door: add custom domains with managed TLS"
```

---

### Task 2: Add WAF variable + firewall policy resource + output

**Files:**
- Modify: `modules/front-door/variables.tf`
- Modify: `modules/front-door/main.tf`
- Modify: `modules/front-door/outputs.tf`

- [ ] **Step 1: Add waf variable to variables.tf**

Insert after the `custom_domains` variable:

```hcl
# === Optional: WAF ===
variable "waf" {
  type = object({
    name = string
    mode = optional(string, "Detection")
    managed_rules = optional(list(object({
      type    = string
      version = string
      action  = string
    })), [])
  })
  default     = null
  description = "WAF firewall policy configuration. Null disables WAF. Custom rules deferred to v1.2.0+."

  validation {
    condition     = var.waf == null || contains(["Detection", "Prevention"], var.waf.mode)
    error_message = "waf.mode must be \"Detection\" or \"Prevention\"."
  }
}
```

- [ ] **Step 2: Add firewall policy resource to main.tf**

Append after the `azurerm_cdn_frontdoor_custom_domain` resource:

```hcl
resource "azurerm_cdn_frontdoor_firewall_policy" "this" {
  count = var.waf != null ? 1 : 0

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

- [ ] **Step 3: Add firewall policy output to outputs.tf**

Append after the `custom_domain_validation_tokens` output:

```hcl
output "firewall_policy_id" {
  value       = var.waf != null ? azurerm_cdn_frontdoor_firewall_policy.this[0].id : null
  description = "WAF firewall policy resource ID (null if WAF disabled)"
}
```

- [ ] **Step 4: Validate**

```bash
cd modules/front-door && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 5: Commit**

```bash
git add modules/front-door/
git commit -m "front-door: add WAF firewall policy with managed rules"
```

---

### Task 3: Add rule sets variable + resources + output

**Files:**
- Modify: `modules/front-door/variables.tf`
- Modify: `modules/front-door/main.tf`
- Modify: `modules/front-door/outputs.tf`

- [ ] **Step 1: Add rule_sets variable to variables.tf**

Insert after the `waf` variable:

```hcl
# === Optional: Rule Sets ===
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
          header_action = string
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
  description = "Map of rule sets. Each rule set contains a map of rules with conditions and actions."
}
```

- [ ] **Step 2: Add locals for flattened rules**

Create `modules/front-door/locals.tf` (or add to it if it exists):

```hcl
locals {
  # Flatten rule_sets.rules into a single map for for_each
  rules_flat = merge([
    for rs_key, rs in var.rule_sets : {
      for r_key, r in rs.rules : "${rs_key}/${r_key}" => merge(r, {
        rule_set_key = rs_key
        rule_key     = r_key
      })
    }
  ]...)
}
```

- [ ] **Step 3: Add rule set and rule resources to main.tf**

Append after the `azurerm_cdn_frontdoor_firewall_policy` resource:

```hcl
resource "azurerm_cdn_frontdoor_rule_set" "this" {
  for_each = var.rule_sets

  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
}

resource "azurerm_cdn_frontdoor_rule" "this" {
  for_each = local.rules_flat

  name                      = each.value.rule_key
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.this[each.value.rule_set_key].id
  order                     = each.value.order

  dynamic "conditions" {
    for_each = each.value.conditions != null ? [each.value.conditions] : []

    content {
      dynamic "url_file_extension_condition" {
        for_each = conditions.value.url_file_extension != null ? [conditions.value.url_file_extension] : []
        content {
          operator     = url_file_extension_condition.value.operator
          match_values = url_file_extension_condition.value.match_values
        }
      }

      dynamic "request_header_condition" {
        for_each = conditions.value.request_header != null ? [conditions.value.request_header] : []
        content {
          operator     = request_header_condition.value.operator
          header_name  = request_header_condition.value.header_name
          match_values = request_header_condition.value.match_values
        }
      }
    }
  }

  actions {
    dynamic "request_header_action" {
      for_each = each.value.actions.request_header_actions
      content {
        header_action = request_header_action.value.header_action
        header_name   = request_header_action.value.header_name
        value         = request_header_action.value.value
      }
    }

    dynamic "response_header_action" {
      for_each = each.value.actions.response_header_actions
      content {
        header_action = response_header_action.value.header_action
        header_name   = response_header_action.value.header_name
        value         = response_header_action.value.value
      }
    }

    dynamic "url_rewrite_action" {
      for_each = each.value.actions.url_rewrite != null ? [each.value.actions.url_rewrite] : []
      content {
        source_pattern          = url_rewrite_action.value.source_pattern
        destination             = url_rewrite_action.value.destination
        preserve_unmatched_path = url_rewrite_action.value.preserve_unmatched_path
      }
    }

    dynamic "url_redirect_action" {
      for_each = each.value.actions.url_redirect != null ? [each.value.actions.url_redirect] : []
      content {
        redirect_type        = url_redirect_action.value.redirect_type
        redirect_protocol    = url_redirect_action.value.redirect_protocol
        destination_hostname = url_redirect_action.value.destination_hostname
        destination_path     = url_redirect_action.value.destination_path
      }
    }
  }
}
```

- [ ] **Step 4: Add rule set output to outputs.tf**

Append after the `firewall_policy_id` output:

```hcl
output "rule_set_ids" {
  value       = { for k, v in azurerm_cdn_frontdoor_rule_set.this : k => v.id }
  description = "Map of rule set keys to their resource IDs"
}
```

- [ ] **Step 5: Validate**

```bash
cd modules/front-door && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 6: Commit**

```bash
git add modules/front-door/
git commit -m "front-door: add rule sets with conditions and actions"
```

---

### Task 4: Extend origins with Private Link

**Files:**
- Modify: `modules/front-door/variables.tf` (extend origins object type)
- Modify: `modules/front-door/main.tf` (add dynamic private_link block)

- [ ] **Step 1: Extend origins variable with private_link**

In `modules/front-door/variables.tf`, add `private_link` to the `origins` object type. The full updated variable:

```hcl
variable "origins" {
  type = map(object({
    origin_group_name              = string
    host_name                      = string
    origin_host_header             = optional(string)
    http_port                      = optional(number, 80)
    https_port                     = optional(number, 443)
    priority                       = optional(number, 1)
    weight                         = optional(number, 1000)
    certificate_name_check_enabled = optional(bool, true)
    enabled                        = optional(bool, true)
    private_link = optional(object({
      target_id       = string
      location        = string
      request_message = optional(string, "AFD Private Link connection")
    }))
  }))
  default     = {}
  description = "Map of origins. Each origin references an origin_group by key name. Optional private_link block for Private Link Service connectivity."
}
```

- [ ] **Step 2: Add private_link dynamic block to origin resource in main.tf**

In the `azurerm_cdn_frontdoor_origin.this` resource, add the dynamic block before the `lifecycle` block:

```hcl
  dynamic "private_link" {
    for_each = each.value.private_link != null ? [each.value.private_link] : []
    content {
      private_link_target_id = private_link.value.target_id
      location               = private_link.value.location
      request_message        = private_link.value.request_message
    }
  }
```

- [ ] **Step 3: Validate**

```bash
cd modules/front-door && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 4: Commit**

```bash
git add modules/front-door/
git commit -m "front-door: add Private Link support on origins"
```

---

### Task 5: Extend routes with rule set keys, custom domain keys, and compression

**Files:**
- Modify: `modules/front-door/variables.tf` (extend routes object type)
- Modify: `modules/front-door/main.tf` (update route resource)

- [ ] **Step 1: Extend routes variable**

Replace the `routes` variable with:

```hcl
variable "routes" {
  type = map(object({
    endpoint_name             = string
    origin_group_name         = string
    origin_names              = optional(list(string))
    patterns_to_match         = optional(list(string), ["/*"])
    supported_protocols       = optional(list(string), ["Http", "Https"])
    forwarding_protocol       = optional(string, "HttpsOnly")
    https_redirect_enabled    = optional(bool, true)
    link_to_default_domain    = optional(bool, true)
    enabled                   = optional(bool, true)
    rule_set_keys             = optional(list(string), [])
    custom_domain_keys        = optional(list(string), [])
    compression_enabled       = optional(bool, false)
    content_types_to_compress = optional(list(string), [])
  }))
  default     = {}
  description = "Map of routes. References endpoints, origin_groups, rule_sets, and custom_domains by key name."
}
```

- [ ] **Step 2: Update route resource in main.tf**

Add the new fields to the `azurerm_cdn_frontdoor_route.this` resource. The full updated resource:

```hcl
resource "azurerm_cdn_frontdoor_route" "this" {
  for_each = var.routes

  name                            = each.key
  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.this[each.value.endpoint_name].id
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.this[each.value.origin_group_name].id
  cdn_frontdoor_origin_ids        = each.value.origin_names != null ? [for name in each.value.origin_names : azurerm_cdn_frontdoor_origin.this[name].id] : [for k, v in azurerm_cdn_frontdoor_origin.this : v.id if var.origins[k].origin_group_name == each.value.origin_group_name]
  cdn_frontdoor_rule_set_ids      = [for k in each.value.rule_set_keys : azurerm_cdn_frontdoor_rule_set.this[k].id]
  cdn_frontdoor_custom_domain_ids = [for k in each.value.custom_domain_keys : azurerm_cdn_frontdoor_custom_domain.this[k].id]
  patterns_to_match               = each.value.patterns_to_match
  supported_protocols             = each.value.supported_protocols
  forwarding_protocol             = each.value.forwarding_protocol
  https_redirect_enabled          = each.value.https_redirect_enabled
  link_to_default_domain          = each.value.link_to_default_domain
  enabled                         = each.value.enabled

  dynamic "cache" {
    for_each = each.value.compression_enabled ? [1] : []
    content {
      compression_enabled           = true
      content_types_to_compress     = each.value.content_types_to_compress
      query_string_caching_behavior = "IgnoreQueryString"
    }
  }

  lifecycle {
    precondition {
      condition     = contains(keys(var.endpoints), each.value.endpoint_name)
      error_message = "Route '${each.key}' references endpoint_name '${each.value.endpoint_name}' which does not exist in endpoints."
    }

    precondition {
      condition     = contains(keys(var.origin_groups), each.value.origin_group_name)
      error_message = "Route '${each.key}' references origin_group_name '${each.value.origin_group_name}' which does not exist in origin_groups."
    }

    precondition {
      condition     = each.value.origin_names == null || alltrue([for name in coalesce(each.value.origin_names, []) : contains(keys(var.origins), name)])
      error_message = "Route '${each.key}' references origin_names that do not exist in origins."
    }

    precondition {
      condition     = alltrue([for k in each.value.rule_set_keys : contains(keys(var.rule_sets), k)])
      error_message = "Route '${each.key}' references rule_set_keys that do not exist in rule_sets."
    }

    precondition {
      condition     = alltrue([for k in each.value.custom_domain_keys : contains(keys(var.custom_domains), k)])
      error_message = "Route '${each.key}' references custom_domain_keys that do not exist in custom_domains."
    }
  }
}
```

- [ ] **Step 3: Validate**

```bash
cd modules/front-door && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 4: Commit**

```bash
git add modules/front-door/
git commit -m "front-door: extend routes with rule sets, custom domains, compression"
```

---

### Task 6: Add security policy resource

**Files:**
- Modify: `modules/front-door/main.tf`

- [ ] **Step 1: Add security policy resource to main.tf**

Append after the `azurerm_cdn_frontdoor_rule` resource:

```hcl
resource "azurerm_cdn_frontdoor_security_policy" "this" {
  count = var.waf != null ? 1 : 0

  name                     = "${var.name}-waf-sp"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.this[0].id

      association {
        patterns_to_match = ["/*"]

        dynamic "domain" {
          for_each = var.endpoints
          content {
            cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.this[domain.key].id
          }
        }

        dynamic "domain" {
          for_each = var.custom_domains
          content {
            cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.this[domain.key].id
          }
        }
      }
    }
  }

  depends_on = [azurerm_cdn_frontdoor_route.this]
}
```

- [ ] **Step 2: Validate**

```bash
cd modules/front-door && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 3: Commit**

```bash
git add modules/front-door/
git commit -m "front-door: add security policy binding WAF to all domains"
```

---

### Task 7: Update examples

**Files:**
- Modify: `modules/front-door/examples/complete/main.tf`

- [ ] **Step 1: Update complete example**

Read the current `modules/front-door/examples/complete/main.tf` and extend it to demonstrate all new features. Add:

```hcl
  custom_domains = {
    www = {
      hostname = "www.example.com"
    }
    api = {
      hostname         = "api.example.com"
      certificate_type = "ManagedCertificate"
    }
  }

  waf = {
    name = "wafexample"
    mode = "Detection"
    managed_rules = [
      {
        type    = "DefaultRuleSet"
        version = "1.0"
        action  = "Block"
      }
    ]
  }

  rule_sets = {
    ForwardHostHeader = {
      rules = {
        StripAcceptEncoding = {
          order = 1
          actions = {
            request_header_actions = [
              {
                header_action = "Delete"
                header_name   = "Accept-Encoding"
              }
            ]
          }
        }
      }
    }
  }
```

Update the route in the example to reference the new features:

```hcl
  routes = {
    default = {
      endpoint_name      = "example"
      origin_group_name  = "backend"
      rule_set_keys      = ["ForwardHostHeader"]
      custom_domain_keys = ["www", "api"]
    }
  }
```

**Note:** The complete example requires `sku_name = "Premium_AzureFrontDoor"` for WAF support.

- [ ] **Step 2: Validate example**

```bash
cd modules/front-door/examples/complete && terraform fmt -check && terraform init -backend=false && terraform validate
```

- [ ] **Step 3: Commit**

```bash
git add modules/front-door/examples/
git commit -m "front-door: update complete example with custom domains, WAF, rule sets"
```

---

### Task 8: CHANGELOG, README, final validation

**Files:**
- Modify: `modules/front-door/CHANGELOG.md`

- [ ] **Step 1: Update CHANGELOG.md**

Add after `## [Unreleased]`:

```markdown
## [1.1.0] - 2026-03-30

### Added

- Custom domains with managed TLS via `custom_domains` variable
- WAF firewall policy with managed rules via `waf` variable (custom rules deferred to v1.2.0)
- Rule sets with conditions and actions via `rule_sets` variable
- Private Link support on origins via optional `private_link` block in `origins` variable
- Route enhancements: `rule_set_keys`, `custom_domain_keys`, `compression_enabled`, `content_types_to_compress`
- Security policy resource binding WAF to all endpoints and custom domains
- New outputs: `custom_domain_ids`, `custom_domain_validation_tokens`, `firewall_policy_id`, `rule_set_ids`
```

- [ ] **Step 2: Regenerate README**

```bash
cd modules/front-door && terraform-docs markdown table --output-file README.md --output-mode inject .
```

- [ ] **Step 3: Final validation**

```bash
cd modules/front-door && terraform fmt -check && terraform init -backend=false && terraform validate
cd modules/front-door/examples/basic && terraform init -backend=false && terraform validate
cd modules/front-door/examples/complete && terraform init -backend=false && terraform validate
```

- [ ] **Step 4: Commit**

```bash
git add modules/front-door/
git commit -m "front-door v1.1.0: CHANGELOG, README, final validation"
```
