# complete

Demonstrates the full feature surface of `communication-service-email`:

- Customer-managed custom domain (`mail.example.com`).
- Two sender usernames (`no-reply`, `notifications`) with display names.
- User engagement tracking enabled.
- Diagnostic settings sent to a Log Analytics workspace.

After first apply, take the `verification_records` output and provision the matching DNS records at your registrar (`domain` TXT, `spf` TXT, `dkim` TXT/CNAME, `dkim2` TXT/CNAME, `dmarc` TXT). Re-apply to let Azure complete verification.

`output.sender_addresses` returns the ready-to-use `<username>@<mail_from_sender_domain>` strings for each sender, which is what consumers usually wire into their SMTP/SDK configuration.
