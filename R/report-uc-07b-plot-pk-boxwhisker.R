#' @title report-uc-07b-plot-pk-boxwhisker
#' @description
#' Integration scenario for UC-07B PK box-whisker plot generation.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportFolder <- file.path("tests", "Reports", "UC-07B-Plot-PKBoxwhisker")
projectDir <- tempfile(pattern = "uc07b_pkbox_")
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
    c("UC07B_ScenarioA", "UC07B_ScenarioB"),
    defaultIndividualId,
    defaultOutputPathId,
    modelFile
)

pkScenarioSetup <- data.table::data.table(
    scenario_name = c("UC07B_ScenarioA", "UC07B_ScenarioB"),
    pKParameter = c("PK_Plasma", "PK_Plasma")
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
xlsxWriteData(wbScenarios, sheetName = "PKParameter", pkScenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

setupPKPlasmaSheet(pkParameterFile, defaultOutputPathId)

scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
assertOrStop(length(scenarioList) == 2, "UC-07B requires two scenarios")

scenarioResults <- runAndSaveScenarios(pc, scenarioList)
calculatePKParameterForScenarios(pc, scenarioResults)
pkParameterDT <- loadPKParameter(pc, scenarioList)
.validatePKParameterDT(pkParameterDT)

setWorkflowOptions(isValidRun = FALSE)

configureOutputsSheet(pc)

addDefaultConfigForPKBoxwhsikerPlots(
    projectConfiguration = pc,
    pkParameterDT = pkParameterDT,
    sheetName = "UC07B_PK_Boxplot",
    overwrite = TRUE
)

wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)
dtConfig <- xlsxReadData(
    wbReports,
    sheetName = "UC07B_PK_Boxplot",
    skipDescriptionRow = TRUE
)
dtConfig <- dtConfig[!is.na(plotName), ]
assertOrStop(nrow(dtConfig) > 0, "No runnable rows in UC07B_PK_Boxplot")
plotName <- as.character(dtConfig$plotName[[1]])

pkBoxCall <- tryCatch(
    {
        runPlot(
            projectConfiguration = pc,
            nameOfplotFunction = "plotPKBoxwhisker",
            configTableSheet = "UC07B_PK_Boxplot",
            rmdName = "UC07B_PK_Boxplot",
            plotNames = plotName,
            inputs = list(pkParameterDT = pkParameterDT)
        )
    },
    error = function(e) {
        e
    }
)

assertOrStop(
    !inherits(pkBoxCall, "error"),
    paste0("runPlot(plotPKBoxwhisker) failed: ", pkBoxCall$message)
)
returnedPlots <- if (inherits(pkBoxCall, "error")) 0 else length(pkBoxCall)

reportLines <- c(
    "# UC-07B Plot generation: PK Box-Whisker",
    "",
    "## Summary",
    "",
    "This scenario validates runPlot execution for PK box-whisker plot generation.",
    "",
    "## Assertions",
    "",
    paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
    "- UC07B_PK_Boxplot contains at least one runnable row.",
    paste0("- Selected plotName: ", plotName),
    "- runPlot(nameOfplotFunction = 'plotPKBoxwhisker') completed without error.",
    paste0("- Returned plot/table objects: ", returnedPlots)
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
