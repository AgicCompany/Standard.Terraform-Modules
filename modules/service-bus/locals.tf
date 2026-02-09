# locals.tf - Local values

locals {
  # Flatten topic subscriptions into a flat map for for_each
  # Key format: "topic_key/subscription_key"
  topic_subscriptions = merge([
    for topic_key, topic in var.topics : {
      for sub_key, sub in coalesce(topic.subscriptions, {}) :
      "${topic_key}/${sub_key}" => {
        topic_key                            = topic_key
        subscription_key                     = sub_key
        max_delivery_count                   = sub.max_delivery_count
        lock_duration                        = sub.lock_duration
        default_message_ttl                  = sub.default_message_ttl
        dead_lettering_on_message_expiration = sub.dead_lettering_on_message_expiration
        enable_batched_operations            = sub.enable_batched_operations
        requires_session                     = sub.requires_session
      }
    }
  ]...)
}
