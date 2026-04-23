#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for module in "$ROOT"/modules/*/; do
  name="$(basename "$module")"
  echo "Generating docs for $name"
  terraform-docs "$module"

  for example in "$module"examples/*/; do
    [ -d "$example" ] || continue
    echo "  -> $(basename "$example")"
    terraform-docs "$example"
  done
done

echo "Done. All module and example READMEs updated."
