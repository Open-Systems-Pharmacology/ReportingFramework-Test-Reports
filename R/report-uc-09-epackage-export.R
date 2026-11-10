#' @title report-uc-09-epackage-export
#' @description
#' Integration scenario for UC-09 electronic package (ePackage) export.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")
setWorkflowOptions(isValidRun = FALSE)

# Prevent accidental creation of Rplots.pdf by using a null default device.
originalDeviceOption <- getOption("device")
options(device = function(...) grDevices::pdf(NULL))
on.exit(options(device = originalDeviceOption), add = TRUE)

# helper functions -------------

#' Builds UC09 scenarios, writes them to workbook, and creates scenario objects.
#' @keywords internal
#' @noRd
.setupUC09Scenarios <- function(
  pc,
  baseScenarioName,
  populationScenarioName,
  populationSourceName,
  modelFile
) {
  wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
  scenariosConfig <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
  scenarioOutputs <- xlsxReadData(wbScenarios, sheetName = "OutputPaths")

  defaultIndividualId <- as.character(scenariosConfig$individualId[[1]])
  defaultOutputPathId <- as.character(scenarioOutputs$outputPathId[[1]])

  copyPopulations(pc, files = paste0(populationSourceName, ".csv"))

  scenarioSetup <- data.table::rbindlist(
    list(
      makeDefaultScenarioTable(
        baseScenarioName,
        individualId = defaultIndividualId,
        outputPathId = defaultOutputPathId,
        modelFile = modelFile
      ),
      makeDefaultScenarioTable(
        populationScenarioName,
        outputPathId = defaultOutputPathId,
        modelFile = modelFile
      )
    ),
    use.names = TRUE
  )

  scenarioSetup[
    scenario_name == populationScenarioName,
    populationId := populationSourceName
  ]
  scenarioSetup[,
    readPopulationFromCSV := ifelse(
      scenario_name == populationScenarioName,
      "TRUE",
      "FALSE"
    )
  ]

  xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
  openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

  scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
  scenarioNames <- names(scenarioList)

  list(
    scenarioNames = scenarioNames,
    scenarioResultsCount = length(scenarioNames),
    simulationResultFiles = file.path(
      pc$outputFolder,
      EXPORTDIR$simulationResult,
      paste0(scenarioNames, ".csv")
    )
  )
}

#' Exports and runs simulation workflow and evaluates critical artifacts.
#' @keywords internal
#' @noRd
.runSimulationWorkflowUC09 <- function(
  pc,
  ePackageFolderPath,
  scenarioNames,
  fileNameReplacements,
  simulationResultFiles
) {
  exportResult <- .runStep(
    exportSimulationWorkflowToEPackage(
      projectConfiguration = pc,
      wfIdentifier = 1,
      scenarioNames = scenarioNames,
      fileNameReplacements = fileNameReplacements
    )
  )

  simulationInputManifest <- file.path(
    ePackageFolderPath,
    "w1_input_files_csv.txt"
  )
  simulationManifestLines <- if (file.exists(simulationInputManifest)) {
    readLines(simulationInputManifest, warn = FALSE)
  } else {
    character(0)
  }

  ePackageModelFiles <- list.files(
    ePackageFolderPath,
    recursive = TRUE,
    full.names = FALSE,
    pattern = "\\.(xml|pkml)$",
    ignore.case = TRUE
  )

  modelRenameVerified <-
    any(grepl(
      "acyclovir\\.(xml|pkml)",
      simulationManifestLines,
      ignore.case = TRUE
    )) &&
    !any(grepl(
      "Aciclovir\\.(xml|pkml)",
      simulationManifestLines,
      ignore.case = TRUE
    )) &&
    any(grepl(
      "^acyclovir\\.(xml|pkml)$",
      ePackageModelFiles,
      ignore.case = TRUE
    )) &&
    !any(grepl(
      "^Aciclovir\\.(xml|pkml)$",
      ePackageModelFiles,
      ignore.case = TRUE
    ))

  workflowRun <- executeExportedWorkflow(
    ePackageFolder = ePackageFolderPath,
    wfIdentifier = 1,
    monitoredRoots = c(
      simulationResults = file.path(
        pc$outputFolder,
        EXPORTDIR$simulationResult
      )
    )
  )

  missingResultFiles <- simulationResultFiles[
    !file.exists(simulationResultFiles)
  ]

  list(
    exportResult = exportResult,
    exportSucceeded = isTRUE(exportResult$success),
    modelRenameVerified = modelRenameVerified,
    workflowRun = workflowRun,
    missingResultFiles = missingResultFiles,
    artifactsRestored = length(missingResultFiles) == 0
  )
}

#' Copies and normalizes TLF workflow prerequisites in the generated project.
#' @keywords internal
#' @noRd
.prepareTLFWorkflowInputs <- function(pc, templatePath, customCodePath) {
  .copyUC10DataImportFixtures(pc)

  workflowRmdInProject <- file.path(pc$configurationsFolder, "workflow.Rmd")
  customCodeInProject <- file.path(
    pc$configurationsFolder,
    "..",
    "customCode.R"
  )

  file.copy(from = templatePath, to = workflowRmdInProject, overwrite = TRUE)
  file.copy(from = customCodePath, to = customCodeInProject, overwrite = TRUE)

  assertOrStop(
    file.exists(workflowRmdInProject),
    paste0("Failed to copy TLF workflow template: ", workflowRmdInProject)
  )
  assertOrStop(
    file.exists(customCodeInProject),
    paste0("Failed to copy custom code file: ", customCodeInProject)
  )

  addDefaultConfigForTimeProfilePlots(projectConfiguration = pc)

  reportsWorkbookPath <- file.path(pc$configurationsFolder, "Reports.xlsx")
  wbReport <- openxlsx::loadWorkbook(reportsWorkbookPath)
  outputsConfig <- xlsxReadData(wbReport, sheetName = "Outputs")

  emptyDisplayName <-
    is.na(outputsConfig[["displayName"]]) |
    trimws(outputsConfig[["displayName"]]) == ""
  outputsConfig[emptyDisplayName, displayName := outputPathId]

  emptyDisplayUnit <-
    is.na(outputsConfig$displayUnit) |
    trimws(outputsConfig$displayUnit) == ""
  outputsConfig[emptyDisplayUnit, displayUnit := "\u00B5g/L"]

  xlsxWriteData(wbReport, sheetName = "Outputs", outputsConfig)
  openxlsx::saveWorkbook(wbReport, reportsWorkbookPath, overwrite = TRUE)

  list(
    workflowRmdInProject = workflowRmdInProject,
    customCodeInProject = customCodeInProject
  )
}

#' Exports and runs TLF workflow and collects post-run diagnostics.
#' @keywords internal
#' @noRd
.runTLFWorkflowUC09 <- function(
  pc,
  ePackageFolderPath,
  workflowRmdInProject,
  fileNameReplacements,
  projectDir
) {
  exportResult <- .runStep(
    exportTLFWorkflowToEPackage(
      projectConfiguration = pc,
      wfIdentifier = 2,
      workflowRmd = workflowRmdInProject,
      fileNameReplacements = fileNameReplacements
    )
  )

  exportSucceeded <- isTRUE(exportResult$success)

  workflowRun <- if (exportSucceeded) {
    executeExportedWorkflow(
      ePackageFolder = ePackageFolderPath,
      wfIdentifier = 2,
      monitoredRoots = c(outputRoot = pc$outputFolder)
    )
  } else {
    list(
      success = FALSE,
      error = exportResult$error,
      projectOutputFolder = NA_character_,
      runnerFile = file.path(ePackageFolderPath, "w2_workflow_r.txt"),
      filesAfter = list(),
      newFiles = list()
    )
  }

  logFile <- if (!is.na(projectDir)) {
    file.path(projectDir, "logs", "w2.log")
  } else {
    NA_character_
  }
  logExists <- !is.na(logFile) && file.exists(logFile)
  logLines <- if (logExists) {
    readLines(logFile, warn = FALSE)
  } else {
    character(0)
  }

  customCodeSourced <- any(grepl("customCode was sourced", logLines))

  numericValuesMatches <- regexec(
    "Nrow NumericalValues:=\\s*([0-9]+)",
    logLines
  )
  numericValuesCaptured <- regmatches(logLines, numericValuesMatches)
  numericValuesCounts <- as.integer(vapply(
    numericValuesCaptured,
    function(match) {
      if (length(match) >= 2) {
        match[[2]]
      } else {
        NA_character_
      }
    },
    character(1)
  ))
  numericValuesCountIsThree <- any(numericValuesCounts == 3, na.rm = TRUE)

  outputFiles <- if (!is.na(workflowRun$projectOutputFolder)) {
    list.files(
      workflowRun$projectOutputFolder,
      recursive = TRUE,
      full.names = TRUE
    )
  } else {
    character(0)
  }

  summaryFiles <- outputFiles[
    grepl(
      "UC09_TLF_Summary\\.(csv|txt)$",
      basename(outputFiles),
      ignore.case = TRUE
    )
  ]

  timeprofilePngFiles <- outputFiles[
    grepl(
      "Timeprofiles?.*\\.png$",
      gsub("\\\\", "/", outputFiles),
      ignore.case = TRUE
    )
  ]

  list(
    exportResult = exportResult,
    exportSucceeded = exportSucceeded,
    workflowRun = workflowRun,
    artifactsCreated = isTRUE(workflowRun$success) &&
      !is.na(workflowRun$projectOutputFolder),
    logFile = logFile,
    logExists = logExists,
    customCodeSourced = customCodeSourced,
    numericValuesCountIsThree = numericValuesCountIsThree,
    summaryFiles = summaryFiles,
    hasSummaryArtifacts = length(summaryFiles) > 0,
    timeprofilePngFiles = timeprofilePngFiles,
    hasTimeprofilePngArtifacts = length(timeprofilePngFiles) > 0
  )
}

#' Lists ePackage contents and computes extension-level checks.
#' @keywords internal
#' @noRd
.inspectEPackage <- function(ePackageFolderPath) {
  ePackageContents <- list.files(
    ePackageFolderPath,
    recursive = TRUE,
    full.names = FALSE
  )

  ePackageContents <- ePackageContents[
    basename(ePackageContents) != "Rplots.pdf"
  ]

  allowedEPackageExtensions <- c("txt", "xml", "json")
  ePackageFileExtensions <- sort(unique(tolower(tools::file_ext(
    ePackageContents
  ))))
  invalidEPackageFiles <- ePackageContents[
    !tolower(tools::file_ext(ePackageContents)) %in%
      allowedEPackageExtensions
  ]

  list(
    fileExtensions = ePackageFileExtensions,
    invalidFiles = invalidEPackageFiles,
    workflowFiles = list.files(
      ePackageFolderPath,
      pattern = "^w[0-9]+_workflow_r\\.txt$",
      full.names = TRUE
    ),
    inputFiles = list.files(
      ePackageFolderPath,
      pattern = "_input_files(?:_csv)?\\.txt$",
      full.names = TRUE
    ),
    configFiles = list.files(
      ePackageFolderPath,
      pattern = "_config_json\\.txt$",
      full.names = TRUE
    )
  )
}

# start workflow ----------

reportFolder <- file.path("tests", "Reports", "UC-09-EPackage-Export")
projectDir <- tempfile(pattern = "uc09_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

# Phase 1: initialize project and baseline paths.
pc <- setupProject(projectDir)
modelFile <- "Aciclovir.pkml"
fileNameReplacements <- c(modelFile, "acyclovir.pkml")
baseScenarioName <- "UC09_Scenario1"
populationScenarioName <- "UC09_PopulationScenario"
populationSourceName <- "adults"

copyModelFiles(pc, modelFile)

ePackageFolderPath <- pc$addOns$electronicPackageFolder
assertOrStop(
  !is.null(ePackageFolderPath),
  "ePackage folder path not set in project configuration"
)
dir.create(ePackageFolderPath, recursive = TRUE, showWarnings = FALSE)
assertOrStop(
  dir.exists(ePackageFolderPath),
  paste0("Failed to create ePackage folder at: ", ePackageFolderPath)
)

# Phase 2: prepare scenarios and run simulation workflow export.
scenarioInfo <- .setupUC09Scenarios(
  pc = pc,
  baseScenarioName = baseScenarioName,
  populationScenarioName = populationScenarioName,
  populationSourceName = populationSourceName,
  modelFile = modelFile
)

simulationInfo <- .runSimulationWorkflowUC09(
  pc = pc,
  ePackageFolderPath = ePackageFolderPath,
  scenarioNames = scenarioInfo$scenarioNames,
  fileNameReplacements = fileNameReplacements,
  simulationResultFiles = scenarioInfo$simulationResultFiles
)

# Phase 3: prepare TLF inputs and run exported TLF workflow.
tlfWorkflowTemplatePath <- reportInputsPath("UC09_ePackageWorkflow.Rmd")
tlfCustomCodePath <- reportInputsPath("UC09_customCode.R")

tlfInputs <- .prepareTLFWorkflowInputs(
  pc = pc,
  templatePath = tlfWorkflowTemplatePath,
  customCodePath = tlfCustomCodePath
)

tlfInfo <- .runTLFWorkflowUC09(
  pc = pc,
  ePackageFolderPath = ePackageFolderPath,
  workflowRmdInProject = tlfInputs$workflowRmdInProject,
  fileNameReplacements = fileNameReplacements,
  projectDir = projectDir
)

# Phase 4: inspect final ePackage folder for output consistency.
ePackageInfo <- .inspectEPackage(ePackageFolderPath)

cat("\n=== TLF Output Files Check ===\n")
cat(
  "Expected TLF output folder:",
  tlfInfo$workflowRun$projectOutputFolder,
  "\n"
)
cat(
  "TLF runner executed successfully:",
  isTRUE(tlfInfo$workflowRun$success),
  "\n"
)
cat(
  "TLF runner output folder available:",
  !is.na(tlfInfo$workflowRun$projectOutputFolder),
  "\n\n"
)

# Phase 5: assert critical outcomes.
assertOrStop(
  simulationInfo$exportSucceeded,
  paste0(
    "Simulation workflow export failed: ",
    simulationInfo$exportResult$error
  )
)
assertOrStop(
  simulationInfo$modelRenameVerified,
  "Expected model rename from Aciclovir.pkml to acyclovir.pkml was not found in the exported simulation workflow runner"
)
assertOrStop(
  isTRUE(simulationInfo$workflowRun$success),
  paste0(
    "Simulation workflow execution failed: ",
    simulationInfo$workflowRun$error
  )
)
assertOrStop(
  simulationInfo$artifactsRestored,
  paste0(
    "Simulation workflow did not recreate all expected scenario result files. Missing: ",
    paste(basename(simulationInfo$missingResultFiles), collapse = ", ")
  )
)
assertOrStop(
  tlfInfo$exportSucceeded,
  paste0("TLF workflow export failed: ", tlfInfo$exportResult$error)
)
assertOrStop(
  isTRUE(tlfInfo$workflowRun$success),
  paste0("TLF workflow execution failed: ", tlfInfo$workflowRun$error)
)
assertOrStop(
  tlfInfo$artifactsCreated,
  "TLF workflow did not create the expected summary output files"
)
assertOrStop(
  tlfInfo$logExists,
  paste0("TLF workflow log file is missing: ", tlfInfo$logFile)
)
assertOrStop(
  tlfInfo$customCodeSourced,
  "TLF workflow log does not contain expected message: customCode was sourced"
)
assertOrStop(
  tlfInfo$numericValuesCountIsThree,
  "TLF workflow log does not contain the expected NumericValues row count of 3"
)
# Intentionally no hard assertion on summary artifacts; user disabled this check.
assertOrStop(
  tlfInfo$hasTimeprofilePngArtifacts,
  "TLF workflow did not export any time-profile PNG artifact"
)
assertOrStop(
  length(ePackageInfo$invalidFiles) == 0,
  paste0(
    "ePackage contains files with unsupported extensions: ",
    paste(ePackageInfo$invalidFiles, collapse = ", ")
  )
)

# Phase 6: write human-readable UC report.
reportLines <- c(
  "# UC-09 Electronic Package (ePackage) Export",
  "",
  "## Summary",
  "",
  "This scenario validates ePackage export for both simulation and TLF workflows.",
  "It exports each workflow, executes the exported runner script, and checks",
  "that the expected files are recreated or generated from the exported package.",
  "",
  "## Assertions",
  "",
  paste0(
    "- Scenarios created: ",
    paste(scenarioInfo$scenarioNames, collapse = ", ")
  ),
  paste0(
    "- Population CSV source assigned to ",
    populationScenarioName,
    ": ",
    populationSourceName,
    ".csv"
  ),
  paste0("- Scenarios simulated: ", scenarioInfo$scenarioResultsCount),
  if (simulationInfo$exportSucceeded) {
    "- Simulation workflow exported to ePackage: SUCCESS"
  } else {
    paste0(
      "- Simulation workflow export failed: ",
      simulationInfo$exportResult$error
    )
  },
  if (isTRUE(simulationInfo$workflowRun$success)) {
    "- Exported simulation workflow executed successfully"
  } else {
    paste0(
      "- Exported simulation workflow execution failed: ",
      simulationInfo$workflowRun$error
    )
  },
  if (simulationInfo$artifactsRestored) {
    paste0(
      "- Simulation runner recreated result files: ",
      paste(basename(scenarioInfo$simulationResultFiles), collapse = ", ")
    )
  } else {
    "- Simulation runner did not recreate all expected result files"
  },
  if (tlfInfo$exportSucceeded) {
    "- TLF workflow exported to ePackage: SUCCESS"
  } else {
    paste0("- TLF workflow export failed: ", tlfInfo$exportResult$error)
  },
  if (isTRUE(tlfInfo$workflowRun$success)) {
    "- Exported TLF workflow executed successfully"
  } else {
    paste0(
      "- Exported TLF workflow execution failed: ",
      tlfInfo$workflowRun$error
    )
  },
  if (tlfInfo$artifactsCreated) {
    "- TLF runner completed with a valid output folder"
  } else {
    "- TLF runner did not complete with a valid output folder"
  },
  paste0(
    "- Custom code sourcing verified in log: ",
    tlfInfo$customCodeSourced
  ),
  paste0(
    "- NumericValues row count equals 3 in log: ",
    tlfInfo$numericValuesCountIsThree
  ),
  paste0(
    "- TLF summary artifacts exported (.csv/.txt): ",
    tlfInfo$hasSummaryArtifacts,
    " (",
    if (length(tlfInfo$summaryFiles) > 0) {
      paste(basename(tlfInfo$summaryFiles), collapse = ", ")
    } else {
      "none"
    },
    ")"
  ),
  paste0(
    "- Time-profile PNG artifacts exported: ",
    tlfInfo$hasTimeprofilePngArtifacts,
    " (count: ",
    length(tlfInfo$timeprofilePngFiles),
    ")"
  ),
  paste0(
    "- ePackage contains only .txt, .xml, and .json files: ",
    length(ePackageInfo$invalidFiles) == 0
  ),
  "",
  "## Data Import",
  "",
  "- Data import source workbook: ReportInputs/DataImportMap_UC10.xlsx",
  "- Data import source CSV folder: ReportInputs/dataFiles",
  "- Data types: Time-profile observations (individual and aggregated)",
  "- Data import files are copied into project Data/ for template-based loading",
  "",
  "## ePackage Contents",
  "",
  paste0(
    "- ePackage workflow files created: ",
    length(ePackageInfo$workflowFiles) > 0
  ),
  if (length(ePackageInfo$workflowFiles) > 0) {
    paste0(
      "  - Files: ",
      paste(basename(ePackageInfo$workflowFiles), collapse = ", ")
    )
  },
  paste0(
    "- ePackage file extensions: ",
    paste(ePackageInfo$fileExtensions, collapse = ", ")
  ),
  paste0("- ePackage manifest files: ", length(ePackageInfo$inputFiles)),
  paste0(
    "- Configuration files in ePackage: ",
    length(ePackageInfo$configFiles)
  ),
  "",
  "## Project Configuration",
  "",
  paste0("- Project Directory: ", projectDir),
  paste0("- ePackage Folder: ", ePackageFolderPath),
  paste0("- Model File: ", modelFile),
  paste0("- Model Path: ", fs::path_abs(modelFile, start = pc$modelFolder)),
  paste0("- TLF workflow template source: ", tlfWorkflowTemplatePath),
  paste0("- TLF workflow copied to: ", tlfInputs$workflowRmdInProject),
  paste0("- Custom code copied to: ", tlfInputs$customCodeInProject),
  "",
  "## Exported Workflow Files",
  "",
  paste0(
    "- Workflow runners: ",
    paste(basename(ePackageInfo$workflowFiles), collapse = ", ")
  ),
  if (length(ePackageInfo$inputFiles) > 0) {
    paste0(
      "- Input manifests: ",
      paste(basename(ePackageInfo$inputFiles), collapse = ", ")
    )
  },
  if (length(ePackageInfo$configFiles) > 0) {
    paste0(
      "- Config and metadata files: ",
      paste(basename(ePackageInfo$configFiles), collapse = ", ")
    )
  },
  "",
  "## Execution Outputs",
  "",
  paste0(
    "- Simulation workflow output files verified: ",
    paste(basename(scenarioInfo$simulationResultFiles), collapse = ", ")
  ),
  paste0(
    "- TLF workflow project output folder: ",
    tlfInfo$workflowRun$projectOutputFolder
  ),
  ""
)

cat("\n=== Report Generation ===\n")
cat("Report lines generated:", length(reportLines), "\n")
cat("Report file path:", file.path(reportFolder, "Report.md"), "\n")

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))

cat("Report written successfully!\n")

assertOrStop(
  file.exists(file.path(reportFolder, "Report.md")),
  "Failed to create report file"
)

cat("UC-09 ePackage export functionality validation completed successfully!\n")

