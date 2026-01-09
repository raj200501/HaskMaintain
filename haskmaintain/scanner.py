"""Directory scanning utilities."""

from __future__ import annotations

from pathlib import Path
from typing import Iterable, List


HASKELL_SUFFIXES = {".hs", ".lhs"}


def is_haskell_file(path: Path) -> bool:
    return path.suffix in HASKELL_SUFFIXES


def scan_sources(root: Path, follow_symlinks: bool = False) -> List[Path]:
    if not root.exists():
        return []

    paths: List[Path] = []
    for path in root.rglob("*"):
        if path.is_symlink() and not follow_symlinks:
            continue
        if path.is_file() and is_haskell_file(path):
            paths.append(path)
    return sorted(paths)
