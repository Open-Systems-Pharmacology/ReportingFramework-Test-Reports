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
returnedPlots <-
  sum(as.double(unlist(coverage$returnedObjects)), na.rm = TRUE)


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
  pattern = "UC07A_TimeProfiles\\.qmd$"
)

reportLines <- c(
  "# UC-07A Plot generation: Time Profiles",
  "",
  "## Summary",
  "",
  "This scenario validates time-profile plot generation using runPlot() with simulation results and overlaid observed data. Plots are generated across multiple variant families and exported for reporting.",
  "",
  "## Approach",
  "",
  "- Uses population model simulation results from repo-local ReportInputs folder.",
  "- Loads observed time-profile fixture data from ReportInputs/UC7_observed_TP.csv.",
  "- Generates time profile plots with concentration-time profiles and overlaid observed data using runPlot(nameOfplotFunction = 'plotTimeProfiles').",
  "- Exports plots and generates Quarto markdown report with figures and captions.",
  "",
  "## Assertions",
  "",
  paste0(
    "- Mean model scenarios configured: ",
    paste(scenarioNames, collapse = ", ")
  ),
  "- Observed data loaded from ReportInputs/UC7_observed_TP.csv.",
  paste0("- Total data points in observed data: ", nrow(dataObserved)),
  "- UC07A_TimeProfiles configuration sheet contains runnable plot definitions.",
  "- All runPlot(nameOfplotFunction = 'plotTimeProfiles') calls completed without error.",
  paste0("- Returned plot/table objects from final execution: ", returnedPlots),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC07A_TimeProfiles.qmd"
  ),
  coverageReportSection(coverage, qmdName),
  qmdRenderContentSection(
    qmdRenderResult,
    sectionDescription = "The following content is from the auto-generated UC07A_TimeProfiles.qmd with exported figures and captions:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
