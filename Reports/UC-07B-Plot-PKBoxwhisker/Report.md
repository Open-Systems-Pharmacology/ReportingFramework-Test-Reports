# UC-07B Plot generation: PK Box-Whisker

## Summary

This scenario validates runPlot execution for PK box-whisker plot generation and exports the generated workflow outputs.

## Assertions

- Scenarios configured: UC07B_ScenarioA, UC07B_ScenarioB
- UC07B_PK_Boxplot contains at least one runnable row.
- Selected plotName: AUC_tEnd_t_max
- runPlot(nameOfplotFunction = 'plotPKBoxwhisker') completed without error.
- Returned plot/table objects: 6
- Generated plot files: 4
- UC07B_PK_Boxplot.qmd generated and rendered: UC07B_PK_Boxplot.qmd (manual extraction)

## 
PK Box-Whisker Report

The following content is from the auto-generated UC07B_PK_Boxplot.qmd with the exported figures and captions from the PK box-whisker workflow:

 
```{r}
#| include: false
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, results = "asis", error = FALSE, message = FALSE)
```
 
  
```{r}
#| label: fig-AUC_tEnd_t_max_AUC_tEnd-linear-abs
#| fig-cap: "Population summary statistics of of Aciclovir_PVB disp. Shown as box-whisker plot, which indicates the 5th, 25th, 50th, 75th, 95th percentiles on a linear y-scale"
knitr::include_graphics("UC07B_PK_Boxplot/AUC_tEnd_t_max_AUC_tEnd-linear-abs.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07B_PK_Boxplot", footNoteFile = "AUC_tEnd_t_max_AUC_tEnd-linear-abs.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: fig-AUC_tEnd_t_max_AUC_tEnd-log-abs
#| fig-cap: "Population summary statistics of of Aciclovir_PVB disp. Shown as box-whisker plot, which indicates the 5th, 25th, 50th, 75th, 95th percentiles on a logarithmic y-scale"
knitr::include_graphics("UC07B_PK_Boxplot/AUC_tEnd_t_max_AUC_tEnd-log-abs.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07B_PK_Boxplot", footNoteFile = "AUC_tEnd_t_max_AUC_tEnd-log-abs.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: tbl-AUC_tEnd_t_max_AUC_tEnd-abs
#| tbl-cap: "Population summary statistics of of Aciclovir_PVB disp."
dt <- data.table::fread("UC07B_PK_Boxplot/AUC_tEnd_t_max_AUC_tEnd-abs.csv")
numeric_cols <- names(dt)[sapply(dt, function(x) is.numeric(x) & !is.integer(x))]
if (length(numeric_cols) > 0) dt[, (numeric_cols) := signif(.SD, 3), .SDcols = numeric_cols]
knitr::kable(dt)
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07B_PK_Boxplot", footNoteFile = "AUC_tEnd_t_max_AUC_tEnd-abs.footnote", footNoteCustomStyle = params$customStyles$TableFootnote)
```
\newpage
  
```{r}
#| label: fig-AUC_tEnd_t_max_t_max-linear-abs
#| fig-cap: "Population summary statistics of of Aciclovir_PVB disp. Shown as box-whisker plot, which indicates the 5th, 25th, 50th, 75th, 95th percentiles on a linear y-scale"
knitr::include_graphics("UC07B_PK_Boxplot/AUC_tEnd_t_max_t_max-linear-abs.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07B_PK_Boxplot", footNoteFile = "AUC_tEnd_t_max_t_max-linear-abs.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: fig-AUC_tEnd_t_max_t_max-log-abs
#| fig-cap: "Population summary statistics of of Aciclovir_PVB disp. Shown as box-whisker plot, which indicates the 5th, 25th, 50th, 75th, 95th percentiles on a logarithmic y-scale"
knitr::include_graphics("UC07B_PK_Boxplot/AUC_tEnd_t_max_t_max-log-abs.png")
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07B_PK_Boxplot", footNoteFile = "AUC_tEnd_t_max_t_max-log-abs.footnote", footNoteCustomStyle = params$customStyles$FigureFootnote)
```
\newpage
  
```{r}
#| label: tbl-AUC_tEnd_t_max_t_max-abs
#| tbl-cap: "Population summary statistics of of Aciclovir_PVB disp."
dt <- data.table::fread("UC07B_PK_Boxplot/AUC_tEnd_t_max_t_max-abs.csv")
numeric_cols <- names(dt)[sapply(dt, function(x) is.numeric(x) & !is.integer(x))]
if (length(numeric_cols) > 0) dt[, (numeric_cols) := signif(.SD, 3), .SDcols = numeric_cols]
knitr::kable(dt)
```
```{r}
#| output: asis
ospsuite.reportingframework::mdFootNote(subfolder = "UC07B_PK_Boxplot", footNoteFile = "AUC_tEnd_t_max_t_max-abs.footnote", footNoteCustomStyle = params$customStyles$TableFootnote)
```
\newpage
  

