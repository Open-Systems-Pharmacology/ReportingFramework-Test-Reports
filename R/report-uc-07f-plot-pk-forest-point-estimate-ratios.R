#' @title report-uc-07f-plot-pk-forest-point-estimate-ratios
#' @description
#' Integration scenario for UC-07F point-estimate PK forest ratio plot generation.

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
  "UC-07F-Plot-PKForest-PointEstimateRatios"
)
projectDir <- tempfile(pattern = "uc07f_pkforest_ratio_point_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

scenarioNames <- c(
  "adults_po",
  "adolescents_iv",
  "adolescents_po",
  "children_iv",
  "children_po",
  "school_children_iv",
  "school_children_po",
  "toddler_iv",
  "toddler_po"
)
qmdName <- "UC07F_PK_Forest"

pc <- setupProject(projectDir)

updateUC7Project(
  pc,
  scenarioNames = scenarioNames,
  copyPK = TRUE,
  copySimResult = FALSE
)

scenarioList <- createScenariosWrapped(pc, scenarioNames = scenarioNames)
assertOrStop(length(scenarioList) == 9, "UC-07F requires 9 scenarios")

pkParameterDT <- ospsuite.reportingframework::loadPKParameter(
  pc,
  scenarioListOrResult = scenarioList
)
pkObservedRawDT <- data.table::fread(reportInputsPath("UC7_observed_PK.csv"))
pkObservedDT <- aggregateObservedPKPointEstimateRatioData(pkObservedRawDT)

setWorkflowOptions(isValidRun = FALSE)

coverage <- loadAndFilterConfigSheet(
  pc,
  sheetName = qmdName
)

for (i in seq_len(nrow(coverage))) {
  plotName <- coverage$plotName[[i]]

  pkForestCall <- runStepWithResult(
    runPlot(
      projectConfiguration = pc,
      nameOfplotFunction = "plotPKForestPointEstimateOfRatios",
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
    "UC-07F plot failures: ",
    paste(coverage$plotName[coverage$status == "FAIL"], collapse = ", ")
  )
)
returnedPlots <-
  sum(as.double(unlist(coverage$returnedObjects)), na.rm = TRUE)

setPlotExportOptions(width = 20)

runPlot(
  projectConfiguration = pc,
  nameOfplotFunction = "plotPKForestPointEstimateOfRatios",
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
  pattern = qmdName
)

reportLines <- c(
  "# UC-07F Plot generation: PK Forest Point Estimate of Ratios",
  "",
  "## Summary",
  "",
  "This scenario validates point-estimate PK forest ratio plot generation using runPlot() for PO / IV comparisons within each population.",
  "",
  "## Assertions",
  "",
  paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
  "- Ratio configuration derived from UC07C_PK_Forest using PO scenarios as numerators and the matching IV scenarios as referenceScenario denominators.",
  "- Observed PK ratios were aggregated from ReportInputs/UC7_observed_PK.csv as PO / IV with geometric mean and 90% CI bounds.",
  "- UC07F_PK_Forest configuration sheet contains runnable plot definitions.",
  "- All runPlot(nameOfplotFunction = 'plotPKForestPointEstimateOfRatios') calls completed without error.",
  paste0("- Returned plot/table objects from final execution: ", returnedPlots),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC07F_PK_Forest_PointEstimate_Ratios.qmd"
  ),
  coverageReportSection(coverage, qmdName),
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "PK Forest Point-Estimate Ratios Report",
    sectionDescription = "The following content is from the auto-generated UC07F_PK_Forest_PointEstimate_Ratios.qmd with the exported figures and captions from the point-estimate PO/IV ratio workflow:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
