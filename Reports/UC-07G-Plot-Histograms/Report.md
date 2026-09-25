# UC-07G Plot generation: Histograms

## Summary

This scenario validates runPlot execution for demographic plot generation and exports the generated workflow outputs.

## Assertions

- Scenarios configured: UC07G_ScenarioA
- Exported population: TestPopulation
- PK parameters available: AUC_tEnd, t_max
- UC07G_Histograms contains at least one runnable row.
- Selected histogram plotName: pkparameter1
- runPlot(nameOfplotFunction = 'plotHistograms') completed without error.
- Returned histogram plot/table objects: 4
- UC07G_DistVsDemo contains at least one runnable row.
- Selected distribution-vs-demographics plotName: pkparameter1
- runPlot(nameOfplotFunction = 'plotDistributionVsDemographics') completed without error.
- Returned distribution-vs-demographics plot/table objects: 0
- Generated plot files: 7
- UC07G_Histograms.qmd generated and rendered: UC07G_Histograms.qmd (manual extraction)

## 
Histogram Report

The following content is from the auto-generated UC07G_Histograms.qmd with the exported figures and captions from the demographic histogram workflow:

 
```{r}
#| include: false
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, results = "asis", error = FALSE, message = FALSE)
```
 
  
```{r}
#| label: fig-demographics_weight_linear
#| fig-cap: "Simulated body weight for NA on a linear x-scale."
knitr::include_graphics("UC07G_Histograms/demographics_weight_linear.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07G_Histograms", footNoteFile = "demographics_weight_linear.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: fig-demographics_height_linear
#| fig-cap: "Simulated height for NA on a linear x-scale."
knitr::include_graphics("UC07G_Histograms/demographics_height_linear.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07G_Histograms", footNoteFile = "demographics_height_linear.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: fig-demographics_BMI_linear
#| fig-cap: "Simulated BMI for NA on a linear x-scale."
knitr::include_graphics("UC07G_Histograms/demographics_BMI_linear.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07G_Histograms", footNoteFile = "demographics_BMI_linear.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
  
  
  
# PK Parameter  
  
  
```{r}
#| label: fig-pkparameter1_AUC_tEnd_linear
#| fig-cap: "Simulated AUC of Aciclovir_PVB disp for UC07G ScenarioA on a linear x-scale."
knitr::include_graphics("UC07G_Histograms/pkparameter1_AUC_tEnd_linear.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07G_Histograms", footNoteFile = "pkparameter1_AUC_tEnd_linear.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: fig-pkparameter1_AUC_tEnd_log
#| fig-cap: "Simulated AUC of Aciclovir_PVB disp for UC07G ScenarioA on a logarithmic x-scale."
knitr::include_graphics("UC07G_Histograms/pkparameter1_AUC_tEnd_log.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07G_Histograms", footNoteFile = "pkparameter1_AUC_tEnd_log.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: fig-pkparameter1_t_max_linear
#| fig-cap: "Simulated T max of Aciclovir_PVB disp for UC07G ScenarioA on a linear x-scale."
knitr::include_graphics("UC07G_Histograms/pkparameter1_t_max_linear.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07G_Histograms", footNoteFile = "pkparameter1_t_max_linear.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: fig-pkparameter1_t_max_log
#| fig-cap: "Simulated T max of Aciclovir_PVB disp for UC07G ScenarioA on a logarithmic x-scale."
knitr::include_graphics("UC07G_Histograms/pkparameter1_t_max_log.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07G_Histograms", footNoteFile = "pkparameter1_t_max_log.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  


