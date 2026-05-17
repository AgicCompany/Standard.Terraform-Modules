# basic

Azure-managed email domain on an `*.azurecomm.net` subdomain. No senders configured, no engagement tracking, no diagnostics. After apply, ACS exposes the auto-generated `donotreply@<managed>.azurecomm.net` MailFrom — that's what `output.from_address` returns.
