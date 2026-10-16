# Report Inputs

This directory contains the repo-local input data used by the report workflows in this repository instead of reading those inputs from package `inst/extdata`.

The currently used subfolders are:

| Folder | Purpose |
|--------|---------|
| Models | PK-Sim model files copied into temporary workflow projects |
| UC13_DataImport | Dedicated CSV and workbook fixtures for UC-13 dictionary-import coverage |
| PKAnalysisResults | Precomputed PK analysis CSV files used by UC07 workflows |
| Populations | Population CSV files copied into temporary workflow projects |
| SensitivityResults | Reserved for local sensitivity input artifacts |
| SimulationResults | Reserved for local simulation input artifacts |

Additional checked-in observed-data fixtures are stored at the top level of this folder:

| File | Purpose |
|------|---------|
| UC7_observed_TP.csv | Stable observed time-profile fixture loaded by UC-07A |
| UC7_observed_PK.csv | Stable observed PK-parameter fixture loaded by the UC-07C to UC-07F PK forest use cases |

Additional checked-in workbook fixtures are also stored at the top level of this folder:

| File | Purpose |
|------|---------|
| Scenarios_UC07.xlsx | UC07-specific scenario, output-path, and PK-parameter mapping workbook copied into temporary workflow projects |
| Reports_UC07.xlsx | UC07-specific report configuration workbook with preserved plot configuration sheets |
| PKParameter_UC07.xlsx | UC07-specific PK parameter workbook with preserved PK_Plasma sheet |

The UC07 migration currently reads models, PK analysis results, populations, and these stable observed-data fixtures from this repo-local ReportInputs folder. Generation helpers in R/helpers-uc-observedData.R are kept for maintenance and fixture refreshes rather than runtime use in the UC scripts.

UC-13 uses the checked-in `UC13_DataImport` fixture folder plus `refresh-uc13-data-import-fixtures.R` to keep the dictionary-import workbook and source CSVs aligned with the installed package template while preserving repo-local coverage rows.

To refresh the checked-in UC7 observed-data fixtures after intentional maintenance changes, run refresh-uc7-observed-fixtures.R from the repository root.

To refresh the checked-in UC07 workbook fixtures after template changes in the installed ospsuite.reportingframework package, run refresh-uc7-xlsx-fixtures.R from the repository root. The script rebuilds the three workbook fixtures from freshly generated package workbooks and then reapplies the repo-local UC07 content that must remain curated here.

To refresh the UC-13 dictionary-import workbook and CSV fixtures, run refresh-uc13-data-import-fixtures.R from the repository root.

