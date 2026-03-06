# action-group

**Complexity:** Low

Creates an Azure Monitor Action Group for alert notification delivery via email, SMS, webhooks, and push notifications.

## Usage

```hcl
module "action_group" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//action-group?ref=action-group/v1.0.0"

  resource_group_name = azurerm_resource_group.example.name
  name                = "ag-platform-dev-weu-001"
  short_name          = "ag-platform"

  email_receivers = {
    platform-team = {
      email_address = "platform@company.com"
    }
  }

  tags = {
    project     = "platform"
    environment = "dev"
  }
}
```

## Features

- Email, SMS, webhook, and Azure app push receivers
- Common alert schema support (enabled by default for email and webhooks)
- AAD authentication for webhook receivers
- Receiver names derived from map keys

## Security Defaults

- Common alert schema enabled by default (standardized notification format)
- Action group enabled by default

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_action_group_id` | Action group resource ID (for cross-project consumption) |

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_action_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_app_push_receivers"></a> [azure\_app\_push\_receivers](#input\_azure\_app\_push\_receivers) | Map of Azure app push receivers. Key is used as the receiver name. | <pre>map(object({<br/>    email_address = string<br/>  }))</pre> | `{}` | no |
| <a name="input_email_receivers"></a> [email\_receivers](#input\_email\_receivers) | Map of email receivers. Key is used as the receiver name. | <pre>map(object({<br/>    email_address           = string<br/>    use_common_alert_schema = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the action group is enabled | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Action group name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_short_name"></a> [short\_name](#input\_short\_name) | Action group short name (max 12 characters, shown in SMS/email) | `string` | n/a | yes |
| <a name="input_sms_receivers"></a> [sms\_receivers](#input\_sms\_receivers) | Map of SMS receivers. Key is used as the receiver name. | <pre>map(object({<br/>    country_code = string<br/>    phone_number = string<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_webhook_receivers"></a> [webhook\_receivers](#input\_webhook\_receivers) | Map of webhook receivers. Key is used as the receiver name. | <pre>map(object({<br/>    service_uri             = string<br/>    use_common_alert_schema = optional(bool, true)<br/>    aad_auth = optional(object({<br/>      object_id = string<br/>      tenant_id = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Action group resource ID |
| <a name="output_name"></a> [name](#output\_name) | Action group name |
| <a name="output_public_action_group_id"></a> [public\_action\_group\_id](#output\_public\_action\_group\_id) | Action group resource ID (for cross-project consumption) |
<!-- END_TF_DOCS -->

## Notes

- **No location:** Action groups are global Azure resources. No `location` variable is needed.
- **Short name limit:** The `short_name` is limited to 12 characters and appears in SMS notifications and email subject lines.
- **Common alert schema:** When enabled, all alerts use a standardized JSON payload. Recommended for webhook integrations.
- **Rate limiting:** Azure applies rate limiting to action group notifications. See Azure Monitor documentation for current limits.
