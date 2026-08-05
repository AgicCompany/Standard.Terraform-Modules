# communication-service-email

Provisions an Azure Communication Service plus an Email Communication Service, a single Email Domain (Azure-managed by default, customer-managed when `enable_custom_domain = true`), an arbitrary set of sender usernames, and the association between communication service and domain.

## Conventions deviating from the typical module

- `location` is required (module convention) but **not passed to the resources**. Neither `azurerm_communication_service` nor `azurerm_email_communication_service` accepts a `location` argument — Azure deploys them globally. The variable is kept on the module so consumers' standard `module "x" { location = local.location, ... }` pattern works unchanged.
- The module does not expose a private endpoint — AzureRM 4.x has no first-class private-endpoint support for Communication Services.
- The module does not export `primary_connection_string`. Use `data "azurerm_communication_service"` in the consumer if you need it, and write the result to Key Vault rather than to a Terraform output.

## Custom domain workflow

When `enable_custom_domain = true`, set `domain_name = "<your verified domain>"` (e.g. `mail.example.com`). After the first apply, Azure surfaces five DNS verification records (`domain` TXT, `spf` TXT, `dkim` TXT/CNAME, `dkim2` TXT/CNAME, `dmarc` TXT). The module exposes them as the `verification_records` output. Provision them at your DNS registrar, then re-apply to advance verification. The records also exist on the Azure-managed flow but are auto-managed and rarely needed.

## ForceNew foot-guns

- `data_location` on both the communication service and the email service is ForceNew. Changing it destroys and recreates both, which also recreates the domain and senders.
- `name` on `azurerm_email_communication_service_domain_sender_username` is ForceNew. The map keys in `sender_usernames` should be stable.
- Switching `enable_custom_domain` between true and false changes the domain name (`AzureManagedDomain` vs `<custom>`) and the `domain_management` mode, both of which are ForceNew on the domain resource. Plan accordingly.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_communication_service.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/communication_service) | resource |
| [azurerm_communication_service_email_domain_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/communication_service_email_domain_association) | resource |
| [azurerm_email_communication_service.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/email_communication_service) | resource |
| [azurerm_email_communication_service_domain.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/email_communication_service_domain) | resource |
| [azurerm_email_communication_service_domain_sender_username.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/email_communication_service_domain_sender_username) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_location"></a> [data\_location](#input\_data\_location) | Region where the Communication Service and Email Communication Service store data at rest. Applied to both resources. ForceNew — cannot be changed in place. No default; consumers must choose explicitly because of data-residency policy implications. | `string` | n/a | yes |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Optional diagnostic settings attached to the Communication Service (the Email service does not currently expose diagnostic categories). At least one destination is required when non-null. | <pre>object({<br/>    name                           = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    enabled_log_categories         = optional(list(string))<br/>    enabled_metrics                = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Fully qualified custom domain (e.g. mail.example.com). Required when enable\_custom\_domain = true. Ignored when enable\_custom\_domain = false (Azure-managed flow uses the literal AzureManagedDomain). | `string` | `null` | no |
| <a name="input_email_service_name"></a> [email\_service\_name](#input\_email\_service\_name) | Override the email service resource name. Defaults to <name>-email. | `string` | `null` | no |
| <a name="input_enable_custom_domain"></a> [enable\_custom\_domain](#input\_enable\_custom\_domain) | Use a customer-managed custom domain (CustomerManaged) instead of an Azure-managed *.azurecomm.net subdomain. Requires domain\_name to be set. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region. Required by module convention but NOT passed to the underlying Communication Service or Email Communication Service resources (they are global). Kept on the module so consumers' standard wiring works unchanged. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Communication Service name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sender_usernames"></a> [sender\_usernames](#input\_sender\_usernames) | Map of sender usernames to provision. Keys are arbitrary identifiers used for for\_each (changing a key replaces the sender). username is the local-part (e.g. no-reply). display\_name is optional. | <pre>map(object({<br/>    username     = string<br/>    display_name = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resources | `map(string)` | `{}` | no |
| <a name="input_user_engagement_tracking_enabled"></a> [user\_engagement\_tracking\_enabled](#input\_user\_engagement\_tracking\_enabled) | Enable user engagement tracking on the email domain. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_communication_service_id"></a> [communication\_service\_id](#output\_communication\_service\_id) | Alias of id, named for clarity when consumers later add SMS/chat wiring |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | Email Communication Service Domain resource ID |
| <a name="output_email_service_id"></a> [email\_service\_id](#output\_email\_service\_id) | Email Communication Service resource ID |
| <a name="output_from_sender_domain"></a> [from\_sender\_domain](#output\_from\_sender\_domain) | P2 sender domain shown to recipients (RFC 5322) |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Communication Service hostname (e.g. for SDK configuration) |
| <a name="output_id"></a> [id](#output\_id) | Communication Service resource ID |
| <a name="output_mail_from_sender_domain"></a> [mail\_from\_sender\_domain](#output\_mail\_from\_sender\_domain) | P1 envelope sender domain (RFC 5321) |
| <a name="output_name"></a> [name](#output\_name) | Communication Service name |
| <a name="output_sender_usernames"></a> [sender\_usernames](#output\_sender\_usernames) | Map of sender keys to { id, username, from\_address }. from\_address is computed as <username>@<mail\_from\_sender\_domain>. |
| <a name="output_verification_records"></a> [verification\_records](#output\_verification\_records) | DNS verification records required when enable\_custom\_domain = true. null when using the Azure-managed domain. Each non-null sub-block contains { name, type, value, ttl }. |
<!-- END_TF_DOCS -->
