# UC-10 Sensitivity Analysis

## Summary

This scenario validates the sensitivity analysis functionality for generating
parameter sensitivity plots. The sensitivity analysis identifies how variations in
input parameters affect model outputs, which is critical for regulatory submissions
and understanding model behavior.

## Functionality Validation

### Available Sensitivity Analysis Functions

#### Main Sensitivity Plot Function
- `plotSensitivity()`: Generates sensitivity plots for selected parameters
  - Input: Project configuration, plot configuration, scenario list
  - Output: Sensitivity plots showing parameter impact on model outputs
  - Features: Tornado plots, sensitivity indices, parameter rankings

#### Data Preparation
- `prepareSensitivityPlotData()`: Prepares sensitivity data for plotting
  - Input: Project configuration, scenario list, sensitivity parameter sheet
  - Output: Data table with sensitivity metrics per parameter
  - Handles: CSV import, data normalization, metric calculations

#### Naming and Configuration
- `sensitivityAnalysisName()`: Derives sensitivity analysis file names
  - Input: Scenario, sensitivity parameter sheet identifier
  - Output: Standardized file name for sensitivity results

## Project Configuration

- Project Directory: C:\Users\17fec1a5\AppData\Local\Temp\2\RtmpGeatJ9\uc10_sensitivity_2e1019131dce
- Configuration Path: C:\Users\17fec1a5\AppData\Local\Temp\2\RtmpGeatJ9\uc10_sensitivity_2e1019131dce/Scripts/ReportingFramework/ProjectConfiguration.xlsx
- Model File: Aciclovir.pkml
- Model Path: C:/Users/17fec1a5/AppData/Local/Temp/2/RtmpGeatJ9/uc10_sensitivity_2e1019131dce/Models/Aciclovir.pkml
- Sensitivity Results: 

## Validations Performed

✓ Project initialization successful
✓ Project configuration created
✓ Scenario configuration loaded
✓ Model file copied to project
✓ Sensitivity results directory created
✓ plotSensitivity() function available
✓ prepareSensitivityPlotData() function available
✓ sensitivityAnalysisName() function available

## Sensitivity Analysis Workflow

### Step 1: Configuration
Define which parameters to analyze via sensitivity parameter sheets in ProjectConfiguration.xlsx
Specify output names and plot characteristics (tornado layout, thresholds, etc.)

### Step 2: Execute Scenarios
Run scenarios through simulation or PK analysis pipeline
Sensitivity analysis results are saved to sensitivityResults folder in CSV format

### Step 3: Generate Plots
```r
plotSensitivity(
  projectConfiguration = pc,
  onePlotConfig = plotConfig,
  scenarioList = scenarios
)
```
Produces tornado plots and sensitivity ranking visualizations

### Step 4: Integration
Plots are automatically integrated into markdown reports via runPlot()
Captions and cross-references are generated from plot configuration

## Tornado Plot Components

- **Parameter Axis**: Shows evaluated parameters with +/- variations
- **Output Range**: Visualizes minimum and maximum output values
- **Sensitivity Ranking**: Parameters ordered by impact magnitude
- **Reference Value**: Baseline output shown for comparison

## File Outputs

- **Sensitivity CSV**: Raw sensitivity metrics per parameter per scenario
  - Columns: Parameter, Output, LowerValue, UpperValue, Range
- **Plot Objects**: ggplot2 objects ready for rendering
- **Sensitivity Tables**: Summary statistics for report inclusion

## Typical Use Cases

1. **Regulatory Submissions**: Document parameter uncertainty impact
2. **Model Development**: Identify critical model parameters
3. **PK Analysis**: Support PK profile interpretation in populations
4. **Risk Assessment**: Quantify parameter-dependent variability in predictions

