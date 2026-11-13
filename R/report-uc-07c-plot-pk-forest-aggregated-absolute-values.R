#' @title report-uc-07c-plot-pk-forest-aggregated-absolute-values
#' @description
#' Integration scenario for UC-07C aggregated absolute-value PK forest plot generation.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")
source("R/helpers-uc-observedData.R")

# Prevent accidental creation of Rplots.pdf by using a null default device.
originalDeviceOption <- getOption("device")
options(device = function(...) grDevices::pdf(NULL))
on.exit(options(device = originalDeviceOption), add = TRUE)

reportFolder <- file.path(
  "tests",
  "Reports",
  "UC-07C-Plot-PKForest-AggregatedAbsoluteValues"
)
projectDir <- tempfile(pattern = "uc07c_pkforest_aggregated_absolute_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)


# scenarios used in this use case:
scenarioNames <- c(
  "adolescents_iv",
  "adolescents_po",
  "children_iv",
  "children_po",
  "school_children_iv",
  "school_children_po",
  "toddler_iv",
  "toddler_po"
)

qmdName <- "UC07C_PK_Forest"

pc <- setupProject(projectDir)

updateUC7Project(
  pc,
  scenarioNames = scenarioNames,
  copyPK = TRUE,
  copySimResult = FALSE
)

scenarioList <- createScenariosWrapped(pc, scenarioNames = scenarioNames)
assertOrStop(length(scenarioList) == 8, "UC-07C requires 8 scenarios")


# Load PK parameters from the copied PKAnalysisResults CSV files
pkParameterDT <-
  ospsuite.reportingframework::loadPKParameter(
    pc,
    scenarioListOrResult = scenarioList
  )

pkObservedRawDT <- data.table::fread(reportInputsPath("UC7_observed_PK.csv"))
pkObservedDT <- aggregateObservedPKData(pkObservedRawDT)

setWorkflowOptions(isValidRun = FALSE)

coverage <- loadAndFilterConfigSheet(
  pc,
  sheetName = qmdName
)

# run per plotName to get coverage statistic (plotNames != NULL hinders export)
for (i in seq_len(nrow(coverage))) {
  plotName <- coverage$plotName[[i]]

  pkForestCall <- .runStepWithResult(
    runPlot(
      projectConfiguration = pc,
      nameOfplotFunction = "plotPKForestAggregatedAbsoluteValues",
      configTableSheet = qmdName,
      qmdName = qmdName,
      plotNames = plotName,
      inputs = list(
        pkParameterDT = pkParameterDT,
        dataObservedPK = pkObservedDT
      )
    )
  )

  if (!isTRUE(pkForestCall$success)) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- pkForestCall$error
    next
  }

  coverage$returnedObjects[[i]] <- length(pkForestCall$result)
  if (coverage$returnedObjects[[i]] == 0) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- "runPlot returned no plot objects"
  }
}


assertOrStop(
  !any(coverage$status == "FAIL"),
  paste0(
    "UC-07C plot failures: ",
    paste(coverage$plotName[coverage$status == "FAIL"], collapse = ", ")
  )
)
returnedPlots <-
  sum(as.double(unlist(coverage$returnedObjects)), na.rm = TRUE)

setPlotExportOptions(width = 20)


runPlot(
  projectConfiguration = pc,
  nameOfplotFunction = "plotPKForestAggregatedAbsoluteValues",
  configTableSheet = qmdName,
  qmdName = qmdName,
  inputs = list(
    pkParameterDT = pkParameterDT,
    dataObservedPK = pkObservedDT
  )
)

plotFiles <- verifyAndCopyPlots(
  reportFolder = reportFolder,
  outputsRoot = pc$outputFolder,
  qmdNames = qmdName
)

qmdRenderResult <- renderQmdToMarkdown(
  searchFolder = reportFolder,
  pattern = "UC07C_PK_Forest\\.qmd$"
)

reportLines <- c(
  "# UC-07C Plot generation: PK Forest Aggregated Absolute Values",
  "",
  "## Summary",
  "",
  "This scenario validates aggregated absolute-value PK forest plot generation using runPlot() with simulated PK parameters and stable observed PK aggregates for forest-plot overlays.",
  "",
  "## Assertions",
  "",
  paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
  "- Observed PK data loaded from ReportInputs/UC7_observed_PK.csv and aggregated to the package's pkAggregated format.",
  "- UC07C_PK_Forest configuration sheet contains runnable plot definitions.",
  "- All runPlot(nameOfplotFunction = 'plotPKForestAggregatedAbsoluteValues') calls completed without error.",
  paste0("- Returned plot/table objects from final execution: ", returnedPlots),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC07C_PK_Forest_Aggregated_Absolute_Values.qmd"
  ),
  coverageReportSection(coverage, qmdName),
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "PK Forest Aggregated Absolute Values Report",
    sectionDescription = "The following content is from the auto-generated UC07C_PK_Forest_Aggregated_Absolute_Values.qmd with the exported figures and captions from the aggregated absolute-value PK forest workflow:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))

