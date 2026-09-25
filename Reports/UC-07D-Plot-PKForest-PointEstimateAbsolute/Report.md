# UC-07D Plot generation: PK Forest Point Estimate of Absolute Values

## Summary
This use case validates point-estimate PK forest plots for absolute values using the UC07 forest configuration and observed PK overlays.

## Assertions
- Uses the UC07C forest configuration as the source sheet.
- Calls runPlot with plotPKForestPointEstimateOfAbsoluteValues.
- Loads observed PK data from ReportInputs/UC7_observed_PK.csv and aggregates it for forest overlays.

## Result files
- Report.md
- UC07D_PK_Forest_PointEstimate_Absolute.qmd
- Exported PK forest plot files
