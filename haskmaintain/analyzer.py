"""Core analysis pipeline."""

from __future__ import annotations

from pathlib import Path
from typing import List

from haskmaintain.config import Config, normalize_formats
from haskmaintain.metrics import FileMetrics, analyze_file
from haskmaintain.report import build_report, write_reports
from haskmaintain.scanner import scan_sources


def analyze(config: Config) -> List[Path]:
    root = config.root
    formats = normalize_formats(config.formats)
    sources = scan_sources(root, follow_symlinks=config.follow_symlinks)
    metrics: List[FileMetrics] = [analyze_file(path) for path in sources]
    report = build_report(root, metrics)
    return write_reports(config.output_dir, formats, report)
