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

configuredTimeProfilePlotNames <- function(reportsFile) {
  raw <- openxlsx::readWorkbook(
    reportsFile,
    sheet = "TimeProfiles",
    colNames = FALSE
  )

  assertOrStop(nrow(raw) >= 3, "TimeProfiles sheet has insufficient rows")

  header <- trimws(as.character(raw[1, ]))
  plotNameIdx <- which(header == "PlotName")[1]
  levelIdx <- which(header == "Level")[1]

  assertOrStop(
    !is.na(plotNameIdx),
    "TimeProfiles sheet missing PlotName column"
  )
  assertOrStop(!is.na(levelIdx), "TimeProfiles sheet missing Level column")

  body <- raw[-c(1, 2), , drop = FALSE]
  plotNames <- trimws(as.character(body[[plotNameIdx]]))
  levels <- trimws(as.character(body[[levelIdx]]))

  runnable <- (is.na(levels) | levels == "") &
    !is.na(plotNames) &
    plotNames != ""
  unique(plotNames[runnable])
}

copyWorkflowOutputsToReport <- function(projectDir, reportFolder) {
  outputsRoot <- file.path(projectDir, "Outputs", "ReportingFramework")
  assertOrStop(
    dir.exists(outputsRoot),
    "Workflow outputs directory does not exist"
  )
  outputsRootNormalized <- normalizePath(outputsRoot, winslash = "/")

  outputFiles <- list.files(outputsRoot, recursive = TRUE, full.names = TRUE)
  assertOrStop(
    length(outputFiles) > 0,
    "No workflow output files were generated"
  )

  for (sourceFile in outputFiles) {
    sourceNormalized <- normalizePath(sourceFile, winslash = "/")
    relativePath <- substring(
      sourceNormalized,
      nchar(outputsRootNormalized) + 2
    )
    destinationFile <- file.path(reportFolder, relativePath)

    if (dir.exists(sourceFile)) {
      dir.create(destinationFile, recursive = TRUE, showWarnings = FALSE)
      next
    }

    dir.create(dirname(destinationFile), recursive = TRUE, showWarnings = FALSE)
    file.copy(sourceFile, destinationFile, overwrite = TRUE)
  }

  invisible(NULL)
}

compareGeneratedPlotsToReference <- function(reportFolder, referenceFolder) {
  generated <- list.files(
    reportFolder,
    recursive = TRUE,
    full.names = TRUE,
    pattern = "(png|svg)$"
  )
  reference <- list.files(
    referenceFolder,
    recursive = TRUE,
    full.names = TRUE,
    pattern = "(png|svg)$"
  )

  assertOrStop(length(generated) > 0, "No generated plots found for comparison")
  assertOrStop(length(reference) > 0, "No reference plots found for comparison")

  reportRoot <- normalizePath(reportFolder, winslash = "/")
  referenceRoot <- normalizePath(referenceFolder, winslash = "/")
  relGenerated <- vapply(
    generated,
    function(path) {
      substring(normalizePath(path, winslash = "/"), nchar(reportRoot) + 2)
    },
    character(1)
  )
  relReference <- vapply(
    reference,
    function(path) {
      substring(normalizePath(path, winslash = "/"), nchar(referenceRoot) + 2)
    },
    character(1)
  )

  missingInReference <- setdiff(relGenerated, relReference)
  missingInGenerated <- setdiff(relReference, relGenerated)

  assertOrStop(
    length(missingInReference) == 0,
    paste0(
      "Generated plots without reference: ",
      paste(missingInReference, collapse = ", ")
    )
  )
  assertOrStop(
    length(missingInGenerated) == 0,
    paste0(
      "Reference plots missing in generated outputs: ",
      paste(missingInGenerated, collapse = ", ")
    )
  )

  mismatches <- character(0)
  for (relativePath in sort(relGenerated)) {
    generatedPath <- file.path(reportFolder, relativePath)
    referencePath <- file.path(referenceFolder, relativePath)
    extension <- tolower(tools::file_ext(relativePath))

    equal <- tryCatch(
      {
        if (extension == "svg") {
          isTRUE(all(rsvg::rsvg(generatedPath) == rsvg::rsvg(referencePath)))
        } else {
          isTRUE(all(
            png::readPNG(generatedPath) == png::readPNG(referencePath)
          ))
        }
      },
      error = function(e) FALSE
    )

    if (!equal) {
      mismatches <- c(mismatches, relativePath)
    }
  }

  assertOrStop(
    length(mismatches) == 0,
    paste0(
      "Generated plots differ from reference: ",
      paste(mismatches, collapse = ", ")
    )
  )

  invisible(length(relGenerated))
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


plotNames <- configuredTimeProfilePlotNames(pc$addOns$reportsFile)
assertOrStop(
  length(plotNames) > 0,
  "No runnable plot names found in TimeProfiles sheet"
)

coverage <- data.table::data.table(
  plotName = plotNames,
  inputsUsed = "",
  status = "PASS",
  returnedObjects = 0L,
  errorMessage = ""
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
        configTableSheet = "TimeProfiles",
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

# export Plots
runPlot(
  nameOfplotFunction = "plotTimeProfiles",
  projectConfiguration = pc,
  configTableSheet = "TimeProfiles",
  theme = themeToUse,
  inputs = list(
    dataObserved = plotDataObserved,
    scenarioResults = scenarioResults
  )
)


copyWorkflowOutputsToReport(
  projectDir = pc,
  reportFolder = reportFolder
)

plotFiles <- list.files(
  reportFolder,
  recursive = TRUE,
  full.names = TRUE,
  pattern = "(png|svg)$"
)
assertOrStop(
  length(plotFiles) > 0,
  "No plot files were generated in the UC-12 report folder"
)

comparedPlots <- compareGeneratedPlotsToReference(
  reportFolder = reportFolder,
  referenceFolder = referenceFolder
)

reportTable <- c(
  "| Plot Name | Inputs | Status | Returned Objects |",
  "|---|---|---|---:|"
)
for (i in seq_len(nrow(coverage))) {
  reportTable <- c(
    reportTable,
    paste0(
      "| ",
      coverage$plotName[[i]],
      " | ",
      coverage$inputsUsed[[i]],
      " | ",
      coverage$status[[i]],
      " | ",
      coverage$returnedObjects[[i]],
      " |"
    )
  )
}

reportLines <- c(
  "# UC-12 Tutorial Time Profiles",
  "",
  "## Summary",
  "",
  "This scenario validates tutorial-based time profile plotting using tutorial configuration and observed-data assets from ospsuite.reportingframework extdata.",
  "",
  "## Assertions",
  "",
  paste0("- Tutorial directory found: ", tutorialDir),
  paste0("- Scenarios created: ", paste(scenarioNames, collapse = ", ")),
  paste0("- Observed rows loaded: ", nrow(dataObserved)),
  paste0("- TimeProfiles plot configurations executed: ", length(plotNames)),
  paste0("- Executed plot names: ", paste(coverage$plotName, collapse = ", ")),
  paste0("- Generated plot files: ", length(plotFiles)),
  paste0("- Compared against reference plots: ", comparedPlots),
  "- Generated and reference plot sets are identical.",
  "",
  "## Plot Coverage",
  "",
  reportTable,
  ""
)

reportPath <- file.path(reportFolder, "Report.md")
writeLines(reportLines, con = reportPath)
