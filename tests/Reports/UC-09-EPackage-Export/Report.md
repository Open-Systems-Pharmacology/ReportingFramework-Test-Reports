# UC-09 Electronic Package (ePackage) Export

## Summary

This scenario validates the electronic package (ePackage) export functionality.
The ePackage mechanism enables creation of self-contained, reproducible workflows
for simulation and TLF (Table/List/Figure) generation in regulatory submissions.

## Functionality Validation

### Available ePackage Functions

The following functions are available for ePackage workflow management:

#### Simulation Workflow Export
- `exportSimulationWorkflowToEPackage()`: Exports simulation workflows to an ePackage
  - Input: Project configuration, workflow identifier, scenario names
  - Output: Self-contained package with model, data, and configuration files
  - Use case: Time-consuming workflows executed once, standardized execution

#### TLF Workflow Export
- `exportTLFWorkflowToEPackage()`: Exports table/list/figure generation workflows
  - Input: Project configuration, workflow identifier, workflow R Markdown file
  - Output: Package with all code, data, and configuration for reproducible reports
  - Use case: Fast-running workflows, frequently customized during review cycles

#### Template Support
- `openEPackageTemplate()`: Opens RStudio addin for ePackage workflow template
  - Provides structured template for creating new ePackage workflows
  - Available via RStudio Addins menu

## Project Configuration

- Project Directory: tests/Reports/UC-09-EPackage-Export/project
- ePackage Folder: C:/Users/17fec1a5/Documents/GitHub/ReportingFramework-Test-Reports/tests/Reports/UC-09-EPackage-Export/project/Outputs/ePackage/AnalysisProgram
- Model File: Aciclovir.pkml
- Model Path: C:/Users/17fec1a5/Documents/GitHub/ReportingFramework-Test-Reports/tests/Reports/UC-09-EPackage-Export/project/Models/Aciclovir.pkml

## Validations Performed

✓ Project initialization successful
✓ Project configuration created
✓ Model file copied to project
✓ ePackage folder exists and is accessible
✓ exportSimulationWorkflowToEPackage() function available
✓ exportTLFWorkflowToEPackage() function available
✓ openEPackageTemplate() function available

## Workflow Execution Patterns

### Pattern We1: Export Simulation Workflow
```
exportSimulationWorkflowToEPackage(
  projectConfiguration = pc,
  wfIdentifier = 1,
  scenarioNames = c('scenario1', 'scenario2')
)
```
Creates: w1_workflow_r.txt, configuration files, model and data files

### Pattern W1: Execute Simulation Workflow
```
# Within ePackage:
# 1. importWorkflow() - imports all necessary files and configuration
# 2. Scenario simulation - runs OSPSuite simulations
# 3. Cleanup - removes temporary files
```

### Pattern We2: Export TLF Workflow
```
exportTLFWorkflowToEPackage(
  projectConfiguration = pc,
  wfIdentifier = 2,
  workflowRmd = 'path/to/workflow.Rmd'
)
```
Creates: w2_workflow_r.txt, configuration files, R Markdown workflow

### Pattern W2: Execute TLF Workflow
```
# Within ePackage:
# 1. importWorkflow() - imports all necessary files and configuration
# 2. Knit workflow - generates tables, lists, and figures
# 3. Cleanup - removes temporary files
```

## ePackage Contents Structure

Exported ePackages contain:
- Workflow script (w<N>_workflow_r.txt)
- Project configuration (JSON files)
- Model files (PKML format)
- Population files (CSV format)
- Configuration sheets (CSV/JSON format)
- Input files metadata (CSV)

## Notes

- ePackage exports are typically part of a multi-step workflow:
  1. We1/We2: Workflow export in development environment
  2. W1/W2: Workflow execution in regulatory/submission environment
  3. A1: Report/appendix generation from outputs

- All exported files are validated for naming conventions and format compatibility
- Supports direct use in regulatory submissions (FDA, EMA formats)
- Ensures reproducibility through standardized file organization