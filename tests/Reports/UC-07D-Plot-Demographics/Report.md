# UC-07D Plot generation: Demographics

## Summary

This scenario validates runPlot execution for demographic plot generation.

## Assertions

- Scenarios configured: UC07D_ScenarioA
- Exported population: TestPopulation
- PK parameters available: AUC_tEnd, t_max
- UC07D_Histograms contains at least one runnable row.
- Selected histogram plotName: pkparameter1
- runPlot(nameOfplotFunction = 'plotHistograms') completed without error.
- Returned histogram plot/table objects: 0
- UC07D_DistVsDemo contains at least one runnable row.
- Selected distribution-vs-demographics plotName: pkparameter1
- runPlot(nameOfplotFunction = 'plotDistributionVsDemographics') completed without error.
- Returned distribution-vs-demographics plot/table objects: 0
