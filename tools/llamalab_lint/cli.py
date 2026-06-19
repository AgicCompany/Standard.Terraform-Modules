"""CLI: resolve tags, run lint and/or drift per sidecar, dedupe, suppress, report, exit."""
import argparse
import glob
import re
import subprocess
import sys

from packaging.version import Version, InvalidVersion

from .sidecar import read_sidecar
from .introspect import introspect, resolve_path
from .lint import lint
from .drift import diff, _upgrade_pass
from .ignore import load_suppressions, apply_suppressions
from .report import format_table, to_json, exit_code
from .models import Finding, DriftError, ERROR


def pick_latest_tag(module, tags):
    """Highest semver tag matching '<module>/vX.Y.Z'. None if no match."""
    pattern = re.compile(rf"^{re.escape(module)}/v(\d+\.\d+\.\d+)$")
    best_version = None
    best_tag = None
    for tag in tags:
        m = pattern.match(tag.strip())
        if not m:
            continue
        try:
            version = Version(m.group(1))
        except InvalidVersion:
            continue
        if best_version is None or version > best_version:
            best_version, best_tag = version, tag.strip()
    return best_tag


def _git(framework_path, *args):
    return subprocess.run(
        ["git", "-C", str(framework_path), *args],
        capture_output=True, text=True,
    )


def _list_tags(framework_path, module):
    r = _git(framework_path, "tag", "--list", f"{module}/v*")
    if r.returncode != 0:
        raise DriftError(f"git tag failed in {framework_path}: {r.stderr.strip()}")
    return [t for t in r.stdout.splitlines() if t.strip()]


def _tag_exists(framework_path, tag):
    r = _git(framework_path, "rev-parse", "-q", "--verify", f"refs/tags/{tag}")
    return r.returncode == 0


def _is_git_repo(framework_path):
    return _git(framework_path, "rev-parse", "--git-dir").returncode == 0


def _module_exists(framework_path, module, ref="HEAD"):
    """Check 2: modules/<module>/ is a directory at `ref`. Probed at HEAD (not the pinned
    tag) to keep two failure modes distinct: a bad module_name yields a clean lint.2 ERROR
    here, whereas a valid module with a typo'd module_version falls through to tag
    resolution and raises DriftError (§10 step 3). Probing at the pinned tag would conflate
    them — a version typo would masquerade as a missing module."""
    r = _git(framework_path, "cat-file", "-t", f"{ref}:modules/{module}")
    return r.returncode == 0 and r.stdout.strip() == "tree"


def _dedupe(findings):
    """Collapse findings sharing (name, severity), first occurrence wins (§6.3). Lint
    findings precede drift findings in the list, so lint wins a lint/drift overlap."""
    seen = set()
    kept = []
    for f in findings:
        key = (f.name, f.severity)
        if key in seen:
            continue
        seen.add(key)
        kept.append(f)
    return kept


def check_sidecar(framework_path, path, mode="unified"):
    """Return (findings, pinned_tag, latest_tag, suppressed_count) for one sidecar.

    mode:
      "unified" -> lint checks + drift._upgrade_pass(new_vars_only=True); dedupe; suppress
      "lint"    -> lint checks only (latest_tag resolved for check 10, no upgrade pass)
      "drift"   -> standalone diff() (both passes, cat-2 unscoped); no check 2/dedupe/suppress
    """
    sc = read_sidecar(path)
    if not sc.module_name or not sc.module_version:
        raise DriftError(f"{path}: missing metadata.module_name/module_version")
    if not _is_git_repo(framework_path):
        raise DriftError(f"--framework path is not a git repository: {framework_path}")

    # Check 2 (module existence) runs before tag resolution and probes HEAD, so a typo'd
    # module_name is a graceful lint.2 ERROR while a typo'd module_version still raises
    # DriftError at the tag step (§6.1, S5, §10 step 3). drift-only preserves the original
    # standalone flow and skips it (§3).
    if mode != "drift" and not _module_exists(framework_path, sc.module_name):
        finding = Finding(family="lint", check="lint.2", severity=ERROR,
                          name=sc.module_name,
                          detail=f"module_name '{sc.module_name}' does not resolve to "
                                 f"modules/{sc.module_name}/ in the framework clone")
        return [finding], None, None, 0

    pinned_tag = f"{sc.module_name}/v{sc.module_version}"
    if not _tag_exists(framework_path, pinned_tag):
        raise DriftError(f"{path}: pinned tag {pinned_tag} not found in {framework_path}")
    latest_tag = pick_latest_tag(sc.module_name, _list_tags(framework_path, sc.module_name))
    pinned_facts = introspect(framework_path, sc.module_name, pinned_tag)

    if mode == "drift":
        latest_facts = None
        if latest_tag and latest_tag != pinned_tag:
            latest_facts = introspect(framework_path, sc.module_name, latest_tag)
        return diff(sc, pinned_facts, latest_facts), pinned_tag, latest_tag, 0

    findings = lint(sc, pinned_facts, latest_tag, resolve_path)
    if mode == "unified" and latest_tag and latest_tag != pinned_tag:
        latest_facts = introspect(framework_path, sc.module_name, latest_tag)
        findings = findings + _upgrade_pass(sc, pinned_facts, latest_facts,
                                            new_vars_only=True)

    findings = _dedupe(findings)
    kept, suppressed = apply_suppressions(findings, load_suppressions(path))
    return kept, pinned_tag, latest_tag, len(suppressed)


def main(argv=None):
    parser = argparse.ArgumentParser(prog="llamalab-lint")
    parser.add_argument("--framework", required=True, help="path to a framework-terraform clone")
    parser.add_argument("--all", action="store_true", help="check files/manifest*.yaml")
    parser.add_argument("sidecars", nargs="*", help="sidecar paths")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--warn-as-error", action="store_true")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--lint-only", action="store_true", help="run only the lint checks")
    group.add_argument("--drift-only", action="store_true", help="run only the standalone drift diff")
    args = parser.parse_args(argv)

    paths = sorted(glob.glob("files/manifest*.yaml")) if args.all else list(args.sidecars)
    if not paths:
        parser.error("no sidecars given (use --all or pass paths)")

    mode = "unified"
    if args.lint_only:
        mode = "lint"
    elif args.drift_only:
        mode = "drift"

    all_findings = []
    total_suppressed = 0
    try:
        for path in paths:
            findings, pinned_tag, latest_tag, suppressed = check_sidecar(
                args.framework, path, mode)
            all_findings.extend(findings)
            total_suppressed += suppressed
            if not args.json:
                if pinned_tag is None:
                    print(f"== {path}  (module not found)")
                else:
                    latest_note = f", latest {latest_tag}" if latest_tag else ""
                    print(f"== {path}  (pinned {pinned_tag}{latest_note})")
                print(format_table(findings))
    except DriftError as e:
        print(f"error: {e}", file=sys.stderr)
        return 2

    if args.json:
        print(to_json(all_findings))
    elif total_suppressed:
        print(f"suppressed: {total_suppressed}")
    return exit_code(all_findings, args.warn_as_error)


if __name__ == "__main__":
    sys.exit(main())
