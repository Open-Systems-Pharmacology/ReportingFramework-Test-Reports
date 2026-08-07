#' @title report-uc-04-pk-parameter-loading
#' @description
#' Integration scenario for UC-04 PK parameter calculation and loading.

rm(list = ls())
pkgload::load_all("../OSPSuite.ReportingFramework", quiet = TRUE)

reportFolder <- file.path("tests", "Reports", "UC-04-PK-Parameter-Loading")
projectDir <- file.path(reportFolder, "project")

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

assertOrStop <- function(condition, message) {
    if (!isTRUE(condition)) {
        stop(message, call. = FALSE)
    }
    invisible(NULL)
}

initProject(projectDirectory = projectDir, overwrite = TRUE)

configurationDir <- file.path(projectDir, "Scripts", "ReportingFramework")
projectConfigPath <- file.path(configurationDir, "ProjectConfiguration.xlsx")

pc <- createProjectConfiguration(
    path = projectConfigPath,
    ignoreVersionCheck = FALSE
)

scenariosFile <- file.path(configurationDir, "Scenarios.xlsx")
pkParameterFile <- file.path(configurationDir, "PKParameter.xlsx")

wbScenarios <- openxlsx::loadWorkbook(scenariosFile)
scenariosConfig <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
scenarioOutputs <- xlsxReadData(wbScenarios, sheetName = "OutputPaths")

repositoryModelsDir <- "Models"
modelFile <- "Aciclovir.pkml"
sourceModelPath <- file.path(repositoryModelsDir, modelFile)
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

defaultIndividualId <- as.character(scenariosConfig$individualId[[1]])
defaultOutputPathId <- as.character(scenarioOutputs$outputPathId[[1]])

scenarioSetup <- data.table::data.table(
    scenario_name = c("UC04_ScenarioA", "UC04_ScenarioB"),
    individualId = c(defaultIndividualId, defaultIndividualId),
    populationId = c(NA_character_, NA_character_),
    readPopulationFromCSV = c(NA, NA),
    modelParameterSheets = c(NA_character_, NA_character_),
    applicationProtocol = c(NA_character_, NA_character_),
    simulationTime = c("0, 24, 60", "0, 24, 60"),
    simulationTimeUnit = c("h", "h"),
    steadyState = c(NA, NA),
    steadyStateTime = c(NA, NA),
    steadyStateTimeUnit = c(NA_character_, NA_character_),
    modelFile = c(modelFile, modelFile),
    outputPathsIds = c(defaultOutputPathId, defaultOutputPathId)
)

pkScenarioSetup <- data.table::data.table(
    scenario_name = c("UC04_ScenarioA", "UC04_ScenarioB"),
    pKParameter = c("PK_Plasma", "PK_Plasma")
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
xlsxWriteData(wbScenarios, sheetName = "PKParameter", pkScenarioSetup)
openxlsx::saveWorkbook(wbScenarios, scenariosFile, overwrite = TRUE)

wbPk <- openxlsx::loadWorkbook(pkParameterFile)
pkTemplate <- xlsxReadData(
    wbPk,
    sheetName = "Template",
    skipDescriptionRow = TRUE
)
pkSheetData <- pkTemplate[
    pkTemplate$name %in% c("C_max", "t_max", "AUC_tEnd"),
]
pkSheetData$outputPathIds <- defaultOutputPathId
pkSheetData <- rbind(
    pkSheetData,
    data.table::data.table(
        name = "F_max",
        displayName = "F max",
        displayUnit = "%",
        outputPathIds = defaultOutputPathId,
        descriptions = "User-defined PK parameter"
    ),
    fill = TRUE
)

if ("PK_Plasma" %in% openxlsx::getSheetNames(pkParameterFile)) {
    openxlsx::removeWorksheet(wbPk, "PK_Plasma")
}
openxlsx::addWorksheet(wbPk, "PK_Plasma")
openxlsx::writeData(wbPk, sheet = "PK_Plasma", x = pkSheetData)
openxlsx::saveWorkbook(wbPk, pkParameterFile, overwrite = TRUE)

scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
assertOrStop(length(scenarioList) == 2, "UC-04 requires two scenarios")

scenarioResults <- runAndSaveScenarios(pc, scenarioList)
calculatePKParameterForScenarios(pc, scenarioResults)

pkResultsFolder <- file.path(pc$outputFolder, EXPORTDIR$pKAnalysisResults)
pkResultFiles <- file.path(pkResultsFolder, paste0(scenarioNames, ".csv"))
assertOrStop(
    all(file.exists(pkResultFiles)),
    "calculatePKParameterForScenarios() did not create one CSV file per scenario"
)

pkParameterDT <- loadPKParameter(pc, scenarioList)
validatePKParameterDT(pkParameterDT)

requiredColumns <- c(
    "scenario",
    "pkParameter",
    "individualId",
    "value",
    "outputPathId",
    "displayNamePKParameter",
    "displayUnitPKParameter"
)
assertOrStop(
    all(requiredColumns %in% names(pkParameterDT)),
    "loadPKParameter() result is missing required columns"
)
assertOrStop(
    "F_max" %in% pkParameterDT$pkParameter,
    "User-defined PK parameter F_max is missing from loaded PK results"
)

reportLines <- c(
    "# UC-04 PK parameter calculation and loading",
    "",
    "## Summary",
    "",
    "This scenario validates PK calculation, PK loading, PK data validation, and inclusion of a user-defined PK parameter.",
    "",
    "## Assertions",
    "",
    paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
    paste0(
        "- PK sheets linked from Scenarios.xlsx: ",
        paste(unique(pkScenarioSetup$pKParameter), collapse = ", ")
    ),
    "- calculatePKParameterForScenarios created one CSV file per scenario.",
    paste0(
        "- Required columns present: ",
        paste(requiredColumns, collapse = ", ")
    ),
    "- validatePKParameterDT passed without error.",
    "- User-defined PK parameter F_max appears in loaded results.",
    "",
    "## PK result CSV files",
    ""
)

for (resultFile in sort(basename(pkResultFiles))) {
    reportLines <- c(reportLines, paste0("- ", resultFile))
}

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
