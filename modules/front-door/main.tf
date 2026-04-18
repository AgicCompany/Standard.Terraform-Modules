resource "azurerm_cdn_frontdoor_profile" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  sku_name                 = var.sku_name
  response_timeout_seconds = var.response_timeout_seconds
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  for_each = var.endpoints

  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  enabled                  = each.value.enabled
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  for_each = var.origin_groups

  name                                                      = each.key
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.this.id
  session_affinity_enabled                                  = each.value.session_affinity_enabled
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = each.value.restore_traffic_time_to_healed_or_new_endpoint_in_minutes

  load_balancing {
    additional_latency_in_milliseconds = each.value.load_balancing.additional_latency_in_milliseconds
    sample_size                        = each.value.load_balancing.sample_size
    successful_samples_required        = each.value.load_balancing.successful_samples_required
  }

  dynamic "health_probe" {
    for_each = each.value.health_probe != null ? [each.value.health_probe] : []

    content {
      interval_in_seconds = health_probe.value.interval_in_seconds
      path                = health_probe.value.path
      protocol            = health_probe.value.protocol
      request_type        = health_probe.value.request_type
    }
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each = var.origins

  name                           = each.key
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this[each.value.origin_group_name].id
  host_name                      = each.value.host_name
  origin_host_header             = coalesce(each.value.origin_host_header, each.value.host_name)
  http_port                      = each.value.http_port
  https_port                     = each.value.https_port
  priority                       = each.value.priority
  weight                         = each.value.weight
  certificate_name_check_enabled = each.value.certificate_name_check_enabled
  enabled                        = each.value.enabled

  dynamic "private_link" {
    for_each = each.value.private_link != null ? [each.value.private_link] : []
    content {
      private_link_target_id = private_link.value.target_id
      location               = private_link.value.location
      target_type            = private_link.value.target_type
      request_message        = private_link.value.request_message
    }
  }

  lifecycle {
    precondition {
      condition     = contains(keys(var.origin_groups), each.value.origin_group_name)
      error_message = "Origin '${each.key}' references origin_group_name '${each.value.origin_group_name}' which does not exist in origin_groups."
    }
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  for_each = var.custom_domains

  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  host_name                = each.value.hostname

  tls {
    certificate_type = each.value.certificate_type
  }
}

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

data "azurerm_monitor_diagnostic_categories" "this" {
  count       = var.diagnostic_settings == null ? 0 : 1
  resource_id = azurerm_cdn_frontdoor_profile.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_cdn_frontdoor_profile.this.id

  log_analytics_workspace_id     = var.diagnostic_settings.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_settings.storage_account_id
  eventhub_authorization_rule_id = var.diagnostic_settings.eventhub_authorization_rule_id
  eventhub_name                  = var.diagnostic_settings.eventhub_name
  log_analytics_destination_type = var.diagnostic_settings.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = coalesce(
      var.diagnostic_settings.enabled_log_categories,
      try(data.azurerm_monitor_diagnostic_categories.this[0].log_category_types, [])
    )
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = coalesce(
      var.diagnostic_settings.enabled_metrics,
      try(data.azurerm_monitor_diagnostic_categories.this[0].metrics, [])
    )
    content {
      category = enabled_metric.value
    }
  }
}
