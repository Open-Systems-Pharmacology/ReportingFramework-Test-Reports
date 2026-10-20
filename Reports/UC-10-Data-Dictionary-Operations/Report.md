# UC-10 Data Dictionary Operations

## Summary
This scenario validates dictionary-driven observed-data import for time profiles and PK parameters in both individual and aggregated forms, plus NumericValues. It uses a dedicated repo-local workbook fixture generated from the installed package template and verifies DataFiles filtering, dictionary Filter and FilterValue mappings, and `spreadData = TRUE` propagation into `Individuals.xlsx`.

## Assertions
- The fixture workbook contains `DataFiles`, `tpDictionary`, `pkDictionary`, and `NumericValues` sheets using the installed package template column layout.
- `DataFiles` covers all five import rows: TP individual, TP aggregated, PK individual, PK aggregated, and NumericValues.
- `readObservedDataByDictionary()` is executed explicitly for `dataClassType = "timeprofile"`, `"pkParameter"`, and `"numericValues"`.
- Time-profile import returns both `DATACLASS$tpIndividual` and `DATACLASS$tpAggregated` rows from source fixtures.
- PK import returns both `DATACLASS$pkIndividual` and `DATACLASS$pkAggregated` rows from source fixtures.
- NumericValues import returns the configured scalar variables with unique `variableName` entries.
- File-level `DataFilter` removes the excluded fixture rows before import.
- Dictionary `Filter` and `FilterValue` rows populate derived fields such as `individualId`, `group`, `population`, and `species`.
- Aggregated TP rows import `yErrorType`, `yErrorValues`, `yMin`, `yMax`, `numberOfIndividuals`, and `nBelowLLOQ` from source data.
- Aggregated PK rows import `errorType`, `errorValues`, `minValue`, `maxValue`, and `numberOfIndividuals` from source data.
- `fileIds` filtering isolates individual and aggregated TP/PK fixture files.
- `spreadData = TRUE` populates `Individuals.xlsx` / `IndividualBiometrics` in the installed package version used by this repo.

## Result files
- `ReportInputs/UC10_DataImport/DataImportConfiguration.xlsx` - dedicated UC-10 import configuration workbook
- `ReportInputs/UC10_DataImport/tp_individual.csv` - individual time-profile source data
- `ReportInputs/UC10_DataImport/tp_aggregated.csv` - aggregated time-profile source data
- `ReportInputs/UC10_DataImport/pk_individual.csv` - individual PK source data
- `ReportInputs/UC10_DataImport/pk_aggregated.csv` - aggregated PK source data
- `ReportInputs/refresh-uc10-data-import-fixtures.R` - fixture refresh script for the UC-10 import matrix
