# UC-07A Plot generation: Time Profiles

## Summary

This scenario validates representative time-profile variant families for mean models.

## Assertions

- Scenarios configured: Set1, Set1_Reference, Set2_OD
- UC07A_TimeProfiles contains one representative row for each variant family.
- All family-specific runPlot(nameOfplotFunction = 'plotTimeProfiles') calls completed without hard errors.

## Family Coverage

| Family | Representative Plot Name | Status | Returned Objects |
|---|---|---|---:|
| single-without-data | singlePlot_withoutData | PASS | 2 |
| single-with-data | singlePlot_withData | PASS | 12 |
| single-with-reference | singlePlot_withReference | PASS | 2 |
| single-with-offset | singlePlot_withOffset | PASS | 2 |
| single-with-limits | singlePlot_withLimits | PASS | 2 |
| multidose-time-ranges | multiDosePlot | PASS | 6 |
| many-panel-fixed | manyPanelPlot | PASS | 2 |
| many-panel-free-col3 | manyPanelPlot_col3 | PASS | 2 |
| single-without-data | manyPanelPlot_col3 | PASS | 2 |
