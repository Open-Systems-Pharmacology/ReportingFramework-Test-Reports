#' @title report-uc-12-plot-timeprofiles-tutorial
#' @description
#' Integration scenario for UC-12 tutorial-based time profile plotting.

# init --------

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportName <- "UC-12-Plot-TimeProfiles-Tutorial"
reportFolder <- file.path("tests", "Reports", reportName)
referenceFolder <- file.path("Reports", reportName)
configSheetName <- "TimeProfiles"
qmdName <- "Timeprofile"
projectDir <- tempfile(pattern = "uc12_timeprofiles_tutorial_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

# functions  --------

copyTutorialAssets <- function(pc) {
  tutorialDir <- system.file(
    "extdata",
    "Tutorial",
    package = "ospsuite.reportingframework"
  )

  assertOrStop(
    nzchar(tutorialDir) && dir.exists(tutorialDir),
    "Tutorial extdata directory was not found in ospsuite.reportingframework"
  )

  requiredFiles <- c(
    DataImportConfiguration.xlsx = pc$dataImporterConfigurationFile,
    Individuals.xlsx = pc$individualsFile,
    Populations.xlsx = pc$populationsFile,
    Scenarios.xlsx = pc$scenariosFile,
    Reports.xlsx = pc$addOns$reportsFile
  )

  for (fileName in names(requiredFiles)) {
    sourcePath <- file.path(tutorialDir, fileName)
    destinationPath <- requiredFiles[[fileName]]
    assertOrStop(
      file.exists(sourcePath),
      paste0("Tutorial configuration file not found: ", sourcePath)
    )
    dir.create(dirname(destinationPath), recursive = TRUE, showWarnings = FALSE)
    file.copy(sourcePath, destinationPath, overwrite = TRUE)
    assertOrStop(
      file.exists(destinationPath),
      paste0("Failed to copy tutorial file: ", fileName)
    )
  }

  dataFiles <- list.files(
    tutorialDir,
    pattern = "\\.csv$",
    full.names = FALSE
  )
  assertOrStop(length(dataFiles) > 0, "No tutorial CSV data files found")

  primaryDataDir <- file.path(dirname(pc$scenariosFile), "Data")
  dir.create(primaryDataDir, recursive = TRUE, showWarnings = FALSE)

  for (dataFile in dataFiles) {
    sourcePath <- file.path(tutorialDir, dataFile)
    file.copy(sourcePath, file.path(primaryDataDir, dataFile), overwrite = TRUE)
  }

  for (rootDir in unique(c(
    projectDir,
    dirname(pc$scenariosFile),
    tempdir(),
    dirname(tempdir()),
    dirname(dirname(tempdir()))
  ))) {
    tempDataDir <- file.path(rootDir, "Data")
    dir.create(tempDataDir, recursive = TRUE, showWarnings = FALSE)
    srcFiles <- file.path(primaryDataDir, dataFiles)
    dstFiles <- file.path(tempDataDir, dataFiles)
    if (
      !all(
        normalizePath(srcFiles, winslash = "/") ==
          normalizePath(dstFiles, winslash = "/", mustWork = FALSE)
      )
    ) {
      file.copy(
        from = srcFiles,
        to = dstFiles,
        overwrite = TRUE
      )
    }
  }

  modelDir <- system.file(
    "extdata",
    "Models",
    package = "ospsuite.reportingframework"
  )
  assertOrStop(
    nzchar(modelDir) && dir.exists(modelDir),
    "Tutorial model directory was not found in ospsuite.reportingframework"
  )
  modelFiles <- c("iv_1_mg_5_min.pkml", "po_3_mg_solution.pkml")
  for (modelFile in modelFiles) {
    sourcePath <- file.path(modelDir, modelFile)
    destinationPath <- file.path(pc$modelFolder, modelFile)
    assertOrStop(
      file.exists(sourcePath),
      paste0("Required tutorial model missing: ", sourcePath)
    )
    file.copy(sourcePath, destinationPath, overwrite = TRUE)
  }

  populationDir <- system.file(
    "extdata",
    "Populations",
    package = "ospsuite.reportingframework"
  )
  assertOrStop(
    nzchar(populationDir) && dir.exists(populationDir),
    "Tutorial population directory was not found in ospsuite.reportingframework"
  )

  sourcePath <- file.path(populationDir, "adults.csv")
  destinationPath <- file.path(pc$populationsFolder, "random_population.csv")
  assertOrStop(
    file.exists(sourcePath),
    paste0("Required tutorial model missing: ", sourcePath)
  )
  file.copy(sourcePath, destinationPath, overwrite = TRUE)

  populationDir <- system.file(
    "extdata",
    "Tutorial",
    package = "ospsuite.reportingframework"
  )
  assertOrStop(
    nzchar(populationDir) && dir.exists(populationDir),
    "Tutorial population directory was not found in ospsuite.reportingframework"
  )
  sourcePath <- file.path(populationDir, "study_1234_population.csv")
  destinationPath <- file.path(
    pc$populationsFolder,
    "study_1234_population.csv"
  )
  assertOrStop(
    file.exists(sourcePath),
    paste0("Required tutorial model missing: ", sourcePath)
  )
  file.copy(sourcePath, destinationPath, overwrite = TRUE)

  invisible(tutorialDir)
}


# setup project  --------

pc <- setupProject(projectDir)
tutorialDir <- copyTutorialAssets(pc)
assertOrStop(
  dir.exists(referenceFolder),
  "Reference folder does not exist for UC-12"
)

setWorkflowOptions(isValidRun = FALSE)

dataObserved <- suppressWarnings(readObservedDataByDictionary(
  projectConfiguration = pc
))

assertOrStop(
  data.table::is.data.table(dataObserved),
  "Observed data is not a data.table"
)
assertOrStop(nrow(dataObserved) > 0, "Observed data table is empty")

validateObservedData(dataObserved, dataClassType = "timeprofile")
dataObserved <- data.table::rbindlist(
  list(
    dataObserved,
    aggregateObservedDataGroups(
      dataObserved = dataObserved,
      groups = c("1234_iv", "1234_po")
    )
  ),
  fill = TRUE
)
updateDataGroupId(projectConfiguration = pc, dataDT = dataObserved)

scenarioList <- createScenariosWrapped(
  projectConfiguration = pc,
  scenarioNames = NULL
)
scenarioNames <- names(scenarioList)
assertOrStop(
  length(scenarioNames) > 0,
  "No scenarios were created from tutorial settings"
)

scenarioResults <- runAndSaveScenarios(
  projectConfiguration = pc,
  scenarioList = scenarioList,
  simulationRunOptions = ospsuite::SimulationRunOptions$new(
    showProgress = FALSE
  )
)

# run Plots  --------
themeToUse <-
  theme(legend.position = 'top', legend.title = element_blank())
options(knitr.kable.NA = '')

coverage <- loadAndFilterConfigSheet(
  pc,
  sheetName = configSheetName
)

# run per plotName to get coverage statistic (plotNames != NULL hinders export)
for (i in seq_len(nrow(coverage))) {
  plotName <- coverage$plotName[[i]]

  plotDataObserved <- data.table::copy(dataObserved)

  tpCall <- tryCatch(
    {
      runPlot(
        nameOfplotFunction = "plotTimeProfiles",
        projectConfiguration = pc,
        configTableSheet = configSheetName,
        qmdName = qmdName,
        plotNames = plotName,
        theme = themeToUse,
        inputs = list(
          dataObserved = plotDataObserved,
          scenarioResults = scenarioResults
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
    "UC-12 plot failures: ",
    paste(coverage$plotName[coverage$status == "FAIL"], collapse = ", ")
  )
)
returnedPlots <-
  sum(as.double(unlist(coverage$returnedObjects)), na.rm = TRUE)

# adjust export width
ospsuite.plots::setOspsuite.plots.option(
  optionKey = ospsuite.plots::OptionKeys$exportWidth,
  value = 20
)

# export Plots
runPlot(
  nameOfplotFunction = "plotTimeProfiles",
  projectConfiguration = pc,
  configTableSheet = configSheetName,
  qmdName = qmdName,
  theme = themeToUse,
  inputs = list(
    dataObserved = plotDataObserved,
    scenarioResults = scenarioResults
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
  pattern = "Timeprofile\\.qmd$"
)

reportLines <- c(
  "# UC-12 Tutorial Time Profiles",
  "",
  "## Summary",
  "",
  "This scenario validates tutorial-based time-profile plot generation using tutorial configuration and observed-data assets from ospsuite.reportingframework extdata.",
  "",
  "## Assertions",
  "",
  paste0("- Tutorial directory found: ", tutorialDir),
  paste0("- Scenarios created: ", paste(scenarioNames, collapse = ", ")),
  paste0("- Observed rows loaded: ", nrow(dataObserved)),
  "- TimeProfiles configuration sheet contains runnable plot definitions.",
  "- All runPlot(nameOfplotFunction = 'plotTimeProfiles') calls completed without error.",
  paste0("- Returned plot/table objects across coverage runs: ", returnedPlots),
  qmdRenderAssertionLine(qmdRenderResult, assertionPrefix = "Timeprofile.qmd"),
  coverageReportSection(coverage, configSheetName),
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "Time Profile Report",
    sectionDescription = "The following content is from the auto-generated Timeprofile.qmd with all figures, captions, and headings as defined in the TimeProfiles configuration sheet:"
  )
)

reportPath <- file.path(reportFolder, "Report.md")
writeLines(reportLines, con = reportPath)
