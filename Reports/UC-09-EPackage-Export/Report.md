# UC-09 Electronic Package (ePackage) Export

## Summary

This scenario validates ePackage export for both simulation and TLF workflows.
It exports each workflow, executes the exported runner script, and checks
that the expected files are recreated or generated from the exported package.

## Assertions

- Scenarios created: `UC09_Scenario1`, `UC09_PopulationScenario`
- Population CSV source assigned to `UC09_PopulationScenario`: `adults.csv`
- Simulation workflow export succeeds and creates `w1_workflow_r.txt`
- Exported simulation workflow executes without error
- Exported simulation workflow recreates `UC09_Scenario1.csv` and `UC09_PopulationScenario.csv`
- Exported simulation workflow recreates `UC09_PopulationScenario_population.csv`
- TLF workflow export succeeds and creates `w2_workflow_r.txt`
- Exported TLF workflow executes without error
- Exported TLF workflow creates `UC09_TLF_Summary.csv` and `UC09_TLF_Summary.txt`
- ePackage contains only `.txt`, `.xml`, and `.json` files

## Exported Workflow Files

- Workflow runners: `w1_workflow_r.txt`, `w2_workflow_r.txt`
- Input manifests: `w1_input_files_csv.txt`, `w2_input_files_csv.txt`
- Configuration files: `w1_config_json.txt`, `w2_config_json.txt`

## Execution Outputs

- Simulation workflow output files verified: `UC09_Scenario1.csv`, `UC09_PopulationScenario.csv`
- Renamed population CSV verified: `UC09_PopulationScenario_population.csv`
- TLF workflow output files verified: `UC09_TLF_Summary.csv`, `UC09_TLF_Summary.txt`