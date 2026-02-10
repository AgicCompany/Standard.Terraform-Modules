# action-group

**Complexity:** Low

Creates an Azure Monitor Action Group for alert notification delivery via email, SMS, webhooks, and push notifications.

## Usage

```hcl
module "action_group" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//action-group?ref=action-group/v1.0.0"

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

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **No location:** Action groups are global Azure resources. No `location` variable is needed.
- **Short name limit:** The `short_name` is limited to 12 characters and appears in SMS notifications and email subject lines.
- **Common alert schema:** When enabled, all alerts use a standardized JSON payload. Recommended for webhook integrations.
- **Rate limiting:** Azure applies rate limiting to action group notifications. See Azure Monitor documentation for current limits.
