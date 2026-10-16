#' @title report-uc-09-epackage-export
#' @description
#' Integration scenario for UC-09 electronic package (ePackage) export.

rm(list = ls())
#library(ospsuite.reportingframework)
pkgload::load_all(path = file.path('..', 'OSPSuite.ReportingFramework'))
source("R/helpers-uc-shared.R")

createUC09TLFWorkflow <- function(
  workflowPath,
  scenarioNames,
  summaryFileName,
  noteFileName
) {
  workflowLines <- c(
    "---",
    "title: \"UC-09 TLF Workflow\"",
    "output: html_document",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "knitr::opts_chunk$set(echo = FALSE)",
    "```",
    "",
    "```{r libraries-copy}",
    "library(ospsuite.reportingframework)",
    "library(data.table)",
    "```",
    "",
    "```{r pathsCustomfunctions-eval}",
    "pathsCustomfunctions <- c()",
    "```",
    "",
    "```{r dataObserved-eval}",
    "dataObserved <- NULL",
    "```",
    "",
    "```{r dataObservedPK-eval}",
    "dataObservedPK <- NULL",
    "```",
    "",
    "```{r scenarioNames-eval}",
    paste0(
      "scenarioNames <- c(",
      paste(sprintf("\"%s\"", scenarioNames), collapse = ", "),
      ")"
    ),
    "```",
    "",
    "```{r loadResults-copy}",
    "scenarioResults <- loadScenarioResultsToFramework(",
    "  projectConfiguration = projectConfiguration,",
    "  scenarioNames = scenarioNames",
    ")",
    "```",
    "",
    "```{r runPlot-copy}",
    paste0(
      "summaryCsv <- file.path(projectConfiguration$outputFolder, \"",
      summaryFileName,
      "\")"
    ),
    paste0(
      "summaryTxt <- file.path(projectConfiguration$outputFolder, \"",
      noteFileName,
      "\")"
    ),
    "resultFiles <- file.path(",
    "  projectConfiguration$outputFolder,",
    "  EXPORTDIR$simulationResult,",
    "  paste0(scenarioNames, '.csv')",
    ")",
    "summaryDT <- data.table::data.table(",
    "  scenario = scenarioNames,",
    "  resultFile = basename(resultFiles),",
    "  resultFileExists = file.exists(resultFiles),",
    "  resultFileBytes = ifelse(",
    "    file.exists(resultFiles),",
    "    file.info(resultFiles)$size,",
    "    NA_real_",
    "  )",
    ")",
    "data.table::fwrite(summaryDT, summaryCsv)",
    "writeLines(",
    "  c(",
    "    'UC-09 exported TLF workflow',",
    "    paste('Scenarios:', paste(summaryDT$scenario, collapse = ', '))",
    "  ),",
    "  summaryTxt",
    ")",
    "```",
    ""
  )

  writeLines(workflowLines, con = workflowPath)
  invisible(workflowPath)
}

removeExistingFiles <- function(filePaths) {
  existingFiles <- filePaths[file.exists(filePaths)]
  if (length(existingFiles) > 0) {
    unlink(existingFiles, force = TRUE)
  }
  invisible(existingFiles)
}

reportFolder <- file.path("tests", "Reports", "UC-09-EPackage-Export")
projectDir <- tempfile(pattern = "uc09_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

# Initialize project and create minimal configuration
pc <- setupProject(projectDir)

# Copy model file
modelFile <- "Aciclovir.pkml"
copyModelFiles(pc, modelFile)

baseScenarioName <- "UC09_Scenario1"
populationScenarioName <- "UC09_PopulationScenario"
populationSourceName <- "adults"

# # Test ePackage export functionality
# ePackageFolderPath <- pc$addOns$electronicPackageFolder
# assertOrStop(
#   !is.null(ePackageFolderPath),
#   "ePackage folder path not set in project configuration"
# )

# # Verify ePackage folder exists or can be created
# dir.create(ePackageFolderPath, recursive = TRUE, showWarnings = FALSE)
# assertOrStop(
#     dir.exists(ePackageFolderPath),
#     paste0("Failed to create ePackage folder at: ", ePackageFolderPath)
# )

# # Verify exportSimulationWorkflowToEPackage function exists
# assertOrStop(
#   exists("exportSimulationWorkflowToEPackage"),
#   "exportSimulationWorkflowToEPackage function not found"
# )

# # Verify exportTLFWorkflowToEPackage function exists
# assertOrStop(
#   exists("exportTLFWorkflowToEPackage"),
#   "exportTLFWorkflowToEPackage function not found"
# )

# # Verify openEPackageTemplate function exists
# assertOrStop(
#   exists("openEPackageTemplate"),
#   "openEPackageTemplate function not found"
# )

# Step 1: Create scenarios for ePackage export
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
      populationId = populationSourceName,
      modelFile = modelFile
    )
  ),
  use.names = TRUE
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

# Create scenarios and run simulations
scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)

# # Run scenarios to generate results for export
# scenarioResults <- runAndSaveScenarios(pc, scenarioList)
# scenarioResultsCount <- length(scenarioResults)
#
# assertOrStop(
#   scenarioResultsCount > 0,
#   "No scenario results generated for ePackage export"
# )

# Step 2: Attempt to export simulation workflow to ePackage
simulationExportResult <- tryCatch(
  {
    exportSimulationWorkflowToEPackage(
      projectConfiguration = pc,
      wfIdentifier = 1,
      scenarioNames = scenarioNames,
      fileNameReplacements = c('Aciclovir.pkml', 'acyclovir.pkml')
    )
    list(success = TRUE, error = NA_character_)
  },
  error = function(e) {
    list(success = FALSE, error = e$message)
  }
)

simulationExportSucceeded <- isTRUE(simulationExportResult$success)

populationScenarioResultFiles <- file.path(
  pc$outputFolder,
  EXPORTDIR$simulationResult,
  paste0(populationScenarioName, c(".csv", "_population.csv"))
)
simulationResultFiles <- file.path(
  pc$outputFolder,
  EXPORTDIR$simulationResult,
  paste0(scenarioNames, ".csv")
)
# simulationFilesToRemove <- unique(c(
#   simulationResultFiles,
#   populationScenarioResultFiles
# ))

# removeExistingFiles(simulationFilesToRemove)

ePackageFolderPath <- pc$addOns$electronicPackageFolder

simulationWorkflowRun <- executeExportedWorkflow(
  ePackageFolder = ePackageFolderPath,
  wfIdentifier = 1,
  monitoredRoots = c(
    simulationResults = file.path(
      pc$outputFolder,
      EXPORTDIR$simulationResult
    )
  )
)

simulationResultFiles <- file.path(
  simulationWorkflowRun$projectOutputFolder,
  EXPORTDIR$simulationResult,
  paste0(scenarioNames, ".csv")
)
populationRenameResultFile <- file.path(
  simulationWorkflowRun$projectOutputFolder,
  EXPORTDIR$simulationResult,
  paste0(populationScenarioName, "_population.csv")
)
simulationWorkflowArtifactsRestored <-
  !is.na(simulationWorkflowRun$projectOutputFolder) &&
  all(file.exists(simulationResultFiles))

populationWorkflowArtifactRenamed <-
  !is.na(simulationWorkflowRun$projectOutputFolder) &&
  file.exists(populationRenameResultFile)
tlfWorkflowPath <- file.path(projectDir, "uc09_tlf_workflow.Rmd")
tlfSummaryFileName <- "UC09_TLF_Summary.csv"
tlfDataImportSummaryFileName <- "UC09_TLF_DataImport_Summary.csv"

# Copy data import fixtures to project configuration folder
dataImportSourcePath <- reportInputsPath("UC09_DataImport")
projectScriptsDir <- dirname(pc$scenariosFile)
dataImportDestPath <- file.path(projectScriptsDir, "UC09_DataImport")
dir.create(dataImportDestPath, recursive = TRUE, showWarnings = FALSE)

# Copy CSV files
file.copy(
  from = file.path(dataImportSourcePath, "tp_individual.csv"),
  to = file.path(dataImportDestPath, "tp_individual.csv"),
  overwrite = TRUE
)
file.copy(
  from = file.path(dataImportSourcePath, "tp_aggregated.csv"),
  to = file.path(dataImportDestPath, "tp_aggregated.csv"),
  overwrite = TRUE
)

# Copy and reference configuration locally
file.copy(
  from = file.path(dataImportSourcePath, "DataImportConfiguration.xlsx"),
  to = file.path(dataImportDestPath, "DataImportConfiguration.xlsx"),
  overwrite = TRUE
)

# Path to data import configuration (relative to project scripts folder)
dataImportConfigPath <- file.path(
  dataImportDestPath,
  "DataImportConfiguration.xlsx"
)

createUC09TLFWorkflowWithDataImport(
  workflowPath = tlfWorkflowPath,
  scenarioNames = scenarioNames,
  dataImportConfigFile = dataImportConfigPath,
  summaryFileName = tlfSummaryFileName,
  dataImportSummaryFileName = tlfDataImportSummaryFileName
)

tlfExportResult <- tryCatch(
  {
    exportTLFWorkflowToEPackage(
      projectConfiguration = pc,
      wfIdentifier = 2,
      workflowRmd = tlfWorkflowPath
    )
    list(success = TRUE, error = NA_character_)
  },
  error = function(e) {
    list(success = FALSE, error = e$message)
  }
)

tlfExportSucceeded <- isTRUE(tlfExportResult$success)

tlfOutputFilesToRemove <- file.path(
  pc$outputFolder,
  c(tlfSummaryFileName, tlfDataImportSummaryFileName)
)
removeExistingFiles(tlfOutputFilesToRemove)

tlfWorkflowRun <- executeExportedWorkflow(
  ePackageFolder = ePackageFolderPath,
  wfIdentifier = 2,
  monitoredRoots = c(
    outputRoot = pc$outputFolder
  )
)

tlfOutputFiles <- file.path(
  tlfWorkflowRun$projectOutputFolder,
  c(tlfSummaryFileName, tlfDataImportSummaryFileName)
)
tlfWorkflowArtifactsCreated <- all(file.exists(tlfOutputFiles))

# DEBUG: Print what files exist
cat("\n=== TLF Output Files Check ===\n")
cat("Expected TLF output folder:", tlfWorkflowRun$projectOutputFolder, "\n")
for (i in seq_along(tlfOutputFiles)) {
  exists <- file.exists(tlfOutputFiles[i])
  cat(sprintf(
    "[%s] %s\n",
    if (exists) "✓" else "✗",
    basename(tlfOutputFiles[i])
  ))
}
cat("All files exist:", tlfWorkflowArtifactsCreated, "\n\n")

# Step 3: Verify ePackage structure and files
ePackageContents <- list.files(
  ePackageFolderPath,
  recursive = TRUE,
  full.names = FALSE
)

allowedEPackageExtensions <- c("txt", "xml", "json")
ePackageFileExtensions <- sort(unique(tolower(tools::file_ext(
  ePackageContents
))))
invalidEPackageFiles <- ePackageContents[
  !tolower(tools::file_ext(ePackageContents)) %in% allowedEPackageExtensions
]

ePackageWorkflowFiles <- list.files(
  ePackageFolderPath,
  pattern = "^w[0-9]+_workflow_r\\.txt$",
  full.names = TRUE
)

ePackageFilesCreated <- length(ePackageWorkflowFiles) > 0

ePackageInputFiles <- list.files(
  ePackageFolderPath,
  pattern = "_input_files(?:_csv)?\\.txt$",
  full.names = TRUE
)

# Check for configuration files in ePackage
ePackageConfigFiles <- list.files(
  ePackageFolderPath,
  pattern = "_config_json\\.txt$",
  full.names = TRUE
)

configFilesCount <- length(ePackageConfigFiles)

assertOrStop(
  simulationExportSucceeded,
  paste0(
    "Simulation workflow export failed: ",
    simulationExportResult$error
  )
)
assertOrStop(
  isTRUE(simulationWorkflowRun$success),
  paste0(
    "Simulation workflow execution failed: ",
    simulationWorkflowRun$error
  )
)
assertOrStop(
  simulationWorkflowArtifactsRestored,
  "Simulation workflow did not recreate all expected scenario result files"
)
assertOrStop(
  populationWorkflowArtifactRenamed,
  paste0(
    "Simulation workflow did not recreate the renamed population CSV: ",
    basename(populationRenameResultFile)
  )
)
assertOrStop(
  tlfExportSucceeded,
  paste0("TLF workflow export failed: ", tlfExportResult$error)
)
assertOrStop(
  isTRUE(tlfWorkflowRun$success),
  paste0("TLF workflow execution failed: ", tlfWorkflowRun$error)
)
assertOrStop(
  tlfWorkflowArtifactsCreated,
  "TLF workflow did not create the expected summary output files"
)
assertOrStop(
  length(invalidEPackageFiles) == 0,
  paste0(
    "ePackage contains files with unsupported extensions: ",
    paste(invalidEPackageFiles, collapse = ", ")
  )
)

# Generate validation report
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
  paste0("- Scenarios created: ", paste(scenarioNames, collapse = ", ")),
  paste0(
    "- Population CSV source assigned to ",
    populationScenarioName,
    ": ",
    populationSourceName,
    ".csv"
  ),
  paste0("- Scenarios simulated: ", scenarioResultsCount),
  if (simulationExportSucceeded) {
    "- Simulation workflow exported to ePackage: SUCCESS"
  } else {
    paste0(
      "- Simulation workflow export failed: ",
      simulationExportResult$error
    )
  },
  if (isTRUE(simulationWorkflowRun$success)) {
    "- Exported simulation workflow executed successfully"
  } else {
    paste0(
      "- Exported simulation workflow execution failed: ",
      simulationWorkflowRun$error
    )
  },
  if (simulationWorkflowArtifactsRestored) {
    paste0(
      "- Simulation runner recreated result files: ",
      paste(basename(simulationResultFiles), collapse = ", ")
    )
  } else {
    "- Simulation runner did not recreate all expected result files"
  },
  if (populationWorkflowArtifactRenamed) {
    paste0(
      "- Simulation runner recreated renamed population CSV: ",
      basename(populationRenameResultFile)
    )
  } else {
    paste0(
      "- Simulation runner did not recreate renamed population CSV: ",
      basename(populationRenameResultFile)
    )
  },
  if (tlfExportSucceeded) {
    "- TLF workflow exported to ePackage: SUCCESS"
  } else {
    paste0("- TLF workflow export failed: ", tlfExportResult$error)
  },
  if (isTRUE(tlfWorkflowRun$success)) {
    "- Exported TLF workflow executed successfully"
  } else {
    paste0(
      "- Exported TLF workflow execution failed: ",
      tlfWorkflowRun$error
    )
  },
  if (tlfWorkflowArtifactsCreated) {
    paste0(
      "- TLF runner created output files: ",
      paste(basename(tlfOutputFiles), collapse = ", ")
    )
  } else {
    "- TLF runner did not create all expected output files"
  },
  paste0(
    "- ePackage contains only .txt, .xml, and .json files: ",
    length(invalidEPackageFiles) == 0
  ),
  "",
  "## Data Import",
  "",
  "- Data import source: UC09_DataImport/DataImportConfiguration.xlsx",
  "- Data types: Time-profile observations (individual and aggregated)",
  paste0(
    "- Data import summary file generated: ",
    file.exists(tlfOutputFiles[2])
  ),
  "",
  "## ePackage Contents",
  "",
  paste0("- ePackage workflow files created: ", ePackageFilesCreated),
  if (ePackageFilesCreated) {
    paste0(
      "  - Files: ",
      paste(basename(ePackageWorkflowFiles), collapse = ", ")
    )
  },
  paste0(
    "- ePackage file extensions: ",
    paste(ePackageFileExtensions, collapse = ", ")
  ),
  paste0("- ePackage manifest files: ", length(ePackageInputFiles)),
  paste0("- Configuration files in ePackage: ", configFilesCount),
  "",
  "## Project Configuration",
  "",
  paste0("- Project Directory: ", projectDir),
  paste0("- ePackage Folder: ", ePackageFolderPath),
  paste0("- Model File: ", modelFile),
  paste0("- Model Path: ", fs::path_abs(modelFile, start = pc$modelFolder)),
  paste0("- TLF workflow template: ", tlfWorkflowPath),
  "",
  "## Exported Workflow Files",
  "",
  paste0(
    "- Workflow runners: ",
    paste(basename(ePackageWorkflowFiles), collapse = ", ")
  ),
  if (length(ePackageInputFiles) > 0) {
    paste0(
      "- Input manifests: ",
      paste(basename(ePackageInputFiles), collapse = ", ")
    )
  },
  if (length(ePackageConfigFiles) > 0) {
    paste0(
      "- Config and metadata files: ",
      paste(basename(ePackageConfigFiles), collapse = ", ")
    )
  },
  "",
  "## Execution Outputs",
  "",
  paste0(
    "- Simulation workflow output files verified: ",
    paste(basename(simulationResultFiles), collapse = ", ")
  ),
  paste0(
    "- Renamed population CSV verified: ",
    basename(populationRenameResultFile)
  ),
  paste0(
    "- TLF workflow output files verified: ",
    paste(basename(tlfOutputFiles), collapse = ", ")
  ),
  ""
)

cat("\n=== Report Generation ===\n")
cat("Report lines generated:", length(reportLines), "\n")
cat("Report file path:", file.path(reportFolder, "Report.md"), "\n")

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))

cat("Report written successfully!\n")

# Verify report creation
assertOrStop(
  file.exists(file.path(reportFolder, "Report.md")),
  "Failed to create report file"
)

cat("UC-09 ePackage export functionality validation completed successfully!\n")
