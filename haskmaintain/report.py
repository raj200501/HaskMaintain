"""Report rendering and serialization."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable, List
import json

from haskmaintain.metrics import FileMetrics


@dataclass(frozen=True)
class Summary:
    files: int
    lines_total: int
    lines_code: int
    lines_comment: int
    lines_blank: int
    function_count: int
    type_signature_count: int
    cyclomatic_complexity: int


@dataclass(frozen=True)
class Report:
    generated_at: str
    root: Path
    summary: Summary
    files: List[FileMetrics]


def build_report(root: Path, metrics: Iterable[FileMetrics]) -> Report:
    metrics_list = sorted(metrics, key=lambda item: str(item.path))
    summary = build_summary(metrics_list)
    generated_at = datetime.now(timezone.utc).isoformat()
    return Report(
        generated_at=generated_at,
        root=root,
        summary=summary,
        files=metrics_list,
    )


def build_summary(metrics: Iterable[FileMetrics]) -> Summary:
    metrics_list = list(metrics)
    return Summary(
        files=len(metrics_list),
        lines_total=sum(item.lines_total for item in metrics_list),
        lines_code=sum(item.lines_code for item in metrics_list),
        lines_comment=sum(item.lines_comment for item in metrics_list),
        lines_blank=sum(item.lines_blank for item in metrics_list),
        function_count=sum(item.function_count for item in metrics_list),
        type_signature_count=sum(item.type_signature_count for item in metrics_list),
        cyclomatic_complexity=sum(item.cyclomatic_complexity for item in metrics_list),
    )


def render_text(report: Report) -> str:
    lines = [
        "HaskMaintain Report",
        f"Root: {report.root}",
        f"Generated: {report.generated_at}",
        "",
        "Summary",
        f"  Files analyzed: {report.summary.files}",
        f"  Lines (total): {report.summary.lines_total}",
        f"  Lines (code): {report.summary.lines_code}",
        f"  Lines (comment): {report.summary.lines_comment}",
        f"  Lines (blank): {report.summary.lines_blank}",
        f"  Functions: {report.summary.function_count}",
        f"  Type signatures: {report.summary.type_signature_count}",
        f"  Cyclomatic complexity: {report.summary.cyclomatic_complexity}",
        "",
        "Per-file Metrics:",
    ]

    for item in report.files:
        lines.extend(
            [
                f"- {item.path}",
                f"    Lines total: {item.lines_total}",
                f"    Lines code: {item.lines_code}",
                f"    Lines comment: {item.lines_comment}",
                f"    Lines blank: {item.lines_blank}",
                f"    Functions: {item.function_count}",
                f"    Type signatures: {item.type_signature_count}",
                f"    Cyclomatic complexity: {item.cyclomatic_complexity}",
            ]
        )
    return "\n".join(lines) + "\n"


def report_to_dict(report: Report) -> dict:
    return {
        "generatedAt": report.generated_at,
        "root": str(report.root),
        "summary": {
            "files": report.summary.files,
            "lines": {
                "total": report.summary.lines_total,
                "code": report.summary.lines_code,
                "comment": report.summary.lines_comment,
                "blank": report.summary.lines_blank,
            },
            "functions": report.summary.function_count,
            "typeSignatures": report.summary.type_signature_count,
            "cyclomaticComplexity": report.summary.cyclomatic_complexity,
        },
        "files": [
            {
                "path": str(item.path),
                "lines": {
                    "total": item.lines_total,
                    "code": item.lines_code,
                    "comment": item.lines_comment,
                    "blank": item.lines_blank,
                },
                "functions": item.function_count,
                "typeSignatures": item.type_signature_count,
                "cyclomaticComplexity": item.cyclomatic_complexity,
            }
            for item in report.files
        ],
    }


def write_reports(output_dir: Path, formats: Iterable[str], report: Report) -> List[Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    written: List[Path] = []
    for fmt in formats:
        fmt_lower = fmt.lower()
        if fmt_lower == "text":
            path = output_dir / "haskmaintain-report.txt"
            path.write_text(render_text(report), encoding="utf-8")
            written.append(path)
        elif fmt_lower == "json":
            path = output_dir / "haskmaintain-report.json"
            path.write_text(json.dumps(report_to_dict(report), indent=2), encoding="utf-8")
            written.append(path)
    return written
