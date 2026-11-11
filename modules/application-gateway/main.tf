resource "azurerm_public_ip" "this" {
  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
  zones             = var.zones

  tags = var.tags
}

resource "azurerm_web_application_firewall_policy" "this" {
  count = var.waf_policy != null && var.firewall_policy_id == null ? 1 : 0

  name                = coalesce(var.waf_policy.name, "wafpol-${var.name}")
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled                     = true
    mode                        = var.waf_policy.mode
    request_body_check          = var.waf_policy.request_body_check
    file_upload_limit_in_mb     = var.waf_policy.file_upload_limit_in_mb
    max_request_body_size_in_kb = var.waf_policy.max_request_body_size_in_kb
  }

  managed_rules {
    managed_rule_set {
      type    = var.waf_policy.rule_set_type
      version = var.waf_policy.rule_set_version
    }
  }

  tags = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  enable_http2       = var.enable_http2
  zones              = var.zones
  firewall_policy_id = var.firewall_policy_id != null ? var.firewall_policy_id : try(azurerm_web_application_firewall_policy.this[0].id, null)

  dynamic "identity" {
    for_each = length(var.user_assigned_identity_ids) > 0 ? [1] : []

    content {
      type         = "UserAssigned"
      identity_ids = var.user_assigned_identity_ids
    }
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.ssl_policy_name
  }

  sku {
    name = var.sku_name
    tier = var.sku_tier
  }

  autoscale_configuration {
    min_capacity = var.autoscale.min_capacity
    max_capacity = var.autoscale.max_capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.this.id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.private_frontend_ip_configuration != null ? [var.private_frontend_ip_configuration] : []

    content {
      name                          = local.private_frontend_ip_configuration_name
      subnet_id                     = coalesce(frontend_ip_configuration.value.subnet_id, var.subnet_id)
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
    }
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports

    content {
      name = frontend_port.key
      port = frontend_port.value.port
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools

    content {
      name         = backend_address_pool.key
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings

    content {
      name                                = backend_http_settings.key
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      request_timeout                     = backend_http_settings.value.request_timeout
      probe_name                          = backend_http_settings.value.probe_name
      host_name                           = backend_http_settings.value.pick_host_name_from_backend_http_settings ? null : backend_http_settings.value.host_name
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_http_settings
      path                                = backend_http_settings.value.path
      trusted_root_certificate_names = (
        length(backend_http_settings.value.trusted_root_certificate_names) > 0
        ? backend_http_settings.value.trusted_root_certificate_names
        : null
      )
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners

    content {
      name = http_listener.key
      frontend_ip_configuration_name = (
        http_listener.value.use_private_frontend
        ? local.private_frontend_ip_configuration_name
        : local.frontend_ip_configuration_name
      )
      frontend_port_name   = http_listener.value.frontend_port_name
      protocol             = http_listener.value.protocol
      host_name            = http_listener.value.host_name
      host_names           = http_listener.value.host_names
      ssl_certificate_name = http_listener.value.ssl_certificate_name
      firewall_policy_id   = http_listener.value.firewall_policy_id
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules

    content {
      name                        = request_routing_rule.key
      rule_type                   = request_routing_rule.value.rule_type
      priority                    = request_routing_rule.value.priority
      http_listener_name          = request_routing_rule.value.http_listener_name
      backend_address_pool_name   = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name  = request_routing_rule.value.backend_http_settings_name
      url_path_map_name           = request_routing_rule.value.url_path_map_name
      redirect_configuration_name = request_routing_rule.value.redirect_configuration_name
    }
  }

  dynamic "probe" {
    for_each = var.probes

    content {
      name                                      = probe.key
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      host                                      = probe.value.pick_host_name_from_backend_http_settings ? null : probe.value.host
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      minimum_servers                           = probe.value.minimum_servers

      match {
        status_code = probe.value.match_status_codes
      }
    }
  }

  dynamic "ssl_certificate" {
    for_each = nonsensitive(var.ssl_certificates)

    content {
      name                = ssl_certificate.key
      data                = ssl_certificate.value.data
      password            = ssl_certificate.value.password
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificates

    content {
      name                = trusted_root_certificate.key
      data                = trusted_root_certificate.value.data
      key_vault_secret_id = trusted_root_certificate.value.key_vault_secret_id
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.redirect_configurations

    content {
      name                 = redirect_configuration.key
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener_name
      target_url           = redirect_configuration.value.target_url
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }

  dynamic "url_path_map" {
    for_each = var.url_path_maps

    content {
      name                                = url_path_map.key
      default_backend_address_pool_name   = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name  = url_path_map.value.default_backend_http_settings_name
      default_redirect_configuration_name = url_path_map.value.default_redirect_configuration_name

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rules

        content {
          name                        = path_rule.key
          paths                       = path_rule.value.paths
          backend_address_pool_name   = path_rule.value.backend_address_pool_name
          backend_http_settings_name  = path_rule.value.backend_http_settings_name
          redirect_configuration_name = path_rule.value.redirect_configuration_name
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.sku_name == var.sku_tier
      error_message = "sku_name and sku_tier must match (e.g., both \"Standard_v2\" or both \"WAF_v2\")."
    }

    precondition {
      condition = alltrue([
        for rule in values(var.request_routing_rules) :
        contains(keys(var.http_listeners), rule.http_listener_name)
      ])
      error_message = "All request_routing_rules must reference an http_listener_name that exists in http_listeners."
    }

    precondition {
      condition = alltrue([
        for rule in values(var.request_routing_rules) :
        rule.backend_address_pool_name == null ? true : contains(keys(var.backend_address_pools), rule.backend_address_pool_name)
      ])
      error_message = "All request_routing_rules must reference a backend_address_pool_name that exists in backend_address_pools (or be null)."
    }

    precondition {
      condition = alltrue([
        for rule in values(var.request_routing_rules) :
        rule.backend_http_settings_name == null ? true : contains(keys(var.backend_http_settings), rule.backend_http_settings_name)
      ])
      error_message = "All request_routing_rules must reference a backend_http_settings_name that exists in backend_http_settings (or be null)."
    }

    precondition {
      condition = (
        !anytrue([for l in values(var.http_listeners) : l.use_private_frontend]) ? true
        : var.private_frontend_ip_configuration != null
      )
      error_message = "private_frontend_ip_configuration is required when any http_listener sets use_private_frontend = true."
    }

    precondition {
      condition = (
        !anytrue([for c in values(nonsensitive(var.ssl_certificates)) : c.key_vault_secret_id != null]) ? true
        : length(var.user_assigned_identity_ids) > 0
      )
      error_message = "user_assigned_identity_ids must contain at least one User-Assigned Managed Identity ID when any ssl_certificate uses key_vault_secret_id."
    }

    precondition {
      condition = (
        var.sku_tier != "WAF_v2" ? true
        : (var.firewall_policy_id != null ? true : var.waf_policy != null)
      )
      error_message = "WAF_v2 SKU requires either firewall_policy_id or waf_policy to be configured."
    }

    precondition {
      condition = (
        !anytrue([for c in values(var.trusted_root_certificates) : c.key_vault_secret_id != null]) ? true
        : length(var.user_assigned_identity_ids) > 0
      )
      error_message = "user_assigned_identity_ids must include at least one identity when any trusted_root_certificates entry sets key_vault_secret_id."
    }

    precondition {
      condition = alltrue(flatten([
        for s in values(var.backend_http_settings) : [
          for cert_name in coalesce(s.trusted_root_certificate_names, []) :
          contains(keys(var.trusted_root_certificates), cert_name)
        ]
      ]))
      error_message = "All backend_http_settings.trusted_root_certificate_names must reference keys defined in trusted_root_certificates."
    }
  }
}


resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_application_gateway.this.id

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
