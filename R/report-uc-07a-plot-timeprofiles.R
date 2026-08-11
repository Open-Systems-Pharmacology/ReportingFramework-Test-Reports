#' @title report-uc-07a-plot-timeprofiles
#' @description
#' Integration scenario for UC-07A time profile plot generation.

rm(list = ls())
pkgload::load_all("../OSPSuite.ReportingFramework", quiet = TRUE)

reportFolder <- file.path("tests", "Reports", "UC-07A-Plot-TimeProfiles")
projectDir <- tempfile(pattern = "uc07a_timeprofiles_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

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
wbScenarios <- openxlsx::loadWorkbook(scenariosFile)
scenariosConfig <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
scenarioOutputs <- xlsxReadData(wbScenarios, sheetName = "OutputPaths")

modelFile <- "Aciclovir.pkml"
sourceModelPath <- file.path("Models", modelFile)
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
    scenario_name = c("UC07A_ScenarioA", "UC07A_ScenarioB"),
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
openxlsx::saveWorkbook(wbScenarios, scenariosFile, overwrite = TRUE)

scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
assertOrStop(length(scenarioList) == 2, "UC-07A requires two scenarios")

scenarioResults <- runAndSaveScenarios(pc, scenarioList)
scenarioResultsForPlots <- loadScenarioResultsToFramework(pc, scenarioNames)

setWorkflowOptions(isValidRun = FALSE)

wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)
outputsSheet <- xlsxReadData(
    wbReports,
    sheetName = "Outputs",
    skipDescriptionRow = TRUE
)
missingDisplayNames <- is.na(outputsSheet$displayName) |
    trimws(as.character(outputsSheet$displayName)) == ""
outputsSheet$displayName[
    missingDisplayNames
] <- as.character(outputsSheet$outputPathId[missingDisplayNames])
missingDisplayUnits <- is.na(outputsSheet$displayUnit) |
    trimws(as.character(outputsSheet$displayUnit)) == ""
outputsSheet$displayUnit[missingDisplayUnits] <- "mol/l"
xlsxWriteData(wbReports, sheetName = "Outputs", outputsSheet)
openxlsx::saveWorkbook(wbReports, pc$addOns$reportsFile, overwrite = TRUE)

addDefaultConfigForTimeProfilePlots(
    projectConfiguration = pc,
    dataObserved = NULL,
    sheetName = "UC07A_TimeProfiles",
    overwrite = TRUE
)

wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)
dtConfig <- xlsxReadData(
    wbReports,
    sheetName = "UC07A_TimeProfiles",
    skipDescriptionRow = TRUE
)
dtConfig <- dtConfig[!is.na(plotName), ]
assertOrStop(nrow(dtConfig) > 0, "No runnable rows in UC07A_TimeProfiles")
plotName <- as.character(dtConfig$plotName[[1]])

tpCall <- tryCatch(
    {
        runPlot(
            projectConfiguration = pc,
            nameOfplotFunction = "plotTimeProfiles",
            configTableSheet = "UC07A_TimeProfiles",
            rmdName = "UC07A_TimeProfiles",
            plotNames = plotName,
            inputs = list(
                scenarioResults = scenarioResultsForPlots,
                dataObserved = NULL
            )
        )
    },
    error = function(e) {
        e
    }
)

assertOrStop(
    !inherits(tpCall, "error"),
    paste0("runPlot(plotTimeProfiles) failed: ", tpCall$message)
)
returnedPlots <- if (inherits(tpCall, "error")) 0 else length(tpCall)

reportLines <- c(
    "# UC-07A Plot generation: Time Profiles",
    "",
    "## Summary",
    "",
    "This scenario validates runPlot execution for time profile plot generation.",
    "",
    "## Assertions",
    "",
    paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
    "- UC07A_TimeProfiles contains at least one runnable row.",
    paste0("- Selected plotName: ", plotName),
    "- runPlot(nameOfplotFunction = 'plotTimeProfiles') completed without error.",
    paste0("- Returned plot/table objects: ", returnedPlots)
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
