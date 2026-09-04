#' @title report-uc-02-scenario-creation
#' @description
#' Integration scenario for UC-02 scenario creation with a real pkml model.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportFolder <- file.path("tests", "Reports", "UC-02-Scenario-Creation")
projectDir <- tempfile(pattern = "uc02_")
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
    c("UC02_ScenarioA", "UC02_ScenarioB"),
    defaultIndividualId,
    defaultOutputPathId,
    modelFile
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
scenariosConfig <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
modelFiles <- sort(unique(as.character(scenariosConfig$modelFile)))

scenarioListAll <- createScenariosWrapped(pc, scenarioNames = NULL)
allScenarioNames <- names(scenarioListAll)

assertOrStop(
    length(scenarioListAll) >= 2,
    "UC-02 requires at least two scenarios"
)
assertOrStop(
    all(
        sort(allScenarioNames) ==
            sort(unique(as.character(scenariosConfig$scenario_name)))
    ),
    "Returned scenario names do not match Scenarios.xlsx"
)

singleScenarioName <- allScenarioNames[[1]]
scenarioListSingle <- createScenariosWrapped(
    pc,
    scenarioNames = singleScenarioName
)

assertOrStop(
    length(scenarioListSingle) == 1,
    "Filtering by scenario name did not return exactly one scenario"
)
assertOrStop(
    identical(names(scenarioListSingle), singleScenarioName),
    "Filtered scenario name does not match requested scenario"
)

wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)
reportsScenarios <- xlsxReadData(wbReports, sheetName = "Scenarios")
reportsOutputs <- xlsxReadData(wbReports, sheetName = "Outputs")
scenarioOutputs <- xlsxReadData(wbScenarios, sheetName = "OutputPaths")

assertOrStop(
    all(allScenarioNames %in% reportsScenarios$scenario),
    "Reports.xlsx Scenarios sheet does not contain all created scenarios"
)
assertOrStop(
    all(scenarioOutputs$outputPathId %in% reportsOutputs$outputPathId),
    "Reports.xlsx Outputs sheet is not synchronized with Scenarios.xlsx OutputPaths"
)

reportLines <- c(
    "# UC-02 Scenario creation with a real pkml model",
    "",
    "## Summary",
    "",
    "This scenario validates scenario creation for all and filtered scenario names using real pkml model files.",
    "",
    "## Assertions",
    "",
    paste0("- Model files found: ", paste(modelFiles, collapse = ", ")),
    paste0(
        "- Created scenarios (all): ",
        paste(allScenarioNames, collapse = ", ")
    ),
    paste0(
        "- Created scenarios (filtered): ",
        paste(names(scenarioListSingle), collapse = ", ")
    ),
    "- Reports.xlsx Scenarios sheet contains all scenario names.",
    "- Reports.xlsx Outputs sheet contains all OutputPathIds from Scenarios.xlsx.",
    "",
    "## OutputPathIds synchronized",
    ""
)

for (outputPathId in sort(unique(as.character(scenarioOutputs$outputPathId)))) {
    reportLines <- c(reportLines, paste0("- ", outputPathId))
}

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
