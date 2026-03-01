resource "azurerm_container_app" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = var.revision_mode
  workload_profile_name        = var.workload_profile_name

  template {
    min_replicas = try(var.scale.min_replicas, 0)
    max_replicas = try(var.scale.max_replicas, 10)

    container {
      name   = local.container_name
      image  = var.container.image
      cpu    = var.container.cpu
      memory = var.container.memory

      dynamic "env" {
        for_each = var.container.env

        content {
          name        = env.key
          value       = env.value.value
          secret_name = env.value.secret_name
        }
      }

      dynamic "liveness_probe" {
        for_each = var.container.liveness_probe != null ? [var.container.liveness_probe] : []

        content {
          transport               = liveness_probe.value.transport
          port                    = liveness_probe.value.port
          path                    = liveness_probe.value.path
          initial_delay           = liveness_probe.value.initial_delay
          interval_seconds        = liveness_probe.value.interval_seconds
          failure_count_threshold = liveness_probe.value.failure_count_threshold
        }
      }

      dynamic "readiness_probe" {
        for_each = var.container.readiness_probe != null ? [var.container.readiness_probe] : []

        content {
          transport               = readiness_probe.value.transport
          port                    = readiness_probe.value.port
          path                    = readiness_probe.value.path
          initial_delay           = readiness_probe.value.initial_delay
          interval_seconds        = readiness_probe.value.interval_seconds
          failure_count_threshold = readiness_probe.value.failure_count_threshold
        }
      }

      dynamic "startup_probe" {
        for_each = var.container.startup_probe != null ? [var.container.startup_probe] : []

        content {
          transport               = startup_probe.value.transport
          port                    = startup_probe.value.port
          path                    = startup_probe.value.path
          initial_delay           = startup_probe.value.initial_delay
          interval_seconds        = startup_probe.value.interval_seconds
          failure_count_threshold = startup_probe.value.failure_count_threshold
        }
      }
    }

    dynamic "init_container" {
      for_each = var.init_containers

      content {
        name    = init_container.value.name
        image   = init_container.value.image
        cpu     = init_container.value.cpu
        memory  = init_container.value.memory
        command = init_container.value.command
        args    = init_container.value.args

        dynamic "env" {
          for_each = init_container.value.env != null ? init_container.value.env : {}

          content {
            name        = env.key
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }
      }
    }

    dynamic "http_scale_rule" {
      for_each = [for r in try(var.scale.rules, []) : r if r.http_scale_rule != null]

      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.http_scale_rule.concurrent_requests
      }
    }
  }

  # Ingress
  dynamic "ingress" {
    for_each = var.enable_ingress && var.ingress != null ? [var.ingress] : []

    content {
      target_port      = ingress.value.target_port
      transport        = ingress.value.transport
      external_enabled = var.enable_external_ingress

      traffic_weight {
        latest_revision = try(ingress.value.traffic_weight.latest_revision, true)
        percentage      = try(ingress.value.traffic_weight.percentage, 100)
      }
    }
  }

  # Secrets
  dynamic "secret" {
    for_each = var.secrets

    content {
      name  = secret.key
      value = secret.value
    }
  }

  # Identity
  dynamic "identity" {
    for_each = local.identity_type != null ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = length(var.user_assigned_identity_ids) > 0 ? var.user_assigned_identity_ids : null
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition = alltrue([
        for name, env in var.container.env :
        !(env.value != null && env.secret_name != null)
      ])
      error_message = "Container env variables must set either 'value' or 'secret_name', not both."
    }
  }
}
