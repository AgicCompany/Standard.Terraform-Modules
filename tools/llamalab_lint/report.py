"""Render findings to text/JSON and compute the process exit code."""
import json

from .models import ERROR, WARN, INFO

_SEV_ORDER = {ERROR: 0, WARN: 1, INFO: 2}


def format_table(findings) -> str:
    if not findings:
        return "No findings."
    rows = sorted(findings, key=lambda f: (_SEV_ORDER[f.severity], f.family, f.check, f.name))
    lines = []
    for f in rows:
        phase = f"[{f.phase}] " if f.phase else ""
        lines.append(f"  {f.severity:<5} {phase}{f.check} {f.name}: {f.detail}")
    return "\n".join(lines)


def to_json(findings) -> str:
    return json.dumps(
        [
            {"family": f.family, "check": f.check, "severity": f.severity,
             "phase": f.phase, "name": f.name, "detail": f.detail}
            for f in findings
        ],
        indent=2,
    )


def exit_code(findings, warn_as_error: bool = False) -> int:
    failing = {ERROR, WARN} if warn_as_error else {ERROR}
    return 1 if any(f.severity in failing for f in findings) else 0
