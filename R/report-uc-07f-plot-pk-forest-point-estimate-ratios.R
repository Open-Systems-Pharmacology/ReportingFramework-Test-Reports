#' @title report-uc-07f-plot-pk-forest-point-estimate-ratios
#' @description
#' Integration scenario for UC-07F point-estimate PK forest ratio plot generation.

rm(list = ls())
library(ospsuite.reportingframework)

source("R/helpers-uc-shared.R")
source("R/helpers-uc-observedData.R")

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
assertOrStop(length(scenarioList) == 8, "UC-07F requires 8 scenarios")

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

  pkForestCall <- tryCatch(
    {
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
    },
    error = function(e) {
      e
    }
  )

  if (inherits(pkForestCall, "error")) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- pkForestCall$message
    next
  }

  coverage$returnedObjects[[i]] <- length(pkForestCall)
  if (coverage$returnedObjects[[i]] == 0) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- "runPlot returned no plot objects"
  }
}

assertOrStop(
  !inherits(pkForestCall, "error"),
  paste0(
    "runPlot(plotPKForestPointEstimateOfRatios) failed: ",
    pkForestCall$message
  )
)
returnedPlots <- if (inherits(pkForestCall, "error")) {
  0
} else {
  length(pkForestCall)
}

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
  pattern = "UC07F_PK_Forest_PointEstimate_Ratios\\.qmd$"
)

reportLines <- c(
  "# UC-07F Plot generation: PK Forest Point Estimate of Ratios",
  "",
  "## Summary",
  "",
  "This scenario validates runPlot execution for point-estimate PK forest ratio plots built as PO / IV comparisons within each population.",
  "",
  "## Assertions",
  "",
  paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
  "- Ratio configuration derived from UC07C_PK_Forest using PO scenarios as numerators and the matching IV scenarios as referenceScenario denominators.",
  "- Observed PK ratios were aggregated from ReportInputs/UC7_observed_PK.csv as PO / IV with geometric mean and 90% CI bounds.",
  paste0("- Selected plotName: ", plotName),
  "- runPlot(nameOfplotFunction = 'plotPKForestPointEstimateOfRatios') completed without error.",
  paste0("- Returned plot/table objects: ", returnedPlots),
  paste0("- Generated plot files: ", length(plotFiles)),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC07F_PK_Forest_PointEstimate_Ratios.qmd"
  ),
  "",
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "PK Forest Point-Estimate Ratios Report",
    sectionDescription = "The following content is from the auto-generated UC07F_PK_Forest_PointEstimate_Ratios.qmd with the exported figures and captions from the point-estimate PO/IV ratio workflow:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
