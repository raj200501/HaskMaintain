#!/usr/bin/env bash
set -euo pipefail

ROOT_PATH=${1:-data/fixtures/basic}
OUTPUT_DIR=${OUTPUT_DIR:-test-output/verify}

python -m pytest

python -m haskmaintain "$ROOT_PATH" --output-dir "$OUTPUT_DIR"

TEXT_REPORT="$OUTPUT_DIR/haskmaintain-report.txt"
JSON_REPORT="$OUTPUT_DIR/haskmaintain-report.json"

if [[ ! -f "$TEXT_REPORT" ]]; then
  echo "Missing text report at $TEXT_REPORT" >&2
  exit 1
fi

if [[ ! -f "$JSON_REPORT" ]]; then
  echo "Missing JSON report at $JSON_REPORT" >&2
  exit 1
fi

if ! grep -q "HaskMaintain Report" "$TEXT_REPORT"; then
  echo "Text report did not contain expected header." >&2
  exit 1
fi

if ! grep -q "\"files\"" "$JSON_REPORT"; then
  echo "JSON report did not contain expected keys." >&2
  exit 1
fi

echo "Verification succeeded."
