check "trigger_config_exactly_one" {
  assert {
    condition = length([
      for v in [var.event_trigger_config, var.manual_trigger_config, var.schedule_trigger_config]
      : v if v != null
    ]) == 1
    error_message = "Exactly one of event_trigger_config, manual_trigger_config, or schedule_trigger_config must be set."
  }
}

resource "azurerm_container_app_job" "with_lifecycle" {
  count = var.enable_secret_ignore_changes ? 1 : 0

  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  replica_timeout_in_seconds   = var.replica_timeout_in_seconds
  replica_retry_limit          = var.replica_retry_limit
  workload_profile_name        = var.workload_profile_name
  tags                         = var.tags

  dynamic "identity" {
    for_each = local.identity_type != null ? [1] : []
    content {
      type         = local.identity_type
      identity_ids = length(var.user_assigned_identity_ids) > 0 ? var.user_assigned_identity_ids : null
    }
  }

  dynamic "registry" {
    for_each = var.registries
    content {
      server               = registry.value.server
      identity             = registry.value.identity
      username             = registry.value.username
      password_secret_name = registry.value.password_secret_name
    }
  }

  dynamic "secret" {
    for_each = nonsensitive(var.secrets)
    content {
      name                = secret.key
      value               = secret.value.value
      key_vault_secret_id = secret.value.key_vault_secret_id
      identity            = secret.value.identity
    }
  }

  dynamic "event_trigger_config" {
    for_each = var.event_trigger_config != null ? [var.event_trigger_config] : []
    content {
      parallelism              = event_trigger_config.value.parallelism
      replica_completion_count = event_trigger_config.value.replica_completion_count

      dynamic "scale" {
        for_each = [event_trigger_config.value.scale]
        content {
          min_executions              = scale.value.min_executions
          max_executions              = scale.value.max_executions
          polling_interval_in_seconds = scale.value.polling_interval_in_seconds

          dynamic "rules" {
            for_each = scale.value.rules
            content {
              name             = rules.value.name
              custom_rule_type = rules.value.custom_rule_type
              identity_id      = rules.value.identity_id
              metadata         = rules.value.metadata

              dynamic "authentication" {
                for_each = rules.value.authentication
                content {
                  secret_name       = authentication.value.secret_name
                  trigger_parameter = authentication.value.trigger_parameter
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "manual_trigger_config" {
    for_each = var.manual_trigger_config != null ? [var.manual_trigger_config] : []
    content {
      parallelism              = manual_trigger_config.value.parallelism
      replica_completion_count = manual_trigger_config.value.replica_completion_count
    }
  }

  dynamic "schedule_trigger_config" {
    for_each = var.schedule_trigger_config != null ? [var.schedule_trigger_config] : []
    content {
      cron_expression          = schedule_trigger_config.value.cron_expression
      parallelism              = schedule_trigger_config.value.parallelism
      replica_completion_count = schedule_trigger_config.value.replica_completion_count
    }
  }

  template {
    container {
      name    = local.container_name
      image   = var.container.image
      cpu     = var.container.cpu
      memory  = var.container.memory
      command = var.container.command
      args    = var.container.args

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
          for_each = init_container.value.env
          content {
            name        = env.key
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [secret]
  }
}

resource "azurerm_container_app_job" "without_lifecycle" {
  count = var.enable_secret_ignore_changes ? 0 : 1

  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  replica_timeout_in_seconds   = var.replica_timeout_in_seconds
  replica_retry_limit          = var.replica_retry_limit
  workload_profile_name        = var.workload_profile_name
  tags                         = var.tags

  dynamic "identity" {
    for_each = local.identity_type != null ? [1] : []
    content {
      type         = local.identity_type
      identity_ids = length(var.user_assigned_identity_ids) > 0 ? var.user_assigned_identity_ids : null
    }
  }

  dynamic "registry" {
    for_each = var.registries
    content {
      server               = registry.value.server
      identity             = registry.value.identity
      username             = registry.value.username
      password_secret_name = registry.value.password_secret_name
    }
  }

  dynamic "secret" {
    for_each = nonsensitive(var.secrets)
    content {
      name                = secret.key
      value               = secret.value.value
      key_vault_secret_id = secret.value.key_vault_secret_id
      identity            = secret.value.identity
    }
  }

  dynamic "event_trigger_config" {
    for_each = var.event_trigger_config != null ? [var.event_trigger_config] : []
    content {
      parallelism              = event_trigger_config.value.parallelism
      replica_completion_count = event_trigger_config.value.replica_completion_count

      dynamic "scale" {
        for_each = [event_trigger_config.value.scale]
        content {
          min_executions              = scale.value.min_executions
          max_executions              = scale.value.max_executions
          polling_interval_in_seconds = scale.value.polling_interval_in_seconds

          dynamic "rules" {
            for_each = scale.value.rules
            content {
              name             = rules.value.name
              custom_rule_type = rules.value.custom_rule_type
              identity_id      = rules.value.identity_id
              metadata         = rules.value.metadata

              dynamic "authentication" {
                for_each = rules.value.authentication
                content {
                  secret_name       = authentication.value.secret_name
                  trigger_parameter = authentication.value.trigger_parameter
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "manual_trigger_config" {
    for_each = var.manual_trigger_config != null ? [var.manual_trigger_config] : []
    content {
      parallelism              = manual_trigger_config.value.parallelism
      replica_completion_count = manual_trigger_config.value.replica_completion_count
    }
  }

  dynamic "schedule_trigger_config" {
    for_each = var.schedule_trigger_config != null ? [var.schedule_trigger_config] : []
    content {
      cron_expression          = schedule_trigger_config.value.cron_expression
      parallelism              = schedule_trigger_config.value.parallelism
      replica_completion_count = schedule_trigger_config.value.replica_completion_count
    }
  }

  template {
    container {
      name    = local.container_name
      image   = var.container.image
      cpu     = var.container.cpu
      memory  = var.container.memory
      command = var.container.command
      args    = var.container.args

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
          for_each = init_container.value.env
          content {
            name        = env.key
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }
      }
    }
  }
}
