# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

## [1.1.0] - 2026-03-30

### Added

- Custom domains with managed TLS via `custom_domains` variable
- WAF firewall policy with managed rules via `waf` variable (custom rules deferred to v1.2.0)
- Rule sets with conditions and actions via `rule_sets` variable
- Private Link support on origins via optional `private_link` block in `origins` variable
- Route enhancements: `rule_set_keys`, `custom_domain_keys`, `compression_enabled`, `content_types_to_compress`
- Security policy resource binding WAF to all endpoints and custom domains
- New outputs: `custom_domain_ids`, `custom_domain_validation_tokens`, `firewall_policy_id`, `rule_set_ids`

## [1.0.0] - 2026-02-09

### Added

- Initial release
- Front Door profile with configurable SKU (Standard, Premium)
- Endpoint management with for_each
- Origin group management with health probes and load balancing
- Origin management with cross-reference to origin groups
- Route management with cross-reference to endpoints and origin groups
- Secure defaults (HTTPS redirect, HttpsOnly forwarding, certificate name check)
