---
title: LlamaLab Lint Migration Notes
date: 2026-06-19
status: draft
---

# LlamaLab Lint — Migration Notes

## What was done

The `llamalab_lint` tool and four initial module sidecars were vendored into
this repo and a CI workflow was wired up. Changes are on branch
`feat/llamalab-lint` (PR pending — open manually, no CLI collaborator access).

### Commits on the branch

- `0980141` — feat: add LlamaLab manifest lint tooling and CI workflow
- `ec86b0f` — chore: exclude Python __pycache__ from version control

### Files added

```
tools/
  README.md                      purpose, usage, re-sync instructions
  requirements.txt               python-hcl2, pyyaml, packaging
  llamalab_lint/                 vendored tool (source: vending-machine-llamalab)

modules/
  user-assigned-identity/manifest.yaml
  storage-account/manifest.yaml
  aks/manifest.yaml
  service-bus/manifest.yaml

.github/workflows/
  llamalab-lint.yml              CI workflow
```

## How to run the tool locally

```bash
pip install -r tools/requirements.txt

# single module
python -m tools.llamalab_lint.cli --framework . modules/storage-account/manifest.yaml

# all modules at once
python -m tools.llamalab_lint.cli --framework . modules/*/manifest.yaml
```

## How the CI workflow behaves

Triggers on PRs that touch `modules/**/manifest.yaml` or `tools/**`.

- If only manifests changed: lints the affected modules only.
- If `tools/` changed: lints every module that has a `manifest.yaml`.

## Next steps

- Merge the PR once reviewed.
- Add `manifest.yaml` sidecars for other modules as they are onboarded to
  the LlamaLab catalogue — the CI workflow will pick them up automatically.
- When the tool is updated upstream in `vending-machine-llamalab`, re-copy
  `tools/llamalab_lint/` from that repo.
