# complete

Demonstrates the full feature surface of `communication-service-email`:

- Customer-managed custom domain (`mail.example.com`).
- Two sender usernames (`no-reply`, `notifications`) with display names.
- User engagement tracking enabled.
- Diagnostic settings sent to a Log Analytics workspace.

After first apply, take the `verification_records` output and provision the matching DNS records at your registrar (`domain` TXT, `spf` TXT, `dkim` TXT/CNAME, `dkim2` TXT/CNAME, `dmarc` TXT). Re-apply to let Azure complete verification.

`output.sender_addresses` returns the ready-to-use `<username>@<mail_from_sender_domain>` strings for each sender, which is what consumers usually wire into their SMTP/SDK configuration.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acs_email"></a> [acs\_email](#module\_acs\_email) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sender_addresses"></a> [sender\_addresses](#output\_sender\_addresses) | n/a |
| <a name="output_verification_records"></a> [verification\_records](#output\_verification\_records) | Provision these at your DNS registrar to complete domain verification |
<!-- END_TF_DOCS -->