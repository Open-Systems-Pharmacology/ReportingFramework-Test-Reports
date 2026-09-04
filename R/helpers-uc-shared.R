#' @description Shared helpers used across all use-case integration scripts.

assertOrStop <- function(condition, message) {
  if (!isTRUE(condition)) {
    stop(message, call. = FALSE)
  }
  invisible(NULL)
}

# Initialises a temp project and returns its ProjectConfiguration object.
setupProject <- function(projectDir, ignoreVersionCheck = FALSE) {
  initProject(projectDirectory = projectDir, overwrite = TRUE)
  createProjectConfiguration(
    path = file.path(
      projectDir,
      "Scripts",
      "ReportingFramework",
      "ProjectConfiguration.xlsx"
    ),
    ignoreVersionCheck = ignoreVersionCheck
  )
}

# Copies modelFile from modelsDir into the project's model folder.
copyModelFile <- function(pc, modelFile, modelsDir = "Models") {
  sourceModelPath <- file.path(modelsDir, modelFile)
  targetModelPath <- fs::path_abs(modelFile, start = pc$modelFolder)
  assertOrStop(
    file.exists(sourceModelPath),
    paste0("Source model file not found: ", sourceModelPath)
  )
  if (!file.exists(targetModelPath)) {
    ignore <- file.copy(sourceModelPath, targetModelPath, overwrite = TRUE)
  }
  assertOrStop(
    file.exists(targetModelPath),
    paste0("Model file not found: ", targetModelPath)
  )
  invisible(NULL)
}

# Builds the standard two-column scenario data.table used by most UCs.
makeDefaultScenarioTable <- function(
  scenarioNames,
  individualId,
  outputPathId,
  modelFile
) {
  n <- length(scenarioNames)
  data.table::data.table(
    scenario_name = scenarioNames,
    individualId = rep(individualId, n),
    populationId = rep(NA_character_, n),
    readPopulationFromCSV = rep(NA, n),
    modelParameterSheets = rep(NA_character_, n),
    applicationProtocol = rep(NA_character_, n),
    simulationTime = rep("0, 24, 60", n),
    simulationTimeUnit = rep("h", n),
    steadyState = rep(NA, n),
    steadyStateTime = rep(NA, n),
    steadyStateTimeUnit = rep(NA_character_, n),
    modelFile = rep(modelFile, n),
    outputPathsIds = rep(outputPathId, n)
  )
}

# Writes standard PK parameters to the PK_Plasma sheet; extraRows are appended when supplied.
setupPKPlasmaSheet <- function(
  pkParameterFile,
  outputPathId,
  extraRows = NULL
) {
  wbPk <- openxlsx::loadWorkbook(pkParameterFile)
  pkTemplate <- xlsxReadData(
    wbPk,
    sheetName = "Template",
    skipDescriptionRow = TRUE
  )
  pkSheetData <- pkTemplate[
    pkTemplate$name %in% c("C_max", "t_max", "AUC_tEnd"),
  ]
  pkSheetData$outputPathIds <- outputPathId
  if (!is.null(extraRows)) {
    pkSheetData <- rbind(pkSheetData, extraRows, fill = TRUE)
  }
  if ("PK_Plasma" %in% openxlsx::getSheetNames(pkParameterFile)) {
    openxlsx::removeWorksheet(wbPk, "PK_Plasma")
  }
  openxlsx::addWorksheet(wbPk, "PK_Plasma")
  openxlsx::writeData(wbPk, sheet = "PK_Plasma", x = pkSheetData)
  openxlsx::saveWorkbook(wbPk, pkParameterFile, overwrite = TRUE)
  invisible(NULL)
}

# Fills missing displayName / displayUnit in the Outputs sheet with sensible defaults.
configureOutputsSheet <- function(pc) {
  wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)
  outputsSheet <- xlsxReadData(
    wbReports,
    sheetName = "Outputs",
    skipDescriptionRow = FALSE
  )
  missingDisplayNames <- is.na(outputsSheet$displayName) |
    trimws(as.character(outputsSheet$displayName)) == ""
  outputsSheet$displayName[missingDisplayNames] <-
    paste(as.character(outputsSheet$outputPathId[missingDisplayNames]), "disp")
  missingDisplayUnits <- is.na(outputsSheet$displayUnit) |
    trimws(as.character(outputsSheet$displayUnit)) == ""
  outputsSheet$displayUnit[missingDisplayUnits] <- "µg/l"
  xlsxWriteData(wbReports, sheetName = "Outputs", outputsSheet)
  openxlsx::saveWorkbook(wbReports, pc$addOns$reportsFile, overwrite = TRUE)
  invisible(NULL)
}
