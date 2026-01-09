#!/usr/bin/env bash
set -euo pipefail

ROOT_PATH=${1:-data/fixtures/basic}
OUTPUT_DIR=${OUTPUT_DIR:-reports}

python -m haskmaintain "$ROOT_PATH" --output-dir "$OUTPUT_DIR"

echo "Reports written to: $OUTPUT_DIR"
