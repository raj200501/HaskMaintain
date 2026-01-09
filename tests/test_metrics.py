from pathlib import Path

from haskmaintain.metrics import analyze_file


def test_metrics_for_example():
    path = Path("data/fixtures/basic/Example.hs")
    metrics = analyze_file(path)
    assert metrics.lines_total == 10
    assert metrics.lines_blank == 2
    assert metrics.lines_comment == 3
    assert metrics.lines_code == 5
    assert metrics.function_count == 2
    assert metrics.type_signature_count == 2
    assert metrics.cyclomatic_complexity >= 2
