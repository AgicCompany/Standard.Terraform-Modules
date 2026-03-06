# container-app

**Complexity:** High

Creates an Azure Container App in an existing Container Apps Environment.

## Usage

```hcl
module "container_app" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//container-app?ref=container-app/v1.1.0"

  resource_group_name          = "rg-ca-dev-weu-001"
  name                         = "ca-payments-api-dev-weu-001"
  container_app_environment_id = module.cae.id

  container = {
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }

  ingress = {
    target_port = 80
  }

  tags = local.common_tags
}
```

## Non-Standard Interface

This module does **not** include a `location` variable. Container Apps inherit their location from the Container Apps Environment.

## Features

- Single container template with configurable image, CPU, memory
- HTTP/TCP ingress with external/internal toggle
- Environment variables (plain text and secret references)
- Secrets management
- System-assigned and user-assigned managed identity
- Revision mode (Single or Multiple)
- Scale rules (min/max replicas, HTTP concurrent requests)
- Init containers
- Liveness, readiness, and startup probes

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| External ingress | Disabled | `enable_external_ingress` |

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_container_app_id` | Container App resource ID |
| `public_container_app_name` | Container App name |
| `public_container_app_fqdn` | Latest revision FQDN |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container"></a> [container](#input\_container) | Main container configuration | <pre>object({<br/>    image  = string<br/>    cpu    = number<br/>    memory = string<br/>    env = optional(map(object({<br/>      value       = optional(string)<br/>      secret_name = optional(string)<br/>    })), {})<br/>    liveness_probe = optional(object({<br/>      transport               = string<br/>      port                    = number<br/>      path                    = optional(string)<br/>      initial_delay           = optional(number, 1)<br/>      interval_seconds        = optional(number, 10)<br/>      failure_count_threshold = optional(number, 3)<br/>    }))<br/>    readiness_probe = optional(object({<br/>      transport               = string<br/>      port                    = number<br/>      path                    = optional(string)<br/>      initial_delay           = optional(number, 1)<br/>      interval_seconds        = optional(number, 10)<br/>      failure_count_threshold = optional(number, 3)<br/>    }))<br/>    startup_probe = optional(object({<br/>      transport               = string<br/>      port                    = number<br/>      path                    = optional(string)<br/>      initial_delay           = optional(number, 1)<br/>      interval_seconds        = optional(number, 10)<br/>      failure_count_threshold = optional(number, 3)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id) | Container Apps Environment ID | `string` | n/a | yes |
| <a name="input_enable_external_ingress"></a> [enable\_external\_ingress](#input\_enable\_external\_ingress) | Allow ingress from outside the Container Apps Environment | `bool` | `false` | no |
| <a name="input_enable_ingress"></a> [enable\_ingress](#input\_enable\_ingress) | Enable HTTP/TCP ingress. Requires ingress variable to be set. | `bool` | `false` | no |
| <a name="input_enable_system_assigned_identity"></a> [enable\_system\_assigned\_identity](#input\_enable\_system\_assigned\_identity) | Enable system-assigned managed identity | `bool` | `false` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Ingress configuration. Only used when enable\_ingress = true. | <pre>object({<br/>    target_port = number<br/>    transport   = optional(string, "auto")<br/>    traffic_weight = optional(object({<br/>      latest_revision = optional(bool, true)<br/>      percentage      = optional(number, 100)<br/>    }), {})<br/>  })</pre> | `null` | no |
| <a name="input_init_containers"></a> [init\_containers](#input\_init\_containers) | Init containers to run before the main container | <pre>list(object({<br/>    image  = string<br/>    name   = string<br/>    cpu    = optional(number)<br/>    memory = optional(string)<br/>    env = optional(map(object({<br/>      value       = optional(string)<br/>      secret_name = optional(string)<br/>    })), {})<br/>    command = optional(list(string))<br/>    args    = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Container App name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_revision_mode"></a> [revision\_mode](#input\_revision\_mode) | Revision mode: Single or Multiple | `string` | `"Single"` | no |
| <a name="input_scale"></a> [scale](#input\_scale) | Scale configuration. Defaults to 0-10 replicas. | <pre>object({<br/>    min_replicas = optional(number, 0)<br/>    max_replicas = optional(number, 10)<br/>    rules = optional(list(object({<br/>      name = string<br/>      http_scale_rule = optional(object({<br/>        concurrent_requests = string<br/>      }))<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets. Key = secret name, value = secret value. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | User Assigned Identity IDs | `list(string)` | `[]` | no |
| <a name="input_workload_profile_name"></a> [workload\_profile\_name](#input\_workload\_profile\_name) | Workload profile name from the environment. null = Consumption. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Container App resource ID |
| <a name="output_latest_revision_fqdn"></a> [latest\_revision\_fqdn](#output\_latest\_revision\_fqdn) | FQDN of the latest revision |
| <a name="output_latest_revision_name"></a> [latest\_revision\_name](#output\_latest\_revision\_name) | Name of the latest revision |
| <a name="output_name"></a> [name](#output\_name) | Container App name |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | Outbound IP addresses |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID (when enabled) |
| <a name="output_public_container_app_fqdn"></a> [public\_container\_app\_fqdn](#output\_public\_container\_app\_fqdn) | Latest revision FQDN (for cross-project consumption) |
| <a name="output_public_container_app_id"></a> [public\_container\_app\_id](#output\_public\_container\_app\_id) | Container App resource ID (for cross-project consumption) |
| <a name="output_public_container_app_name"></a> [public\_container\_app\_name](#output\_public\_container\_app\_name) | Container App name (for cross-project consumption) |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned managed identity tenant ID (when enabled) |
<!-- END_TF_DOCS -->

## Notes

- **No `location` variable:** Container Apps inherit their location from the Container Apps Environment. The `location` standard interface variable is not included in this module. This is a documented deviation from the standard interface.
- **Container name:** The container name within the template is derived from the module's `name` variable (sanitized for container naming rules). Consumers don't need to specify it separately.
- **CPU/memory combinations:** On Consumption plans, CPU and memory must match specific combinations (e.g., 0.25 CPU / 0.5Gi, 0.5 CPU / 1Gi, etc.). On dedicated workload profiles, these constraints are relaxed. The module does not validate combinations -- Azure rejects invalid ones.
- **Secrets handling:** Secrets are passed as `map(string)` and stored in the container app. For Key Vault references, use the `identity` + `key_vault_secret_id` pattern in environment variables. This is a future enhancement.
- **Scale to zero:** Default `min_replicas = 0` allows scale to zero on Consumption plans. Set `min_replicas = 1` to keep at least one instance running (useful for reducing cold starts).
- **Naming:** CAF prefix for Container Apps is `ca`. Example: `ca-payments-api-dev-weu-001`.
- **Revision mode:** `Single` is simpler -- only one revision is active. `Multiple` enables traffic splitting and blue/green deployments but requires more management. Default to `Single`.
- **Ingress transport:** Valid values are `auto`, `http`, `http2`, `tcp`. Default is `auto`.
