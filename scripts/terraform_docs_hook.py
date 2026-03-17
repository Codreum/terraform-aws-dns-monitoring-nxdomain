#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def render_module(module_dir: Path) -> int:
    cmd = [
        "terraform-docs",
        "markdown",
        "table",
        "--output-file",
        "README.md",
        "--output-mode",
        "inject",
        ".",
    ]
    result = subprocess.run(cmd, cwd=str(module_dir), check=False)
    return result.returncode


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]

    module_dirs = [
        repo_root / "modules" / "nxdomain",
        repo_root / "modules" / "autovpc",
    ]

    rc = 0

    try:
        for module_dir in module_dirs:
            if not module_dir.is_dir():
                print(
                    f"ERROR: module directory not found: {module_dir}",
                    file=sys.stderr,
                )
                rc = 1
                continue

            rc |= render_module(module_dir)

        return rc
    except FileNotFoundError:
        print(
            "ERROR: terraform-docs not found on PATH. Install it in this environment.",
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())