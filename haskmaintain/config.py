"""Configuration parsing for HaskMaintain."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable, List


@dataclass(frozen=True)
class Config:
    root: Path
    output_dir: Path
    formats: List[str] = field(default_factory=lambda: ["text", "json"])
    follow_symlinks: bool = False


def normalize_formats(formats: Iterable[str]) -> List[str]:
    normalized = [fmt.strip().lower() for fmt in formats if fmt.strip()]
    return normalized or ["text"]


def default_config() -> Config:
    return Config(root=Path("."), output_dir=Path("reports"))
