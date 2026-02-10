# locals.tf - Local values

locals {
  consumer_groups = merge([
    for hub_key, hub in var.event_hubs : {
      for cg_key, cg in coalesce(hub.consumer_groups, {}) :
      "${hub_key}/${cg_key}" => {
        eventhub_key  = hub_key
        name          = cg_key
        user_metadata = cg.user_metadata
      }
    }
  ]...)
}
