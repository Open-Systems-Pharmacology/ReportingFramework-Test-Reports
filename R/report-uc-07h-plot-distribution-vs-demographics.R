#' @title report-uc-07h-plot-distribution-vs-demographics
#' @description
#' Integration scenario for UC-07H distribution vs demographics plot generation.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

# Prevent accidental creation of Rplots.pdf by using a null default device.
originalDeviceOption <- getOption("device")
options(device = function(...) grDevices::pdf(NULL))
on.exit(options(device = originalDeviceOption), add = TRUE)

reportFolder <- file.path(
  "tests",
  "Reports",
  "UC-07H-Plot-DistributionVsDemographics"
)
projectDir <- tempfile(pattern = "uc07h_dist_vs_demo_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

scenarioNames <- c(
  "adults_iv",
  "adolescents_iv",
  "children_iv",
  "school_children_iv",
  "toddler_iv"
)
qmdNames <- c(
  "UC07H_DistVsDemo_StepPlot",
  "UC07H_DistVsDemo_RangePlot"
)
configSheetName <- "UC07H_DistVsDemo"

pc <- setupProject(projectDir)

updateUC7Project(
  pc,
  scenarioNames = scenarioNames,
  copyPK = TRUE,
  copySimResult = FALSE
)

scenarioList <- createScenariosWrapped(pc, scenarioNames = scenarioNames)
assertOrStop(length(scenarioList) == 5, "UC-07H requires 5 scenarios")

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
  sheetName = configSheetName
)

for (i in seq_len(nrow(coverage))) {
  plotName <- coverage$plotName[[i]]

  rangeCall <- .runStepWithResult(
    runPlot(
      projectConfiguration = pc,
      nameOfplotFunction = "plotDistributionVsDemographics",
      configTableSheet = configSheetName,
      qmdName = qmdNames[[1]],
      plotNames = plotName,
      theme = themeToUse,
      inputs = list(
        scenarioList = scenarioList,
        pkParameterDT = pkParameterDT,
        aggregationFlag = "GeometricStdDev",
        asStepPlot = TRUE
      )
    )
  )

  if (!isTRUE(rangeCall$success)) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- rangeCall$error
    next
  }

  coverage$returnedObjects[[i]] <- length(rangeCall$result)
  if (coverage$returnedObjects[[i]] == 0) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- "runPlot returned no plot objects"
  }
}

assertOrStop(
  !any(coverage$status == "FAIL"),
  paste0(
    "UC-07H plot failures: ",
    paste(coverage$plotName[coverage$status == "FAIL"], collapse = ", ")
  )
)
returnedPlots <-
  sum(as.double(unlist(coverage$returnedObjects)), na.rm = TRUE)

setPlotExportOptions(width = 20)

# Run plot with asStepPlot = TRUE
runPlot(
  projectConfiguration = pc,
  nameOfplotFunction = "plotDistributionVsDemographics",
  configTableSheet = configSheetName,
  qmdName = qmdNames[[1]],
  theme = themeToUse,
  inputs = list(
    scenarioList = scenarioList,
    pkParameterDT = pkParameterDT,
    aggregationFlag = "GeometricStdDev",
    asStepPlot = TRUE
  )
)

# Run plot with asStepPlot = FALSE
runPlot(
  projectConfiguration = pc,
  nameOfplotFunction = "plotDistributionVsDemographics",
  configTableSheet = configSheetName,
  qmdName = qmdNames[[2]],
  theme = themeToUse,
  inputs = list(
    scenarioList = scenarioList,
    pkParameterDT = pkParameterDT,
    aggregationFlag = "GeometricStdDev",
    asStepPlot = FALSE
  )
)

plotFiles <- verifyAndCopyPlots(
  reportFolder = reportFolder,
  outputsRoot = pc$outputFolder,
  qmdNames = qmdNames
)

qmdRenderResultStep <- renderQmdToMarkdown(
  searchFolder = reportFolder,
  pattern = "UC07H_DistVsDemo_StepPlot\\.qmd$"
)

qmdRenderResultRange <- renderQmdToMarkdown(
  searchFolder = reportFolder,
  pattern = "UC07H_DistVsDemo_RangePlot\\.qmd$"
)

reportLines <- c(
  "# UC-07H Plot generation: Distribution vs Demographics",
  "",
  "## Summary",
  "",
  "This scenario validates distribution-vs-demographics plot generation using runPlot() with both step-plot and range-plot rendering.",
  "",
  "## Assertions",
  "",
  paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
  paste0(
    "- PK parameters available: ",
    paste(unique(pkParameterDT$pkParameter), collapse = ", ")
  ),
  "- Configuration sheet (UC07H_DistVsDemo) rows with active status loaded for coverage testing.",
  paste0("- Coverage tested: ", nrow(coverage), " plot configurations"),
  "- runPlot(nameOfplotFunction = 'plotDistributionVsDemographics') completed with asStepPlot = TRUE.",
  "- runPlot(nameOfplotFunction = 'plotDistributionVsDemographics') completed with asStepPlot = FALSE.",
  paste0("- Returned plot/table objects: ", returnedPlots),
  qmdRenderAssertionLine(
    qmdRenderResultStep,
    assertionPrefix = "UC07H_DistVsDemo_StepPlot.qmd"
  ),
  qmdRenderAssertionLine(
    qmdRenderResultRange,
    assertionPrefix = "UC07H_DistVsDemo_RangePlot.qmd"
  ),
  coverageReportSection(coverage, configSheetName),
  qmdRenderContentSection(
    qmdRenderResultStep,
    sectionTitle = "Distribution vs Demographics (Step Plot)",
    sectionDescription = "The following content is from the auto-generated UC07H_DistVsDemo_StepPlot.qmd with step-plot rendering:"
  ),
  qmdRenderContentSection(
    qmdRenderResultRange,
    sectionTitle = "Distribution vs Demographics (Range Plot)",
    sectionDescription = "The following content is from the auto-generated UC07H_DistVsDemo_RangePlot.qmd with range-plot rendering:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))

