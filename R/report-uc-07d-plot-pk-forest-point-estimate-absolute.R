#' @title report-uc-07d-plot-pk-forest-point-estimate-absolute
#' @description
#' Integration scenario for UC-07D PK forest point-estimate plot generation.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")
source("R/helpers-uc-observedData.R")

reportFolder <- file.path(
  "tests",
  "Reports",
  "UC-07D-Plot-PKForest-PointEstimateAbsolute"
)
projectDir <- tempfile(pattern = "uc07d_pkforest_point_absolute_")
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
qmdName <- "UC07D_PK_Forest"

pc <- setupProject(projectDir)

updateUC7Project(
  pc,
  scenarioNames = scenarioNames,
  copyPK = TRUE,
  copySimResult = FALSE
)

scenarioList <- createScenariosWrapped(pc, scenarioNames = scenarioNames)
assertOrStop(length(scenarioList) == 8, "UC-07D requires 8 scenarios")

pkParameterDT <- ospsuite.reportingframework::loadPKParameter(
  pc,
  scenarioListOrResult = scenarioList
)
pkObservedRawDT <- data.table::fread(reportInputsPath("UC7_observed_PK.csv"))
pkObservedDT <- aggregateObservedPKPointEstimateData(pkObservedRawDT)

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
        nameOfplotFunction = "plotPKForestPointEstimateOfAbsoluteValues",
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
    "runPlot(plotPKForestPointEstimateOfAbsoluteValues) failed: ",
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
  nameOfplotFunction = "plotPKForestPointEstimateOfAbsoluteValues",
  configTableSheet = qmdName,
  qmdName = qmdName,
  inputs = list(
    pkParameterDT = pkParameterDT,
    dataObservedPK = pkObservedDT,
    relWidths = c(2, 1)
  )
)

plotFiles <- verifyAndCopyPlots(
  reportFolder = reportFolder,
  outputsRoot = pc$outputFolder,
  qmdNames = qmdName
)

qmdRenderResult <- renderQmdToMarkdown(
  searchFolder = reportFolder,
  pattern = "UC07D_PK_Forest_PointEstimate_Absolute\\.qmd$"
)

reportLines <- c(
  "# UC-07D Plot generation: PK Forest Point Estimate of Absolute Values",
  "",
  "## Summary",
  "",
  "This scenario validates runPlot execution for PK forest point-estimate plots of absolute values using simulated PK data and aggregated observed PK overlays.",
  "",
  "## Assertions",
  "",
  paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
  "- Observed PK data loaded from ReportInputs/UC7_observed_PK.csv and aggregated to geometric mean with 90% CI interval overlays.",
  "- Configuration sheet cloned from UC07C_PK_Forest.",
  paste0("- Selected plotName: ", plotName),
  "- runPlot(nameOfplotFunction = 'plotPKForestPointEstimateOfAbsoluteValues') completed without error.",
  paste0("- Returned plot/table objects: ", returnedPlots),
  paste0("- Generated plot files: ", length(plotFiles)),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC07D_PK_Forest_PointEstimate_Absolute.qmd"
  ),
  "",
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "PK Forest Point-Estimate Report",
    sectionDescription = "The following content is from the auto-generated UC07D_PK_Forest_PointEstimate_Absolute.qmd with the exported figures and captions from the PK forest point-estimate workflow:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
