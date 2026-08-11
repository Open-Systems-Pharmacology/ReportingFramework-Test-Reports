#' @title report-uc-07c-plot-pk-forest
#' @description
#' Integration scenario for UC-07C PK forest plot generation.

rm(list = ls())
pkgload::load_all("../OSPSuite.ReportingFramework", quiet = TRUE)

reportFolder <- file.path("tests", "Reports", "UC-07C-Plot-PKForest")
projectDir <- tempfile(pattern = "uc07c_pkforest_")
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
pkParameterFile <- file.path(configurationDir, "PKParameter.xlsx")
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
    scenario_name = c("UC07C_ScenarioA", "UC07C_ScenarioB"),
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
    scenario_name = c("UC07C_ScenarioA", "UC07C_ScenarioB"),
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
if ("PK_Plasma" %in% openxlsx::getSheetNames(pkParameterFile)) {
    openxlsx::removeWorksheet(wbPk, "PK_Plasma")
}
openxlsx::addWorksheet(wbPk, "PK_Plasma")
openxlsx::writeData(wbPk, sheet = "PK_Plasma", x = pkSheetData)
openxlsx::saveWorkbook(wbPk, pkParameterFile, overwrite = TRUE)

scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
assertOrStop(length(scenarioList) == 2, "UC-07C requires two scenarios")

scenarioResults <- runAndSaveScenarios(pc, scenarioList)
calculatePKParameterForScenarios(pc, scenarioResults)
pkParameterDT <- loadPKParameter(pc, scenarioList)
.validatePKParameterDT(pkParameterDT)

setWorkflowOptions(isValidRun = FALSE)

# Compatibility alias for wrappers still calling validatePKParameterDT.
validatePKParameterDT <- .validatePKParameterDT

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

addDefaultConfigForPKForestPlots(
    projectConfiguration = pc,
    pkParameterDT = pkParameterDT,
    sheetName = "UC07C_PK_Forest",
    overwrite = TRUE
)

wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)
dtConfig <- xlsxReadData(
    wbReports,
    sheetName = "UC07C_PK_Forest",
    skipDescriptionRow = TRUE
)
dtConfig <- dtConfig[!is.na(plotName), ]
assertOrStop(nrow(dtConfig) > 0, "No runnable rows in UC07C_PK_Forest")
plotName <- as.character(dtConfig$plotName[[1]])

pkForestCall <- tryCatch(
    {
        runPlot(
            projectConfiguration = pc,
            nameOfplotFunction = "plotPKForestAggregatedAbsoluteValues",
            configTableSheet = "UC07C_PK_Forest",
            rmdName = "UC07C_PK_Forest",
            plotNames = plotName,
            inputs = list(pkParameterDT = pkParameterDT)
        )
    },
    error = function(e) {
        e
    }
)

assertOrStop(
    !inherits(pkForestCall, "error"),
    paste0(
        "runPlot(plotPKForestAggregatedAbsoluteValues) failed: ",
        pkForestCall$message
    )
)
returnedPlots <- if (inherits(pkForestCall, "error")) {
    0
} else {
    length(pkForestCall)
}

reportLines <- c(
    "# UC-07C Plot generation: PK Forest",
    "",
    "## Summary",
    "",
    "This scenario validates runPlot execution for PK forest plot generation.",
    "",
    "## Assertions",
    "",
    paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
    "- UC07C_PK_Forest contains at least one runnable row.",
    paste0("- Selected plotName: ", plotName),
    "- runPlot(nameOfplotFunction = 'plotPKForestAggregatedAbsoluteValues') completed without error.",
    paste0("- Returned plot/table objects: ", returnedPlots)
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
