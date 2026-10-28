#' @title report-uc-09-epackage-export
#' @description
#' Integration scenario for UC-09 electronic package (ePackage) export.

rm(list = ls())
#library(ospsuite.reportingframework)
pkgload::load_all(
  path = file.path(
    'C:/Users/17fec1a5/Documents/GitHub/',
    'OSPSuite.ReportingFramework'
  )
)
source("R/helpers-uc-shared.R")
setWorkflowOptions(isValidRun = FALSE)

# Prevent accidental creation of Rplots.pdf by using a null default device.
originalDeviceOption <- getOption("device")
options(device = function(...) grDevices::pdf(NULL))
on.exit(options(device = originalDeviceOption), add = TRUE)

reportFolder <- file.path("tests", "Reports", "UC-09-EPackage-Export")
projectDir <- tempfile(pattern = "uc09_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

# Step 1: setup base Project ---------------------

# Initialize project and create minimal configuration
pc <- setupProject(projectDir)

# Copy model file
modelFile <- "Aciclovir.pkml"
copyModelFiles(pc, modelFile)
fileNameReplacements <- c(modelFile, "acyclovir.pkml")

baseScenarioName <- "UC09_Scenario1"
populationScenarioName <- "UC09_PopulationScenario"
populationSourceName <- "adults"

# Test ePackage export functionality
ePackageFolderPath <- pc$addOns$electronicPackageFolder
assertOrStop(
  !is.null(ePackageFolderPath),
  "ePackage folder path not set in project configuration"
)

# Verify ePackage folder exists or can be created
dir.create(ePackageFolderPath, recursive = TRUE, showWarnings = FALSE)
assertOrStop(
  dir.exists(ePackageFolderPath),
  paste0("Failed to create ePackage folder at: ", ePackageFolderPath)
)


# Workflow execution

# Step 1: Create and run scenarios for ePackage export
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

# Create scenarios and run simulations
scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
scenarioResultsCount <- length(scenarioNames)


# Step 2: Attempt to export simulation workflow to ePackage -----------------
simulationExportResult <- tryCatch(
  {
    exportSimulationWorkflowToEPackage(
      projectConfiguration = pc,
      wfIdentifier = 1,
      scenarioNames = scenarioNames,
      fileNameReplacements = fileNameReplacements
    )
    list(success = TRUE, error = NA_character_)
  },
  error = function(e) {
    list(success = FALSE, error = e$message)
  }
)

simulationExportSucceeded <- isTRUE(simulationExportResult$success)

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

simulationResultFiles <- file.path(
  pc$outputFolder,
  EXPORTDIR$simulationResult,
  paste0(scenarioNames, ".csv")
)

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

missingSimulationResultFiles <- simulationResultFiles[
  !file.exists(simulationResultFiles)
]
simulationWorkflowArtifactsRestored <-
  length(missingSimulationResultFiles) == 0

# Step 3: TLF workflow ----------

tlfWorkflowTemplatePath <- reportInputsPath("UC09_ePackageWorkflow.Rmd")
tlfCustomCodePath <- reportInputsPath("UC09_customCode.R")

# Copy UC10 data import fixtures into the project.
copiedDataImportCsvFiles <- copyUC10DataImportFixtures(pc)

workflowRmdInProject <- file.path(pc$configurationsFolder, "workflow.Rmd")
customCodeInProject <- file.path(pc$configurationsFolder, "..", "customCode.R")

file.copy(
  from = tlfWorkflowTemplatePath,
  to = workflowRmdInProject,
  overwrite = TRUE
)
file.copy(
  from = tlfCustomCodePath,
  to = customCodeInProject,
  overwrite = TRUE
)

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
outputsSheetName <- "Outputs"

wbReport <- openxlsx::loadWorkbook(reportsWorkbookPath)
outputsConfig <- xlsxReadData(wbReport, sheetName = outputsSheetName)


emptyDisplayName <-
  is.na(outputsConfig[["displayName"]]) |
  trimws(outputsConfig[["displayName"]]) == ""
outputsConfig[
  emptyDisplayName,
  displayName := outputPathId
]

emptyDisplayUnit <-
  is.na(outputsConfig$displayUnit) |
  trimws(outputsConfig$displayUnit) == ""
outputsConfig[
  emptyDisplayUnit,
  displayUnit := "\u00B5g/L"
]

xlsxWriteData(wbReport, sheetName = outputsSheetName, outputsConfig)
openxlsx::saveWorkbook(
  wbReport,
  reportsWorkbookPath,
  overwrite = TRUE
)

tlfExportResult <- tryCatch(
  {
    exportTLFWorkflowToEPackage(
      projectConfiguration = pc,
      wfIdentifier = 2,
      workflowRmd = workflowRmdInProject,
      fileNameReplacements = fileNameReplacements
    )
    list(success = TRUE, error = NA_character_)
  },
  error = function(e) {
    list(success = FALSE, error = e$message)
  }
)

tlfExportSucceeded <- isTRUE(tlfExportResult$success)

tlfWorkflowRun <- if (tlfExportSucceeded) {
  executeExportedWorkflow(
    ePackageFolder = ePackageFolderPath,
    wfIdentifier = 2,
    monitoredRoots = c(
      outputRoot = pc$outputFolder
    )
  )
} else {
  list(
    success = FALSE,
    error = tlfExportResult$error,
    projectOutputFolder = NA_character_,
    runnerFile = file.path(ePackageFolderPath, "w2_workflow_r.txt"),
    filesAfter = list(),
    newFiles = list()
  )
}

tlfWorkflowArtifactsCreated <-
  isTRUE(tlfWorkflowRun$success) &&
  !is.na(tlfWorkflowRun$projectOutputFolder)

tlfLogFile <- if (!is.na(tlfWorkflowRun$projectOutputFolder)) {
  file.path(tlfWorkflowRun$projectOutputFolder, "logs", "workflow.log")
} else {
  NA_character_
}
tlfLogExists <- !is.na(tlfLogFile) && file.exists(tlfLogFile)
tlfLogLines <- if (tlfLogExists) {
  readLines(tlfLogFile, warn = FALSE)
} else {
  character(0)
}
tlfCustomCodeSourced <- any(grepl("customCode was sourced", tlfLogLines))

numericValuesMatches <- regexec(
  "Nrow NumericalValues:=\\s*([0-9]+)",
  tlfLogLines
)
numericValuesCaptured <- regmatches(tlfLogLines, numericValuesMatches)
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
tlfNumericValuesCountIsThree <- any(numericValuesCounts == 3, na.rm = TRUE)

tlfExpectedTimeprofilePng <- if (!is.na(tlfWorkflowRun$projectOutputFolder)) {
  file.path(
    tlfWorkflowRun$projectOutputFolder,
    "Timeprofile",
    "UC09_Scenario1.png"
  )
} else {
  NA_character_
}
tlfExpectedTimeprofilePngCreated <-
  !is.na(tlfExpectedTimeprofilePng) && file.exists(tlfExpectedTimeprofilePng)

# DEBUG: Print what files exist
cat("\n=== TLF Output Files Check ===\n")
cat("Expected TLF output folder:", tlfWorkflowRun$projectOutputFolder, "\n")
cat("TLF runner executed successfully:", isTRUE(tlfWorkflowRun$success), "\n")
cat(
  "TLF runner output folder available:",
  !is.na(tlfWorkflowRun$projectOutputFolder),
  "\n\n"
)

# Step 3: Verify ePackage structure and files
ePackageContents <- list.files(
  ePackageFolderPath,
  recursive = TRUE,
  full.names = FALSE
)

# Remove transient graphics device artifact if present.
ePackageContents <- ePackageContents[
  basename(ePackageContents) != "Rplots.pdf"
]

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
  modelRenameVerified,
  "Expected model rename from Aciclovir.pkml to acyclovir.pkml was not found in the exported simulation workflow runner"
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
  paste0(
    "Simulation workflow did not recreate all expected scenario result files. Missing: ",
    paste(basename(missingSimulationResultFiles), collapse = ", ")
  )
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
  tlfLogExists,
  paste0("TLF workflow log file is missing: ", tlfLogFile)
)
assertOrStop(
  tlfCustomCodeSourced,
  "TLF workflow log does not contain expected message: customCode was sourced"
)
assertOrStop(
  tlfNumericValuesCountIsThree,
  "TLF workflow log does not contain the expected NumericValues row count of 3"
)
assertOrStop(
  tlfExpectedTimeprofilePngCreated,
  paste0(
    "TLF workflow did not export expected file: ",
    tlfExpectedTimeprofilePng
  )
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
    "- TLF runner completed with a valid output folder"
  } else {
    "- TLF runner did not complete with a valid output folder"
  },
  paste0(
    "- Custom code sourcing verified in log: ",
    tlfCustomCodeSourced
  ),
  paste0(
    "- NumericValues row count equals 3 in log: ",
    tlfNumericValuesCountIsThree
  ),
  paste0(
    "- Expected time-profile PNG exported: ",
    tlfExpectedTimeprofilePngCreated,
    " (",
    basename(tlfExpectedTimeprofilePng),
    ")"
  ),
  paste0(
    "- ePackage contains only .txt, .xml, and .json files: ",
    length(invalidEPackageFiles) == 0
  ),
  "",
  "## Data Import",
  "",
  "- Data import source workbook: ReportInputs/DataImportConfiguration_UC10.xlsx",
  "- Data import source CSV folder: ReportInputs/dataFiles",
  "- Data types: Time-profile observations (individual and aggregated)",
  "- Data import files are copied into project Data/ for template-based loading",
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
  paste0("- TLF workflow template source: ", tlfWorkflowTemplatePath),
  paste0("- TLF workflow copied to: ", workflowRmdInProject),
  paste0("- Custom code copied to: ", customCodeInProject),
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
    "- TLF workflow project output folder: ",
    tlfWorkflowRun$projectOutputFolder
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
