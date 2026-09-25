#' @title report-uc-07a-plot-timeprofiles
#' @description
#' Integration scenario for UC-07A time profile plot generation.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")
source("R/helpers-uc-observedData.R")
set.seed(1)

reportFolder <- file.path("tests", "Reports", "UC-07A-Plot-TimeProfiles")
projectDir <- tempfile(pattern = "uc07a_timeprofiles_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)


pc <- setupProject(projectDir)

# scenarios used in this use case:
scenarioNames <- c("adults_iv", "adults_po")

qmdName <- "UC07A_TimeProfiles"

updateUC7Project(
  pc,
  scenarioNames = scenarioNames,
  copyPK = FALSE,
  copySimResult = TRUE
)

scenarioList <- createScenariosWrapped(pc, scenarioNames = scenarioNames)
assertOrStop(length(scenarioList) == 2, "UC-07a requires two scenarios")

scenarioResultsForPlots <- loadScenarioResultsToFramework(pc, scenarioNames)

dataObserved <- data.table::fread(reportInputsPath("UC7_observed_TP.csv"))
dataObserved <- setObservedTimeProfileColumnTypes(dataObserved)

dataObserved <- rbind(
  dataObserved,
  ospsuite.reportingframework::aggregateObservedDataGroups(
    dataObserved = dataObserved
  ),
  fill = TRUE
)
validateObservedData(dataObserved, dataClassType = "timeprofile")
updateDataGroupId(projectConfiguration = pc, dataDT = dataObserved)


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
  tpCall <- tryCatch(
    {
      plotList <- runPlot(
        projectConfiguration = pc,
        nameOfplotFunction = "plotTimeProfiles",
        configTableSheet = qmdName,
        qmdName = qmdName,
        plotNames = plotName,
        theme = themeToUse,
        inputs = list(
          scenarioResults = scenarioResultsForPlots,
          dataObserved = dataObserved
        )
      )
    },
    error = function(e) {
      e
    }
  )

  if (inherits(tpCall, "error")) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- tpCall$message
    next
  }

  coverage$returnedObjects[[i]] <- length(tpCall)
  if (coverage$returnedObjects[[i]] == 0) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- "runPlot returned no plot objects"
  }
}


assertOrStop(
  !any(coverage$status == "FAIL"),
  paste0(
    "UC-07A plot failures: ",
    paste(
      coverage$plotName[coverage$status == "FAIL"],
      collapse = ", "
    )
  )
)
returnedPlots <- if (any(inherits(tpCall, "error"))) {
  0
} else {
  coverage$returnedObjects[[nrow(coverage)]]
}


# adjust export width
setPlotExportOptions(width = 20)

# export Plots
runPlot(
  nameOfplotFunction = "plotTimeProfiles",
  projectConfiguration = pc,
  configTableSheet = qmdName,
  qmdName = qmdName,
  theme = themeToUse,
  inputs = list(
    dataObserved = dataObserved,
    scenarioResults = scenarioResultsForPlots
  )
)

plotFiles <- verifyAndCopyPlots(
  reportFolder = reportFolder,
  outputsRoot = pc$outputFolder,
  qmdNames = qmdName
)

# Render qmd content to markdown using helper function
qmdRenderResult <- renderQmdToMarkdown(
  searchFolder = reportFolder,
  pattern = "UC07A_TimeProfiles\\\\.qmd$"
)


reportLines <- c(
  "# UC-07A Plot generation: Time Profiles",
  "",
  "## Summary",
  "",
  "This scenario validates runPlot execution for time profile plot generation using mean simulation results with observed data and exports the generated workflow outputs.",
  "",
  "## Approach",
  "",
  "- Uses simulation results from mean model scenarios copied from the repo-local ReportInputs folder.",
  "- Loads stable observed time-profile fixture data from ReportInputs/UC7_observed_TP.csv.",
  "- Generates time profile plots showing concentration-time profiles with overlaid observed data.",
  "",
  "## Assertions",
  "",
  paste0(
    "- Mean model scenarios configured: ",
    paste(scenarioNames, collapse = ", ")
  ),
  "- Observed data loaded from ReportInputs/UC7_observed_TP.csv.",
  paste0("- Total data points in observed data: ", nrow(dataObserved)),
  "- UC07A_TimeProfiles contains at least one runnable row.",
  paste0("- Selected plotName: ", plotName),
  "- runPlot(nameOfplotFunction = 'plotTimeProfiles') completed without error.",
  paste0("- Returned plot/table objects: ", returnedPlots),
  paste0("- Generated plot files: ", length(plotFiles)),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC07A_TimeProfiles.qmd"
  ),
  "",
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "Time Profile Report",
    sectionDescription = "The following content is from the auto-generated UC07A_TimeProfiles.qmd with the exported figures and captions from the time profile workflow:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
