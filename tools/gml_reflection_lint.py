#!/usr/bin/env python3
"""gml_reflection_lint.py
Simple repo linter to detect unsafe reflection/probing patterns in GML projects.

Flags (non-exhaustive):
 - unquoted identifier passed to function_exists(...)  -> BAD (may evaluate an identifier)
 - script_exists("name") where `name` is a declared function (not a script asset) -> likely BAD
 - asset_get_index("funcName") where funcName is a declared function -> BAD
 - usage of function_exists(...) at all (flagged as suspicious)

Exit code: 0 = clean, 1 = issues found

Usage:
  python tools/gml_reflection_lint.py [--root PATH]

"""
from __future__ import annotations
import re
import sys
from pathlib import Path
from typing import List, Tuple

ROOT = Path(__file__).resolve().parents[1]
EXTS = {".gml", ".yy", ".gm6"}

# Regexes
RE_FUNCTION_DEF = re.compile(r"^\s*function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.MULTILINE)
RE_FUNCTION_EXISTS_UNQUOTED = re.compile(r"function_exists\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)")
RE_FUNCTION_EXISTS_STRING = re.compile(r"function_exists\(\s*['\"]([A-Za-z_][A-Za-z0-9_]*)['\"]\s*\)")
RE_SCRIPT_EXISTS_STRING = re.compile(r"script_exists\(\s*['\"]([A-Za-z_][A-Za-z0-9_]*)['\"]\s*\)")
RE_ASSET_GET_INDEX = re.compile(r"asset_get_index\(\s*['\"]([A-Za-z_][A-Za-z0-9_]*)['\"]\s*\)")

IGNORED_PATHS = {".git", "build", "bin", "dist", "node_modules"}


def collect_files(root: Path) -> List[Path]:
    out = []
    for p in root.rglob("*"):
        if p.is_file() and p.suffix.lower() in EXTS:
            if any(part in IGNORED_PATHS for part in p.parts):
                continue
            out.append(p)
    return out


def read_text(p: Path) -> str:
    try:
        return p.read_text(encoding="utf-8")
    except Exception:
        return ""


def find_function_defs(text: str) -> List[str]:
    return list({m.group(1) for m in RE_FUNCTION_DEF.finditer(text)})




if __name__ == "__main__":
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT
    files = collect_files(root)

    # Collect all declared function names across the repo (heuristic)
    declared = set()
    for f in files:
        txt = read_text(f)
        for name in find_function_defs(txt):
            declared.add(name)

    # Collect asset-backed script names (from .yy files) so we don't flag valid asset_get_index/script_exists uses
    asset_names = set()
    for yy in Path(root).rglob('**/*.yy'):
        try:
            content = yy.read_text(encoding='utf-8')
        except Exception:
            continue
        # look for "%Name":"<name>"
        for m in re.finditer(r'"%Name"\s*:\s*"([A-Za-z0-9_\-]+)"', content):
            asset_names.add(m.group(1))
        # also add by filename heuristic: folder/name/name.yy or name.yy
        stem = yy.stem
        asset_names.add(stem)

    issues: List[str] = []

    for f in files:
        text = read_text(f)
        if not text:
            continue

        # 1) flag unquoted function_exists(identifier)
        for m in RE_FUNCTION_EXISTS_UNQUOTED.finditer(text):
            name = m.group(1)
            line_no = text[:m.start()].count("\n") + 1
            issues.append(f"{f}:{line_no}: unsafe use of function_exists with an identifier '{name}' — use direct call or try/catch/is_callable\n    -> {m.group(0).strip()}")

        # 2) flag any use of function_exists with a string (deprecated/suspicious)
        for m in RE_FUNCTION_EXISTS_STRING.finditer(text):
            name = m.group(1)
            line_no = text[:m.start()].count("\n") + 1
            issues.append(f"{f}:{line_no}: suspicious use of function_exists(\"{name}\") — GMS2 doesn't support this as a safe runtime probe\n    -> {m.group(0).strip()}")

        # 3) script_exists("name") where name matches a declared function -> likely wrong
        for m in RE_SCRIPT_EXISTS_STRING.finditer(text):
            name = m.group(1)
            # If the name is also an asset-backed script, this usage is likely valid; otherwise flag when it looks like a function
            if name in declared and name not in asset_names:
                line_no = text[:m.start()].count("\n") + 1
                issues.append(f"{f}:{line_no}: script_exists(\"{name}\") — '{name}' is declared as a function in the repo and not found as an asset; calling script_exists with a string may be the wrong check (use is_callable or asset_get_index for asset-backed scripts)\n    -> {m.group(0).strip()}")

        # 4) asset_get_index("X") where X appears as a declared function -> flag (functions are not assets)
        for m in RE_ASSET_GET_INDEX.finditer(text):
            name = m.group(1)
            # asset_get_index on a name that actually exists as an asset is fine; flag when name is only a function
            if name in declared and name not in asset_names:
                line_no = text[:m.start()].count("\n") + 1
                issues.append(f"{f}:{line_no}: asset_get_index(\"{name}\") — '{name}' is a declared function, not an asset; this is likely incorrect\n    -> {m.group(0).strip()}")

    if issues:
        print("GML reflection/lint: found potential issues (see list)")
        print("-" * 72)
        for it in issues:
            print(it)
            print()
        print(f"Total issues: {len(issues)}")
        sys.exit(1)

    print("GML reflection/lint: no obvious reflection/probing issues found.")
    sys.exit(0)
