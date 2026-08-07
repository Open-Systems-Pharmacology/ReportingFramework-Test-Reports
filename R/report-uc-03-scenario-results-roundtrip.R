#' @title report-uc-03-scenario-results-roundtrip
#' @description
#' Integration scenario for UC-03 simulate, save and reload scenario results.

rm(list = ls())
pkgload::load_all("../OSPSuite.ReportingFramework", quiet = TRUE)

reportFolder <- file.path(
    "tests",
    "Reports",
    "UC-03-Scenario-Results-RoundTrip"
)
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

wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
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
    scenario_name = c("UC03_ScenarioA", "UC03_ScenarioB"),
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

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)

assertOrStop(
    length(scenarioList) == 2,
    "UC-03 requires two scenarios for reload/rerun checks"
)

runAndSaveScenarios(pc, scenarioList)

resultsFolder <- file.path(pc$outputFolder, EXPORTDIR$simulationResult)
resultFiles <- file.path(resultsFolder, paste0(scenarioNames, ".csv"))

assertOrStop(
    all(file.exists(resultFiles)),
    "runAndSaveScenarios() did not create one CSV file per scenario"
)

loadedResults <- loadScenarioResultsToFramework(pc, scenarioNames)
assertOrStop(
    identical(sort(names(loadedResults)), sort(scenarioNames)),
    "loadScenarioResultsToFramework() did not return results for all scenarios"
)

scenarioToDelete <- scenarioNames[[1]]
retainedScenarios <- setdiff(scenarioNames, scenarioToDelete)
retainedFiles <- file.path(resultsFolder, paste0(retainedScenarios, ".csv"))

forcedOldTime <- Sys.time() - 120
for (retainedFile in retainedFiles) {
    Sys.setFileTime(retainedFile, forcedOldTime)
}

deletedFile <- file.path(resultsFolder, paste0(scenarioToDelete, ".csv"))
unlink(deletedFile)
assertOrStop(
    !file.exists(deletedFile),
    "Failed to delete scenario CSV before runOrLoadScenarios()"
)

reloadedOrRerunResults <- runOrLoadScenarios(pc, scenarioList)
assertOrStop(
    identical(sort(names(reloadedOrRerunResults)), sort(scenarioNames)),
    "runOrLoadScenarios() did not return results for all requested scenarios"
)
assertOrStop(
    all(file.exists(resultFiles)),
    "runOrLoadScenarios() did not recreate missing scenario CSV"
)

rerunTimestamp <- file.info(deletedFile)$mtime
retainedTimestamps <- file.info(retainedFiles)$mtime

assertOrStop(
    all(rerunTimestamp > retainedTimestamps),
    "Recomputed scenario CSV timestamp is not later than retained scenario CSV files"
)

reportLines <- c(
    "# UC-03 Simulate, save and reload scenario results",
    "",
    "## Summary",
    "",
    "This scenario validates run/save, load, and run-or-load behavior for simulation result CSV files.",
    "",
    "## Assertions",
    "",
    paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
    "- runAndSaveScenarios created one CSV file per scenario.",
    "- loadScenarioResultsToFramework returned results for all scenario names.",
    paste0(
        "- Deleted scenario CSV before runOrLoadScenarios: ",
        scenarioToDelete
    ),
    "- runOrLoadScenarios returned results for all scenarios and recreated the missing CSV.",
    "- Recomputed CSV has a newer timestamp than retained CSV files.",
    "",
    "## Result CSV files",
    ""
)

for (resultFile in sort(basename(resultFiles))) {
    reportLines <- c(reportLines, paste0("- ", resultFile))
}

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
