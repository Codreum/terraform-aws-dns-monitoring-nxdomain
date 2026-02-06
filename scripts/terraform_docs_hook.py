#!/usr/bin/env python3
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    modules_dir = repo_root / "modules"
    workdir = modules_dir if modules_dir.is_dir() else repo_root

    cmd = [
        "terraform-docs", "markdown", "table",
        "--output-file", "README.md",
        "--output-mode", "inject",
        ".",
    ]

    try:
        r = subprocess.run(cmd, cwd=str(workdir), check=False)
        return r.returncode
    except FileNotFoundError:
        print("ERROR: terraform-docs not found on PATH. Install it in this environment.", file=sys.stderr)
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
