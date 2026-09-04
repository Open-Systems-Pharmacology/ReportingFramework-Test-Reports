#' @title report-uc-03-scenario-results-roundtrip
#' @description
#' Integration scenario for UC-03 simulate, save and reload scenario results.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportFolder <- file.path(
    "tests",
    "Reports",
    "UC-03-Scenario-Results-RoundTrip"
)
projectDir <- tempfile(pattern = "uc03_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

pc <- setupProject(projectDir)

wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
scenariosConfig <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
scenarioOutputs <- xlsxReadData(wbScenarios, sheetName = "OutputPaths")

modelFile <- "Aciclovir.pkml"
copyModelFile(pc, modelFile)

defaultIndividualId <- as.character(scenariosConfig$individualId[[1]])
defaultOutputPathId <- as.character(scenarioOutputs$outputPathId[[1]])

scenarioSetup <- makeDefaultScenarioTable(
    c("UC03_ScenarioA", "UC03_ScenarioB"),
    defaultIndividualId,
    defaultOutputPathId,
    modelFile
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
