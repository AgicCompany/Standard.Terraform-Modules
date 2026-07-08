"""Per-sidecar ignore-list: suppress acknowledged WARN/INFO findings.

A sidecar's suppressions live in an adjacent `<sidecar>.lintignore.yaml`. ERROR is
never suppressible — a matched ERROR survives and earns a `lint.ignore` WARN so the
mistaken entry is visible.
"""
from pathlib import Path

import yaml

from .models import Finding, ERROR, WARN


def _suppression_path(sidecar_path) -> Path:
    s = str(sidecar_path)
    base = s[:-len(".yaml")] if s.endswith(".yaml") else s
    return Path(base + ".lintignore.yaml")


def load_suppressions(sidecar_path) -> list:
    """Return the list of suppression dicts, or [] when the adjacent file is absent."""
    path = _suppression_path(sidecar_path)
    if not path.exists():
        return []
    with open(path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    return data.get("suppress") or []


def _matches(supp: dict, finding) -> bool:
    if supp.get("variable") != finding.name:
        return False
    check = supp.get("check")
    return check is None or check == finding.check


def apply_suppressions(findings, suppressions):
    """Return (kept, suppressed).

    `kept` drives the report and exit code; `suppressed` is the audit count. A
    suppression that matches an ERROR does NOT silence it — the ERROR stays in `kept`
    and a `lint.ignore` WARN is appended.
    """
    kept = []
    suppressed = []
    for f in findings:
        match = next((s for s in suppressions if _matches(s, f)), None)
        if match is None:
            kept.append(f)
        elif f.severity == ERROR:
            kept.append(f)
            kept.append(Finding(family="lint", check="lint.ignore", severity=WARN,
                                name=f.name,
                                detail=f"ignore-list entry cannot suppress an ERROR "
                                       f"({f.check})"))
        else:
            suppressed.append(f)
    return kept, suppressed
