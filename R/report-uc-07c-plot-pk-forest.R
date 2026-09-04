#' @title report-uc-07c-plot-pk-forest
#' @description
#' Integration scenario for UC-07C PK forest plot generation.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportFolder <- file.path("tests", "Reports", "UC-07C-Plot-PKForest")
projectDir <- tempfile(pattern = "uc07c_pkforest_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

pc <- setupProject(projectDir)
pkParameterFile <- file.path(dirname(pc$scenariosFile), "PKParameter.xlsx")
wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
scenariosConfig <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
scenarioOutputs <- xlsxReadData(wbScenarios, sheetName = "OutputPaths")

modelFile <- "Aciclovir.pkml"
copyModelFile(pc, modelFile)

defaultIndividualId <- as.character(scenariosConfig$individualId[[1]])
defaultOutputPathId <- as.character(scenarioOutputs$outputPathId[[1]])

scenarioSetup <- makeDefaultScenarioTable(
    c("UC07C_ScenarioA", "UC07C_ScenarioB"),
    defaultIndividualId,
    defaultOutputPathId,
    modelFile
)

pkScenarioSetup <- data.table::data.table(
    scenario_name = c("UC07C_ScenarioA", "UC07C_ScenarioB"),
    pKParameter = c("PK_Plasma", "PK_Plasma")
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
xlsxWriteData(wbScenarios, sheetName = "PKParameter", pkScenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

setupPKPlasmaSheet(pkParameterFile, defaultOutputPathId)

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

configureOutputsSheet(pc)

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
