# HaskMaintain

**HaskMaintain** is a maintainability analyzer for Haskell codebases. It recursively scans a directory, analyzes each Haskell source file, and generates a report with metrics such as lines of code, function count, type signature count, and cyclomatic complexity.

## Features

- Recursively scans a directory for `.hs` and `.lhs` files.
- Computes file-level metrics (lines, functions, type signatures, cyclomatic complexity).
- Aggregates results into a project summary.
- Generates both text and JSON reports by default.

## Requirements

- Python 3.11+ (available by default in the execution environment)

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/HaskMaintain.git
    cd HaskMaintain
    ```

## Usage

Run the application on a codebase path:

```bash
python -m haskmaintain <path-to-codebase>
```

By default, reports are written to the `reports/` directory as:

- `reports/haskmaintain-report.txt`
- `reports/haskmaintain-report.json`

### Options

- `--output-dir DIR` — Change the report output directory.
- `--format text|json` — Limit the report formats (repeatable).
- `--follow-symlinks` — Follow symlinks while scanning.

Example:

```bash
python -m haskmaintain data/fixtures/basic --output-dir out --format text
```

## Scripts

- `./scripts/run.sh [path]` — Run with sane defaults.
- `./scripts/verify.sh [path]` — Canonical verification (tests and smoke check).

## Verified Quickstart

The following commands were executed successfully to verify the project:

```bash
python -m haskmaintain data/fixtures/basic --output-dir reports
```

## Verified Verification

```bash
./scripts/verify.sh
```

## Report Behavior

When a run succeeds, you will see `Report generated.` and the reports will be written to the configured output directory. The text report includes a summary block followed by per-file metrics. The JSON report includes the same information for programmatic usage.

## Troubleshooting

- **Reports are missing:** ensure the output directory exists or provide `--output-dir`.
- **No files analyzed:** confirm the path contains `.hs` or `.lhs` files.
- **Parsing edge cases:** HaskMaintain uses a lightweight heuristic parser; highly specialized syntax may require adding new rules to `haskmaintain/metrics.py`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
