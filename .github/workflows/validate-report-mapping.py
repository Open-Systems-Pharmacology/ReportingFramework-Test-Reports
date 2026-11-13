#!/usr/bin/env python3

"""Validate report mapping consistency for CI workflows.

Checks:
- Mapping file exists and is valid JSON list.
- Each item has Script, Report, and Reference fields.
- Script and Report names are unique.
- Script files exist under R/<Script>.R.
- Report directories exist under Reports/<Report> for reference-enabled entries.
- Optional selected report exists in the mapping.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys


def _fail(errors: list[str]) -> None:
    for error in errors:
        print(f"ERROR: {error}")
    raise SystemExit(1)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--mapping",
        default="tests/testthat/report-mapping.json",
        help="Path to report mapping JSON file.",
    )
    parser.add_argument(
        "--report",
        default="",
        help="Optional report name to validate against mapping.",
    )
    args = parser.parse_args()

    mapping_path = Path(args.mapping)
    errors: list[str] = []

    if not mapping_path.exists():
        _fail([f"Mapping file not found: {mapping_path}"])

    try:
        mapping = json.loads(mapping_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        _fail([f"Invalid JSON in {mapping_path}: {exc}"])

    if not isinstance(mapping, list) or len(mapping) == 0:
        _fail([f"Mapping in {mapping_path} must be a non-empty JSON array."])

    seen_scripts: set[str] = set()
    seen_reports: set[str] = set()

    for index, item in enumerate(mapping, start=1):
        if not isinstance(item, dict):
            errors.append(f"Entry {index} is not an object.")
            continue

        for key in ("Script", "Report", "Reference"):
            if key not in item:
                errors.append(f"Entry {index} is missing required key '{key}'.")

        script = item.get("Script")
        report = item.get("Report")
        reference = item.get("Reference")

        if not isinstance(script, str) or not script.strip():
            errors.append(f"Entry {index} has invalid Script value: {script!r}.")
            continue
        if not isinstance(report, str) or not report.strip():
            errors.append(f"Entry {index} has invalid Report value: {report!r}.")
            continue
        if not isinstance(reference, bool):
            errors.append(
                f"Entry {index} has invalid Reference value: {reference!r}; expected true/false."
            )

        if script in seen_scripts:
            errors.append(f"Duplicate Script value: {script}.")
        else:
            seen_scripts.add(script)

        if report in seen_reports:
            errors.append(f"Duplicate Report value: {report}.")
        else:
            seen_reports.add(report)

        script_path = Path("R") / f"{script}.R"
        if not script_path.exists():
            errors.append(f"Missing script file for mapping entry: {script_path}.")

        report_path = Path("Reports") / report
        if reference and not report_path.exists():
            errors.append(f"Missing report directory for mapping entry: {report_path}.")

    selected_report = args.report.strip()
    if selected_report and selected_report not in seen_reports:
        errors.append(
            "Selected report is not listed in mapping: "
            f"{selected_report}. Update tests/testthat/report-mapping.json or input value."
        )

    if errors:
        _fail(errors)

    print(
        "Validation successful: "
        f"{len(mapping)} report mappings checked"
        + (f", selected report '{selected_report}' is valid." if selected_report else ".")
    )


if __name__ == "__main__":
    main()
