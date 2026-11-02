#' @title report-uc-07i-plot-custom-annotated-timeprofiles
#' @description
#' Integration scenario for UC-07I custom annotated time profile plot generation.
#' Demonstrates how to create and use a custom plot function that extends
#' framework functionality with additional styling and annotations.

rm(list = ls())
library(ospsuite.reportingframework)

source("R/helpers-uc-shared.R")
source("R/helpers-uc-observedData.R")
source("R/helpers-uc-07i-custom-plot.R")

# Prevent accidental creation of Rplots.pdf by using a null default device.
originalDeviceOption <- getOption("device")
options(device = function(...) grDevices::pdf(NULL))
on.exit(options(device = originalDeviceOption), add = TRUE)

set.seed(1)

reportFolder <- file.path(
  "tests",
  "Reports",
  "UC-07I-Plot-CustomAnnotatedTimeProfiles"
)
projectDir <- tempfile(pattern = "uc07i_custom_tp_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

scenarioNames <- c("adults_iv", "adults_po")
qmdName <- "UC07I_CustomAnnotatedTimeProfiles"
configSheetName <- "UC07A_TimeProfiles"

pc <- setupProject(projectDir)

updateUC7Project(
  pc,
  scenarioNames = scenarioNames,
  copyPK = FALSE,
  copySimResult = TRUE
)

scenarioList <- createScenariosWrapped(pc, scenarioNames = scenarioNames)
assertOrStop(length(scenarioList) == 2, "UC-07I requires two scenarios")

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
  sheetName = configSheetName
)

for (i in seq_len(nrow(coverage))) {
  plotName <- coverage$plotName[[i]]

  customCall <- runStepWithResult(
    runPlot(
      projectConfiguration = pc,
      nameOfplotFunction = "plotCustomAnnotatedTimeProfiles",
      configTableSheet = configSheetName,
      qmdName = qmdName,
      plotNames = plotName,
      theme = themeToUse,
      inputs = list(
        scenarioResults = scenarioResultsForPlots,
        dataObserved = dataObserved
      )
    )
  )

  if (!isTRUE(customCall$success)) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- customCall$error
    next
  }

  coverage$returnedObjects[[i]] <- length(customCall$result)
  if (coverage$returnedObjects[[i]] == 0) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- "runPlot returned no plot objects"
  }
}

assertOrStop(
  !any(coverage$status == "FAIL"),
  paste0(
    "UC-07I plot failures: ",
    paste(
      coverage$plotName[coverage$status == "FAIL"],
      collapse = ", "
    )
  )
)
returnedPlots <-
  sum(as.double(unlist(coverage$returnedObjects)), na.rm = TRUE)

setPlotExportOptions(width = 20)

runPlot(
  projectConfiguration = pc,
  nameOfplotFunction = "plotCustomAnnotatedTimeProfiles",
  configTableSheet = configSheetName,
  qmdName = qmdName,
  theme = themeToUse,
  inputs = list(
    scenarioResults = scenarioResultsForPlots,
    dataObserved = dataObserved
  )
)

plotFiles <- verifyAndCopyPlots(
  reportFolder = reportFolder,
  outputsRoot = pc$outputFolder,
  qmdNames = qmdName
)

qmdRenderResult <- renderQmdToMarkdown(
  searchFolder = reportFolder,
  pattern = "UC07I_CustomAnnotatedTimeProfiles\\.qmd$"
)

reportLines <- c(
  "# UC-07I Plot generation: Custom Annotated Time Profiles",
  "",
  "## Summary",
  "",
  "This scenario validates custom time-profile plot generation using the UC-07A workflow inputs while routing plotting through a custom wrapper function.",
  "The custom plot function (plotCustomAnnotatedTimeProfiles) extends the standard workflow with additional annotations and styling.",
  "",
  "## Approach",
  "",
  "- Uses the same mean simulation result scenarios as UC-07A from the repo-local ReportInputs folder.",
  "- Loads the same stable observed time-profile fixture data from ReportInputs/UC7_observed_TP.csv.",
  "- Calls plotTimeProfiles through a custom wrapper that adds annotations and export metadata.",
  "",
  "## Assertions",
  "",
  paste0(
    "- Mean model scenarios configured: ",
    paste(scenarioNames, collapse = ", ")
  ),
  "- Observed data loaded from ReportInputs/UC7_observed_TP.csv.",
  paste0("- Total data points in observed data: ", nrow(dataObserved)),
  paste0(
    "- ",
    configSheetName,
    " configuration sheet contains runnable plot definitions."
  ),
  "- All custom plot calls (plotCustomAnnotatedTimeProfiles) completed without error.",
  "- Custom wrapper adds reference lines and export annotations on top of plotTimeProfiles.",
  paste0("- Returned plot/table objects from final execution: ", returnedPlots),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC07I_CustomAnnotatedTimeProfiles.qmd"
  ),
  "",
  "## Customizations",
  "",
  "- Call existing framework plot functions",
  "- Extend plots with additional ggplot2 layers and styling",
  "- Customize export attributes with captions and footnotes",
  "- Implement configuration validation",
  coverageReportSection(coverage, configSheetName),
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "Custom Annotated Time Profiles Report",
    sectionDescription = "The following content is from the auto-generated UC07I_CustomAnnotatedTimeProfiles.qmd with custom-styled time profile plots and enhanced annotations:"
  )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
