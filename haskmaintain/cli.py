"""CLI entrypoints."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import List

from haskmaintain.analyzer import analyze
from haskmaintain.config import Config


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="HaskMaintain",
        description="Analyze a Haskell codebase for maintainability metrics.",
    )
    parser.add_argument("path", nargs="?", default=".", help="Root path to analyze")
    parser.add_argument(
        "--output-dir",
        default="reports",
        help="Directory to write reports (default: reports)",
    )
    parser.add_argument(
        "--format",
        dest="formats",
        action="append",
        default=[],
        help="Report format: text or json (repeatable)",
    )
    parser.add_argument(
        "--follow-symlinks",
        action="store_true",
        help="Follow symlinks when scanning",
    )
    return parser


def parse_args(argv: List[str] | None = None) -> Config:
    parser = build_parser()
    args = parser.parse_args(argv)
    formats = args.formats or ["text", "json"]
    return Config(
        root=Path(args.path),
        output_dir=Path(args.output_dir),
        formats=formats,
        follow_symlinks=args.follow_symlinks,
    )


def main(argv: List[str] | None = None) -> int:
    config = parse_args(argv)
    analyze(config)
    print("Report generated.")
    return 0
