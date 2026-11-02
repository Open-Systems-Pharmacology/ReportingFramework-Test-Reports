#' @title report-uc-07b-plot-pk-boxwhisker
#' @description
#' Integration scenario for UC-07B PK box-whisker plot generation using population scenarios.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

# Prevent accidental creation of Rplots.pdf by using a null default device.
originalDeviceOption <- getOption("device")
options(device = function(...) grDevices::pdf(NULL))
on.exit(options(device = originalDeviceOption), add = TRUE)


reportFolder <- file.path("tests", "Reports", "UC-07B-Plot-PKBoxwhisker")
projectDir <- tempfile(pattern = "uc07b_pkbox_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

pc <- setupProject(projectDir)

# scenarios used in this use case:
scenarioNames <- c("adults_iv", "adults_po")
qmdName <- "UC07B_PK_Boxplot"

updateUC7Project(
  pc,
  scenarioNames = scenarioNames,
  copyPK = TRUE,
  copySimResult = FALSE
)

scenarioList <- createScenariosWrapped(pc, scenarioNames = scenarioNames)
assertOrStop(length(scenarioList) == 2, "UC-07b requires two scenarios")

# Load PK parameters from the copied PKAnalysisResults CSV files
pkParameterDT <- ospsuite.reportingframework::loadPKParameter(
  pc,
  scenarioListOrResult = scenarioList
)

setWorkflowOptions(isValidRun = FALSE)

themeToUse <-
  theme(legend.position = "top", legend.title = element_blank())
options(knitr.kable.NA = "")

coverage <- loadAndFilterConfigSheet(
  pc,
  sheetName = qmdName
)

# run per plotName to get coverage statistic (plotNames != NULL hinders export)
for (i in seq_len(nrow(coverage))) {
  plotName <- coverage$plotName[[i]]

  pkBoxCall <- runStepWithResult(
    runPlot(
      projectConfiguration = pc,
      nameOfplotFunction = "plotPKBoxwhisker",
      configTableSheet = qmdName,
      qmdName = qmdName,
      plotNames = plotName,
      theme = themeToUse,
      inputs = list(
        pkParameterDT = pkParameterDT,
        colorVector = c("IV" = NA, "PO" = NA)
      )
    )
  )

  if (!isTRUE(pkBoxCall$success)) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- pkBoxCall$error
    next
  }

  coverage$returnedObjects[[i]] <- length(pkBoxCall$result)
  if (coverage$returnedObjects[[i]] == 0) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- "runPlot returned no plot objects"
  }
}

assertOrStop(
  !any(coverage$status == "FAIL"),
  paste0(
    "UC-07B plot failures: ",
    paste(coverage$plotName[coverage$status == "FAIL"], collapse = ", ")
  )
)
returnedPlots <-
  sum(as.double(unlist(coverage$returnedObjects)), na.rm = TRUE)

setPlotExportOptions(width = 20)

# export Plots

runPlot(
  projectConfiguration = pc,
  nameOfplotFunction = "plotPKBoxwhisker",
  configTableSheet = qmdName,
  qmdName = qmdName,
  theme = themeToUse,
  inputs = list(pkParameterDT = pkParameterDT)
)

plotFiles <- verifyAndCopyPlots(
  reportFolder = reportFolder,
  outputsRoot = pc$outputFolder,
  qmdNames = qmdName
)

qmdRenderResult <- renderQmdToMarkdown(
  searchFolder = reportFolder,
  pattern = "UC07B_PK_Boxplot\\.qmd$"
)

reportLines <- c(
  "# UC-07B Plot generation: PK Box-Whisker",
  "",
  "## Summary",
  "",
  "This scenario validates PK box-whisker plot generation using runPlot() with population-based pharmacokinetic parameters. Plots display the distribution of key PK parameters across multiple individuals and are exported for reporting.",
  "",
  "## Approach",
  "",
  "- Uses pre-computed PK analysis results from population simulations in repo-local ReportInputs folder.",
  "- Loads PK parameters from PKAnalysisResults CSV files for multiple individuals across population scenarios.",
  "- Generates PK box-whisker plots showing parameter distributions using runPlot(nameOfplotFunction = 'plotPKBoxwhisker').",
  "- Exports plots and generates Quarto markdown report with figures and captions.",
  "",
  "## Assertions",
  "",
  paste0(
    "- Population scenarios configured: ",
    paste(scenarioNames, collapse = ", ")
  ),
  "- PK parameter data loaded from PKAnalysisResults CSV files.",
  paste0("- Total PK parameter records: ", nrow(pkParameterDT)),
  "- UC07B_PK_Boxplot configuration sheet contains runnable plot definitions.",
  "- All runPlot(nameOfplotFunction = 'plotPKBoxwhisker') calls completed without error.",
  paste0("- Returned plot/table objects from final execution: ", returnedPlots),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC07B_PK_Boxplot.qmd"
  ),
  coverageReportSection(coverage, qmdName),
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "Generated PK Box-Whisker Report",
    sectionDescription = "The following content is from the auto-generated UC07B_PK_Boxplot.qmd with exported figures and captions:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
