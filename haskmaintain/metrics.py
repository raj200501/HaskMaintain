"""Metrics calculation for HaskMaintain."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
from typing import Iterable, List, Tuple


FUNCTION_DEF_RE = re.compile(r"^\s*([a-zA-Z_][\w']*)\s+.*=")
TYPE_SIG_RE = re.compile(r"^\s*([a-zA-Z_][\w']*)\s*::")
KEYWORD_RE = re.compile(r"\b(if|case|else|where|let|in|then)\b")
LOGICAL_RE = re.compile(r"(&&|\|\|)")
GUARD_RE = re.compile(r"^\s*\|")

EXCLUDED_DEF_PREFIXES = (
    "data ",
    "type ",
    "newtype ",
    "class ",
    "instance ",
    "module ",
    "import ",
)


@dataclass(frozen=True)
class FileMetrics:
    path: Path
    lines_total: int
    lines_code: int
    lines_comment: int
    lines_blank: int
    function_count: int
    type_signature_count: int
    cyclomatic_complexity: int


def analyze_file(path: Path) -> FileMetrics:
    content = path.read_text(encoding="utf-8")
    return compute_metrics(path, content.splitlines())


def compute_metrics(path: Path, lines: Iterable[str]) -> FileMetrics:
    lines_list = list(lines)
    lines_total = len(lines_list)
    lines_comment, lines_blank, lines_code = classify_lines(lines_list)
    function_count = count_functions(lines_list)
    type_signature_count = count_type_signatures(lines_list)
    cyclomatic_complexity = calculate_cyclomatic_complexity(lines_list, function_count)
    return FileMetrics(
        path=path,
        lines_total=lines_total,
        lines_code=lines_code,
        lines_comment=lines_comment,
        lines_blank=lines_blank,
        function_count=function_count,
        type_signature_count=type_signature_count,
        cyclomatic_complexity=cyclomatic_complexity,
    )


def classify_lines(lines: Iterable[str]) -> Tuple[int, int, int]:
    comment_lines = 0
    blank_lines = 0
    code_lines = 0
    in_block_comment = False

    for line in lines:
        stripped = line.strip()
        if in_block_comment:
            comment_lines += 1
            if "-}" in stripped:
                in_block_comment = False
            continue

        if not stripped:
            blank_lines += 1
            continue

        if stripped.startswith("--"):
            comment_lines += 1
            continue

        if stripped.startswith("{-"):
            comment_lines += 1
            if "-}" not in stripped:
                in_block_comment = True
            continue

        if "{-" in stripped and "-}" not in stripped:
            code_lines += 1
            in_block_comment = True
            continue

        code_lines += 1

    return comment_lines, blank_lines, code_lines


def count_functions(lines: Iterable[str]) -> int:
    count = 0
    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith("--"):
            continue
        if any(stripped.startswith(prefix) for prefix in EXCLUDED_DEF_PREFIXES):
            continue
        match = FUNCTION_DEF_RE.match(line)
        if match:
            count += 1
    return count


def count_type_signatures(lines: Iterable[str]) -> int:
    count = 0
    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith("--"):
            continue
        if any(stripped.startswith(prefix) for prefix in EXCLUDED_DEF_PREFIXES):
            continue
        if TYPE_SIG_RE.match(line):
            count += 1
    return count


def calculate_cyclomatic_complexity(lines: Iterable[str], function_count: int) -> int:
    branches = 0
    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith("--"):
            continue
        branches += len(KEYWORD_RE.findall(line))
        branches += len(LOGICAL_RE.findall(line))
        if GUARD_RE.match(line):
            branches += 1
    base = max(1, function_count)
    return base + branches
