# container-app-job

Terraform module for Azure Container App Jobs (`azurerm_container_app_job`).

Supports event-driven (KEDA), manual, and schedule (cron) trigger types. Secrets support
both plain values and Azure Key Vault references. Private registry authentication via managed
identity or username/password.

## Usage

```hcl
module "container_app_job" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/container-app-job?ref=container-app-job/v1.0.0"

  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  name                         = "caj-example-runner-dev"
  container_app_environment_id = azurerm_container_app_environment.example.id
  replica_timeout_in_seconds   = 3600

  container = {
    image  = "myacr.azurecr.io/myimage:latest"
    cpu    = 1.0
    memory = "2Gi"
  }

  event_trigger_config = {
    scale = {
      max_executions = 5
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_job.with_lifecycle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_job) | resource |
| [azurerm_container_app_job.without_lifecycle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_job) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container"></a> [container](#input\_container) | Main container configuration | <pre>object({<br/>    image  = string<br/>    cpu    = number<br/>    memory = string<br/>    env = optional(map(object({<br/>      value       = optional(string)<br/>      secret_name = optional(string)<br/>    })), {})<br/>    command = optional(list(string))<br/>    args    = optional(list(string))<br/>    liveness_probe = optional(object({<br/>      transport               = string<br/>      port                    = number<br/>      path                    = optional(string)<br/>      initial_delay           = optional(number, 1)<br/>      interval_seconds        = optional(number, 10)<br/>      failure_count_threshold = optional(number, 3)<br/>    }))<br/>    readiness_probe = optional(object({<br/>      transport               = string<br/>      port                    = number<br/>      path                    = optional(string)<br/>      initial_delay           = optional(number, 1)<br/>      interval_seconds        = optional(number, 10)<br/>      failure_count_threshold = optional(number, 3)<br/>    }))<br/>    startup_probe = optional(object({<br/>      transport               = string<br/>      port                    = number<br/>      path                    = optional(string)<br/>      initial_delay           = optional(number, 1)<br/>      interval_seconds        = optional(number, 10)<br/>      failure_count_threshold = optional(number, 3)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id) | Container Apps Environment ID | `string` | n/a | yes |
| <a name="input_enable_secret_ignore_changes"></a> [enable\_secret\_ignore\_changes](#input\_enable\_secret\_ignore\_changes) | When true, Terraform ignores changes to the secret block after initial creation. Recommended for secrets rotated outside Terraform. WARNING: toggling this value after initial deployment will destroy and recreate the job resource. | `bool` | `true` | no |
| <a name="input_enable_system_assigned_identity"></a> [enable\_system\_assigned\_identity](#input\_enable\_system\_assigned\_identity) | Enable system-assigned managed identity. | `bool` | `false` | no |
| <a name="input_event_trigger_config"></a> [event\_trigger\_config](#input\_event\_trigger\_config) | Event-driven trigger configuration (KEDA). Exactly one trigger type must be set. | <pre>object({<br/>    parallelism              = optional(number, 1)<br/>    replica_completion_count = optional(number, 1)<br/>    scale = optional(object({<br/>      min_executions              = optional(number, 0)<br/>      max_executions              = optional(number, 10)<br/>      polling_interval_in_seconds = optional(number, 30)<br/>      rules = optional(list(object({<br/>        name             = string<br/>        custom_rule_type = string<br/>        identity_id      = optional(string)<br/>        metadata         = map(string)<br/>        authentication = optional(list(object({<br/>          secret_name       = string<br/>          trigger_parameter = string<br/>        })), [])<br/>      })), [])<br/>    }), {})<br/>  })</pre> | `null` | no |
| <a name="input_init_containers"></a> [init\_containers](#input\_init\_containers) | Init containers to run before the main container. | <pre>list(object({<br/>    image   = string<br/>    name    = string<br/>    cpu     = optional(number)<br/>    memory  = optional(string)<br/>    command = optional(list(string))<br/>    args    = optional(list(string))<br/>    env = optional(map(object({<br/>      value       = optional(string)<br/>      secret_name = optional(string)<br/>    })), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_manual_trigger_config"></a> [manual\_trigger\_config](#input\_manual\_trigger\_config) | Manual trigger configuration. Exactly one trigger type must be set. | <pre>object({<br/>    parallelism              = optional(number, 1)<br/>    replica_completion_count = optional(number, 1)<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Container App Job name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_registries"></a> [registries](#input\_registries) | Private registry authentication. Each entry requires either 'identity' (resource ID of a user-assigned managed identity) or both 'username' and 'password\_secret\_name'. The identity should be listed in user\_assigned\_identity\_ids; Azure will reject the deployment if it is not. | <pre>list(object({<br/>    server               = string<br/>    identity             = optional(string)<br/>    username             = optional(string)<br/>    password_secret_name = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_replica_retry_limit"></a> [replica\_retry\_limit](#input\_replica\_retry\_limit) | Maximum number of retries before a replica is considered failed. null = provider default. | `number` | `null` | no |
| <a name="input_replica_timeout_in_seconds"></a> [replica\_timeout\_in\_seconds](#input\_replica\_timeout\_in\_seconds) | Maximum number of seconds a replica is allowed to run. Required by the provider. | `number` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_schedule_trigger_config"></a> [schedule\_trigger\_config](#input\_schedule\_trigger\_config) | Schedule (cron) trigger configuration. Exactly one trigger type must be set. | <pre>object({<br/>    cron_expression          = string<br/>    parallelism              = optional(number, 1)<br/>    replica_completion_count = optional(number, 1)<br/>  })</pre> | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets map. Key = secret name. Each entry uses either 'value' (plain string) or 'key\_vault\_secret\_id' (Key Vault reference, optionally with 'identity' for the managed identity to use). | <pre>map(object({<br/>    value               = optional(string)<br/>    key_vault_secret_id = optional(string)<br/>    identity            = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource. | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | User Assigned Identity resource IDs to attach to the job. | `list(string)` | `[]` | no |
| <a name="input_workload_profile_name"></a> [workload\_profile\_name](#input\_workload\_profile\_name) | Workload profile name from the environment. null = Consumption. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_event_stream_endpoint"></a> [event\_stream\_endpoint](#output\_event\_stream\_endpoint) | Event stream endpoint for log streaming |
| <a name="output_id"></a> [id](#output\_id) | Container App Job resource ID |
| <a name="output_name"></a> [name](#output\_name) | Container App Job name |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | Outbound IP addresses of the Container App Job |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID (when enabled) |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned managed identity tenant ID (when enabled) |
<!-- END_TF_DOCS -->
