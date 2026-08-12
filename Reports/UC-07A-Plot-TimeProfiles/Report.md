# UC-07A Plot generation: Time Profiles

## Summary

This scenario validates representative time-profile variant families derived from external config_timeprofiles.csv.
Source variants: H:/VP_auxiliary_functions/plotTimeProfile/tests/testthat/testdata/config_timeprofiles.csv

## Assertions

- Scenarios configured: Set1, Set1_Reference, Set2_OD
- UC07A_TimeProfiles contains one representative row for each variant family.
- All family-specific runPlot(nameOfplotFunction = 'plotTimeProfiles') calls completed without hard errors.

## Family Coverage

| Family | Representative Plot Name | Status | Returned Objects |
|---|---|---|---:|
| single-without-data | singlePlot_withoutData | PASS | 0 |
| single-with-data | singlePlot_withData | PASS | 0 |
| single-with-reference | singlePlot_withReference | PASS | 0 |
| single-with-offset | singlePlot_withOffset | PASS | 0 |
| single-with-limits | singlePlot_withLimits | PASS | 0 |
| multidose-time-ranges | multiDosePlot | PASS | 0 |
| many-panel-fixed | manyPanelPlot | PASS | 0 |
| many-panel-free-col3 | manyPanelPlot_col3 | PASS | 0 |
