# UC-03 Simulate, save and reload scenario results

## Summary

This scenario validates run/save, load, and run-or-load behavior for simulation result CSV files.

## Assertions

- Scenarios configured: UC03_ScenarioA, UC03_ScenarioB
- runAndSaveScenarios created one CSV file per scenario.
- loadScenarioResultsToFramework returned results for all scenario names.
- Deleted scenario CSV before runOrLoadScenarios: UC03_ScenarioA
- runOrLoadScenarios returned results for all scenarios and recreated the missing CSV.
- Recomputed CSV has a newer timestamp than retained CSV files.

## Result CSV files

- UC03_ScenarioA.csv
- UC03_ScenarioB.csv
