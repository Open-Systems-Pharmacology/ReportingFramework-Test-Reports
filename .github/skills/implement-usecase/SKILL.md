---
name: implement-usecase
description: "How to implement a new use case (UC) in the ReportingFramework. Use when: adding a new use case, creating an integration test, documenting a framework workflow, validating framework features."
---

# Implementing a Use Case (UC)

## Overview

A Use Case (UC) is an integration test that validates a specific ReportingFramework workflow. Each UC consists of an R script that executes operations and a markdown report documenting the assertions.

## Implementation Checklist

### 1. Plan Your Use Case
- [ ] Identify what framework feature/workflow you're testing
- [ ] List the key assertions (validation points)
- [ ] Determine required input data
- [ ] Plan output artifacts

### 2. Create R Script

**File location**: `R/report-uc-NN-descriptive-name.R` (where NN is zero-padded number)

**Template structure**:
```r
#' @title report-uc-NN-your-feature-name
#' @description
#' Integration scenario for UC-NN brief description.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

# Setup
reportFolder <- file.path("tests", "Reports", "UC-NN-Your-Feature-Name")
projectDir <- tempfile(pattern = "ucNN_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

# Initialize project
pc <- setupProject(projectDir)

# Perform use case operations
# ... your workflow here ...

# Generate assertions (collect validation data)
assertions <- list(
  assertion1 = "value1",
  assertion2 = "value2"
)

# Save results for report
saveRDS(assertions, file.path(reportFolder, "assertions.rds"))
```

### 3. Key Helper Functions

Available from `helpers-uc-shared.R`:

| Function | Purpose |
|----------|---------|
| `setupProject(projectDir)` | Initialize project with standard structure, returns ProjectConfiguration |
| `copyModelFile(pc, modelFile)` | Copy test model from Models/ to project model folder |
| `makeDefaultScenarioTable(names, indivId, outputId, modelFile)` | Create standard scenario configuration data.table |
| `setupPKPlasmaSheet(pkFile, outputId, extraRows)` | Configure PK parameters |
| `configureOutputsSheet(pc)` | Fill missing output display names/units |
| `assertOrStop(condition, message)` | Validate condition, stop if false |

### 4. Test Data Organization

Store test input files in `Data/test-NNx/` (where x = sub-index):

```
Data/
└── test-NN/
    ├── README.md                 # Describe input files
    ├── input-file.csv
    └── ...additional files...
```

Reference in R script with relative paths:
```r
testDataDir <- "Data/test-NN"
dataFile <- file.path(testDataDir, "input-file.csv")
```

### 5. Create Report Markdown

**File location**: `Reports/UC-NN-Your-Feature-Name/Report.md`

**Required sections**:

```markdown
# UC-NN Descriptive Title

## Summary
Briefly describe what this use case validates (1-2 sentences).

## Assertions
- Assertion point 1: what was tested
- Assertion point 2: what was validated
- Include specific values/counts when meaningful

## Result files
- `filename.csv` - description
- `filename.xlsx` - description
```

**Example**:
```markdown
# UC-03 Simulate, Save and Reload Scenario Results

## Summary
This scenario validates run/save, load, and run-or-load behavior for simulation result CSV files.

## Assertions
- Scenarios configured: UC03_ScenarioA, UC03_ScenarioB
- runAndSaveScenarios created one CSV file per scenario
- loadScenarioResultsToFramework returned results for all scenario names
- runOrLoadScenarios recreated missing CSV with newer timestamp

## Result files
- UC03_ScenarioA.csv
- UC03_ScenarioB.csv
```

## Common Workflow Patterns

### Pattern: Setup, Execute, Compare

```r
# Setup
pc <- setupProject(projectDir)
originalState <- captureState(pc)

# Execute operation
executeOperation(pc)

# Compare/Assert
newState <- captureState(pc)
differences <- compareStates(originalState, newState)
```

### Pattern: Round-trip Testing

```r
# Create and save
create_object(pc)
saved_data <- save_object(pc)

# Load and restore
restored_data <- load_object(pc)

# Validate round-trip
assertOrStop(identical(saved_data, restored_data), 
             "Round-trip failed")
```

### Pattern: Multi-scenario Testing

```r
# Setup scenarios
scenarios <- makeDefaultScenarioTable(
  c("UC_Scenario1", "UC_Scenario2"),
  defaultIndividualId,
  defaultOutputPathId,
  modelFile
)

# Execute for each scenario
results <- lapply(scenarios$scenario_name, function(name) {
  runScenario(pc, name)
})
```

## Best Practices

1. **Numbering**: Use zero-padded sequential numbers (UC-01, UC-02, ..., UC-12)
2. **Naming**: Use kebab-case descriptive names: `report-uc-07b-plot-pk-boxwhisker`
3. **Cleanup**: Always use `on.exit()` for temporary directory cleanup
4. **Assertions**: Make them specific and measurable, not vague
5. **Documentation**: Keep R script comments and Report.md in sync
6. **Modularity**: Reuse helper functions instead of duplicating code
7. **Error Handling**: Use `assertOrStop()` for validation, not silent failures

## Execution & Testing

Run individual use case:
```r
source("R/report-uc-NN-feature.R")
```

Verify report was generated:
```
Reports/UC-NN-Feature/Report.md
```

## Related Files

- [helpers-uc-shared.R](../../R/helpers-uc-shared.R) - Shared helper functions
- [README.md](../../README.md) - Project overview
- [Tests](../../tests/) - Test infrastructure
