"""Offline repository checks; Python 3.9+, standard library only."""

import ast
import json
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
TEXT_SUFFIXES = {".md", ".py", ".json", ".yml", ".yaml", ".gd", ".tscn", ".tres"}
LINK = re.compile(r'\[[^\]\n]*\]\((<[^>\n]+>|[^()\s]+)(?:\s+"[^"\n]*")?\)')
CONFLICT = re.compile(r"^(?:<<<<<<< .+|=======|>>>>>>> .+)$", re.MULTILINE)


def exact_path_exists(path):
    """Catch case mismatches even on case-insensitive developer filesystems."""
    try:
        relative = path.relative_to(ROOT)
        current = ROOT
        for part in relative.parts:
            if part not in {child.name for child in current.iterdir()}:
                return False
            current = current / part
        return current.exists()
    except (OSError, ValueError):
        return False


def check_file(path):
    errors = []
    try:
        content = path.read_text(encoding="utf-8")
    except (UnicodeError, OSError) as error:
        return ["cannot read UTF-8: {}".format(error)]
    if CONFLICT.search(content):
        errors.append("unresolved merge conflict marker")
    try:
        if path.suffix == ".json":
            json.loads(content)
        elif path.suffix == ".py":
            ast.parse(content, filename=str(path))
    except (ValueError, SyntaxError) as error:
        errors.append("invalid syntax: {}".format(error))
    if path.suffix == ".md":
        # Check simple inline file links, excluding fenced examples. This is
        # intentionally not a complete Markdown parser or an external URL check.
        prose = re.sub(r"(?ms)^```[^\n]*\n.*?^```[^\n]*$", "", content)
        for match in LINK.finditer(prose):
            target = match.group(1).strip("<>")
            url = urlsplit(target)
            if url.scheme or url.netloc or not url.path:
                continue
            if url.path.startswith("/"):
                errors.append("use a relative repository link: {}".format(target))
                continue
            resolved = (path.parent / unquote(url.path)).resolve()
            if not exact_path_exists(resolved):
                errors.append("missing or case-mismatched local link: {}".format(target))
    return errors


def main():
    try:
        result = subprocess.run(
            ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
            cwd=ROOT, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
    except (OSError, subprocess.CalledProcessError):
        print("Run this script inside a Git checkout with Git installed.", file=sys.stderr)
        return 2
    paths = sorted(set(result.stdout.decode("utf-8").split("\0")) - {""})
    errors = []
    checked = 0
    for name in paths:
        path = ROOT / name
        if path.suffix not in TEXT_SUFFIXES:
            continue
        checked += 1
        errors.extend("{}: {}".format(name, error) for error in check_file(path))
    for error in errors:
        print(error, file=sys.stderr)
    print("Checked {} text files; {} error(s).".format(checked, len(errors)))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
