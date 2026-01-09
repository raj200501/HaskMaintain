from pathlib import Path
import shutil

from haskmaintain.analyzer import analyze
from haskmaintain.config import Config


def test_analyze_writes_reports(tmp_path):
    output_dir = tmp_path / "reports"
    config = Config(
        root=Path("data/fixtures/basic"),
        output_dir=output_dir,
        formats=["text", "json"],
        follow_symlinks=False,
    )
    written = analyze(config)
    assert output_dir / "haskmaintain-report.txt" in written
    assert output_dir / "haskmaintain-report.json" in written
    assert (output_dir / "haskmaintain-report.txt").read_text(encoding="utf-8").startswith(
        "HaskMaintain Report"
    )
