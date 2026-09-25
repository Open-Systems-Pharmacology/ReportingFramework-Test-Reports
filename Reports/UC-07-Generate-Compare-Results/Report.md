# UC-07 Generate and compare UC7 results

## Summary
This use case regenerates the simulation and PK analysis outputs consumed by the fixture-backed UC07 plot workflows and compares the generated CSV outputs against the repo-local baseline files in ReportInputs.

## Assertions
- Uses the shared UC7 project configuration via `updateUC7Project()`.
- Generates scenario outputs with `runAndSaveScenarios()` instead of copying presimulated files into the working project.
- Compares generated simulation, population, and PK analysis CSV files against the UC7 baseline fixtures.
- Records PK parameter-set differences when the current package build and the stored fixtures expose different parameter coverage.

## Result files
- Scenario simulation CSV files for adult and pediatric UC07 scenarios
- Scenario population CSV files for the same scenarios
- Scenario PK analysis CSV files for the same scenarios