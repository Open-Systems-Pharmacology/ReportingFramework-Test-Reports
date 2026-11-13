# UC-04 PK parameter calculation and loading

## Summary

This scenario validates PK calculation, PK loading, PK data validation, and inclusion of a user-defined PK parameter.

## Assertions

- Scenarios configured: UC04_ScenarioA, UC04_ScenarioB
- PK sheets linked from Scenarios.xlsx: PK_Plasma
- calculatePKParameterForScenarios created one CSV file per scenario.
- Required columns present: scenario, pkParameter, individualId, value, outputPathId, displayNamePKParameter, displayUnitPKParameter
- validatePKParameterDT passed without error.
- User-defined PK parameter F_max appears in loaded results.

## PK result CSV files

- UC04_ScenarioA.csv
- UC04_ScenarioB.csv
