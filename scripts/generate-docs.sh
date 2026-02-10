#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for module in "$ROOT"/modules/*/; do
  echo "Generating docs for $(basename "$module")"
  terraform-docs "$module"
done

echo "Done. All module READMEs updated."
