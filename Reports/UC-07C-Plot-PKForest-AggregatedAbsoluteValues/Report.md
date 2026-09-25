# UC-07C Plot generation: PK Forest Aggregated Absolute Values

## Summary

This scenario validates runPlot execution for aggregated absolute-value PK forest plots and exports the generated workflow outputs.

## Assertions

- Scenarios configured: UC07C_ScenarioA, UC07C_ScenarioB
- Configuration sheet cloned from UC07C_PK_Forest_Aggregated_Absolute_Values.
- Selected plotName: PKForest
- runPlot(nameOfplotFunction = 'plotPKForestAggregatedAbsoluteValues') completed without error.
- Returned plot/table objects: 4
- Generated plot files: 4
- UC07C_PK_Forest_Aggregated_Absolute_Values_Aggregated_Absolute_Values.qmd generated and rendered: UC07C_PK_Forest_Aggregated_Absolute_Values_Aggregated_Absolute_Values.qmd (manual extraction)

## 
PK Forest Aggregated Absolute Values Report

The following content is from the auto-generated UC07C_PK_Forest_Aggregated_Absolute_Values_Aggregated_Absolute_Values.qmd with the exported figures and captions from the aggregated absolute-value PK forest workflow:

 
```{r}
#| include: false
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, results = "asis", error = FALSE, message = FALSE)
```
 
  
```{r}
#| label: fig-PKForest-AUC_tEnd-linear
#| fig-cap: "Simulated AUC of Aciclovir_PVB disp on a linear x-scale. Number of simulated values is 1 for all scenarios."
knitr::include_graphics("UC07C_PK_Forest_Aggregated_Absolute_Values/PKForest-AUC_tEnd-linear.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07C_PK_Forest_Aggregated_Absolute_Values", footNoteFile = "PKForest-AUC_tEnd-linear.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: fig-PKForest-AUC_tEnd-log
#| fig-cap: "Simulated AUC of Aciclovir_PVB disp on a logarithmic x-scale. Number of simulated values is 1 for all scenarios."
knitr::include_graphics("UC07C_PK_Forest_Aggregated_Absolute_Values/PKForest-AUC_tEnd-log.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07C_PK_Forest_Aggregated_Absolute_Values", footNoteFile = "PKForest-AUC_tEnd-log.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: fig-PKForest-t_max-linear
#| fig-cap: "Simulated T max of Aciclovir_PVB disp on a linear x-scale. Number of simulated values is 1 for all scenarios."
knitr::include_graphics("UC07C_PK_Forest_Aggregated_Absolute_Values/PKForest-t_max-linear.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07C_PK_Forest_Aggregated_Absolute_Values", footNoteFile = "PKForest-t_max-linear.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: fig-PKForest-t_max-log
#| fig-cap: "Simulated T max of Aciclovir_PVB disp on a logarithmic x-scale. Number of simulated values is 1 for all scenarios."
knitr::include_graphics("UC07C_PK_Forest_Aggregated_Absolute_Values/PKForest-t_max-log.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07C_PK_Forest_Aggregated_Absolute_Values", footNoteFile = "PKForest-t_max-log.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  


