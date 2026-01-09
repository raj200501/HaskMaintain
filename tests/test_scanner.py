from pathlib import Path

from haskmaintain.scanner import scan_sources


def test_scan_sources_finds_fixture():
    root = Path("data/fixtures/basic")
    files = scan_sources(root)
    assert any(path.name == "Example.hs" for path in files)
