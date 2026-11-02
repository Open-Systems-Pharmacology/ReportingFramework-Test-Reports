#' @title report-uc-07g-plot-histograms
#' @description
#' Integration scenario for UC-07G histogram plot generation.

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
  "UC-07G-Plot-Histograms"
)
projectDir <- tempfile(pattern = "uc07g_histograms_")
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
qmdName <- "UC07G_Histograms"

pc <- setupProject(projectDir)

updateUC7Project(
  pc,
  scenarioNames = scenarioNames,
  copyPK = TRUE,
  copySimResult = FALSE
)

scenarioList <- createScenariosWrapped(pc, scenarioNames = scenarioNames)
assertOrStop(length(scenarioList) == 5, "UC-07G requires 5 scenarios")

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

for (i in seq_len(nrow(coverage))) {
  plotName <- coverage$plotName[[i]]

  histCall <- runStepWithResult(
    runPlot(
      projectConfiguration = pc,
      nameOfplotFunction = "plotHistograms",
      configTableSheet = qmdName,
      qmdName = qmdName,
      plotNames = plotName,
      theme = themeToUse,
      inputs = list(
        scenarioList = scenarioList,
        pkParameterDT = pkParameterDT
      )
    )
  )

  if (!isTRUE(histCall$success)) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- histCall$error
    next
  }

  coverage$returnedObjects[[i]] <- length(histCall$result)
  if (coverage$returnedObjects[[i]] == 0) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- "runPlot returned no plot objects"
  }
}

assertOrStop(
  !any(coverage$status == "FAIL"),
  paste0(
    "UC-07G plot failures: ",
    paste(coverage$plotName[coverage$status == "FAIL"], collapse = ", ")
  )
)
returnedPlots <-
  sum(as.double(unlist(coverage$returnedObjects)), na.rm = TRUE)

setPlotExportOptions(width = 20)

runPlot(
  projectConfiguration = pc,
  nameOfplotFunction = "plotHistograms",
  configTableSheet = qmdName,
  qmdName = qmdName,
  inputs = list(
    scenarioList = scenarioList,
    pkParameterDT = pkParameterDT
  )
)

plotFiles <- verifyAndCopyPlots(
  reportFolder = reportFolder,
  outputsRoot = pc$outputFolder,
  qmdNames = qmdName
)

qmdRenderResult <- renderQmdToMarkdown(
  searchFolder = reportFolder,
  pattern = "UC07G_Histograms\\.qmd$"
)

reportLines <- c(
  "# UC-07G Plot generation: Histograms",
  "",
  "## Summary",
  "",
  "This scenario validates histogram plot generation using runPlot() across multiple population scenarios.",
  "",
  "## Assertions",
  "",
  paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
  paste0(
    "- PK parameters available: ",
    paste(unique(pkParameterDT$pkParameter), collapse = ", ")
  ),
  "- UC07G_Histograms configuration rows with active status loaded for coverage testing.",
  paste0("- Coverage tested: ", nrow(coverage), " plot configurations"),
  "- runPlot(nameOfplotFunction = 'plotHistograms') completed without error.",
  paste0("- Returned plot/table objects: ", returnedPlots),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC07G_Histograms.qmd"
  ),
  coverageReportSection(coverage, qmdName),
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "Histogram Report",
    sectionDescription = "The following content is from the auto-generated UC07G_Histograms.qmd with the exported figures and captions from the demographic histogram workflow:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
