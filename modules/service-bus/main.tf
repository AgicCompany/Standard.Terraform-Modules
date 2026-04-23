resource "azurerm_servicebus_namespace" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  capacity                      = var.sku == "Premium" ? var.capacity : 0
  minimum_tls_version           = var.min_tls_version
  local_auth_enabled            = var.enable_local_auth
  public_network_access_enabled = var.enable_public_access
  premium_messaging_partitions  = var.sku == "Premium" ? min(4, var.capacity > 0 ? var.capacity : 1) : 0
  tags                          = var.tags

  lifecycle {
    precondition {
      condition     = var.sku != "Premium" || var.capacity > 0
      error_message = "capacity must be greater than 0 for Premium SKU. Valid values: 1, 2, 4, 8, 16."
    }

    precondition {
      condition     = length(var.topics) == 0 || var.sku != "Basic"
      error_message = "Topics require Standard or Premium SKU. Set sku to \"Standard\" or \"Premium\", or remove topics."
    }
  }
}

resource "azurerm_servicebus_queue" "this" {
  for_each = var.queues

  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id

  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  default_message_ttl                     = each.value.default_message_ttl
  lock_duration                           = each.value.lock_duration
  max_delivery_count                      = each.value.max_delivery_count
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  partitioning_enabled                    = each.value.enable_partitioning
  batched_operations_enabled              = each.value.enable_batched_operations
  requires_session                        = each.value.requires_session
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
}

resource "azurerm_servicebus_topic" "this" {
  for_each = var.topics

  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id

  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  default_message_ttl                     = each.value.default_message_ttl
  partitioning_enabled                    = each.value.enable_partitioning
  batched_operations_enabled              = each.value.enable_batched_operations
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
}

resource "azurerm_servicebus_subscription" "this" {
  for_each = local.topic_subscriptions

  name     = each.value.subscription_key
  topic_id = azurerm_servicebus_topic.this[each.value.topic_key].id

  max_delivery_count                   = each.value.max_delivery_count
  lock_duration                        = each.value.lock_duration
  default_message_ttl                  = each.value.default_message_ttl
  dead_lettering_on_message_expiration = each.value.dead_lettering_on_message_expiration
  batched_operations_enabled           = each.value.enable_batched_operations
  requires_session                     = each.value.requires_session
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                          = coalesce(var.private_endpoint_name, "pep-${var.name}")
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_id
  custom_network_interface_name = coalesce(var.private_endpoint_nic_name, "pep-${var.name}-nic")

  private_service_connection {
    name                           = coalesce(var.private_service_connection_name, "psc-${var.name}")
    private_connection_resource_id = azurerm_servicebus_namespace.this.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = var.tags
}
