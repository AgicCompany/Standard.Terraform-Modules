# tools/

This directory contains tooling that supports CI validation of the LlamaLab
module catalogue.

## llamalab_lint

A Python CLI that validates `manifest.yaml` sidecar files against their
corresponding Terraform modules.

### What is a sidecar?

Each module in this repo can carry a `manifest.yaml` file alongside its
Terraform code. The sidecar is a machine-readable description of the module
written for the LlamaLab vending machine: it tells the web app how to render
a self-service deployment form, which variables are user-facing, how outputs
should be displayed, and how modules wire together.

### What does the tool check?

The tool compares the sidecar against the actual Terraform source to detect
drift — cases where the two have gone out of sync:

- Every Terraform variable has a corresponding sidecar entry, and vice versa
- Conditional visibility rules (`show_when`) reference variables that exist
- Output display entries reference real Terraform outputs
- Group names use the registered vocabulary
- No duplicate alias outputs

### Running it

Requirements: Python 3.11+, dependencies in `tools/requirements.txt`.

```bash
pip install -r tools/requirements.txt

# lint a single module
python -m tools.llamalab_lint.cli --framework . modules/storage-account/manifest.yaml

# lint all modules at once
python -m tools.llamalab_lint.cli --framework . modules/*/manifest.yaml
```

### Origin

The tool was developed and is maintained in the
[vending-machine-llamalab](https://github.com/ecstrim/vending-machine-llamalab)
contract repository, where the full test suite (170 tests) and schema live.
This copy is vendored here so CI can run without cross-repo access. When the
tool is updated upstream, re-copy `tools/llamalab_lint/` from that repo.
