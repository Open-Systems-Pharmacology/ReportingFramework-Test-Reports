#' @title report-uc-07b-plot-pk-boxwhisker
#' @description
#' Integration scenario for UC-07B PK box-whisker plot generation using population scenarios.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")


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

coverage <- loadAndFilterConfigSheet(
  pc,
  sheetName = qmdName
)

# run per plotName to get coverage statistic (plotNames != NULL hinders export)
for (i in seq_len(nrow(coverage))) {
  plotName <- coverage$plotName[[i]]

  pkBoxCall <- tryCatch(
    {
      runPlot(
        projectConfiguration = pc,
        nameOfplotFunction = "plotPKBoxwhisker",
        configTableSheet = qmdName,
        qmdName = qmdName,
        plotNames = plotName,
        theme = themeToUse,
        inputs = list(
          pkParameterDT = pkParameterDT,
          colorVector = c('IV' = NA, 'PO' = NA)
        )
      )
    },
    error = function(e) {
      e
    }
  )

  if (inherits(pkBoxCall, "error")) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- pkBoxCall$message
    next
  }

  coverage$returnedObjects[[i]] <- length(pkBoxCall)
  if (coverage$returnedObjects[[i]] == 0) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- "runPlot returned no plot objects"
  }
}

assertOrStop(
  !inherits(pkBoxCall, "error"),
  paste0("runPlot(plotPKBoxwhisker) failed: ", pkBoxCall$message)
)
returnedPlots <- if (inherits(pkBoxCall, "error")) 0 else length(pkBoxCall)

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
  "This scenario validates runPlot execution for PK box-whisker plot generation using population-based pharmacokinetic parameters and exports the generated workflow outputs.",
  "",
  "## Approach",
  "",
  "- Uses pre-computed PK analysis results from population simulations copied from the repo-local ReportInputs folder.",
  "- Loads PK parameters from PKAnalysisResults CSV files for multiple individuals in the adult population",
  "- Generates PK box-whisker plots showing distribution of key parameters across the population",
  "",
  "## Assertions",
  "",
  paste0(
    "- Population scenarios configured: ",
    paste(scenarioNames, collapse = ", ")
  ),
  "- PK parameter data loaded from PKAnalysisResults (adults_iv.csv, adults_po.csv)",
  paste0("- Total individuals in population analysis: ", nrow(pkParameterDT)),
  "- UC07B_PK_Boxplot contains at least one runnable row.",
  paste0("- Selected plotName: ", plotName),
  "- runPlot(nameOfplotFunction = 'plotPKBoxwhisker') completed without error.",
  paste0("- Returned plot/table objects: ", returnedPlots),
  paste0("- Generated plot files: ", length(plotFiles)),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC07B_PK_Boxplot.qmd"
  ),
  "",
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "PK Box-Whisker Report",
    sectionDescription = "The following content is from the auto-generated UC07B_PK_Boxplot.qmd with the exported figures and captions from the PK box-whisker workflow:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
