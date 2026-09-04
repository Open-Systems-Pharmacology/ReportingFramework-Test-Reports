#' @title report-uc-07d-plot-demographics
#' @description
#' Integration scenario for UC-07D demographic plot generation.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportFolder <- file.path("tests", "Reports", "UC-07D-Plot-Demographics")
projectDir <- tempfile(pattern = "uc07d_demography_")
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

# Export default configured population(s) and use those IDs in the scenario sheet.
exportRandomPopulations(projectConfiguration = pc, overwrite = TRUE)

populationFiles <- list.files(
    path = pc$populationsFolder,
    pattern = "\\.csv$",
    full.names = FALSE
)
assertOrStop(
    length(populationFiles) > 0,
    "No random population CSV files were created"
)
populationName <- fs::path_ext_remove(populationFiles[[1]])

defaultOutputPathId <- as.character(scenarioOutputs$outputPathId[[1]])
defaultOutputPathId <- ifelse(
    is.na(defaultOutputPathId),
    "",
    defaultOutputPathId
)

scenarioSetup <- data.table::data.table(
    scenario_name = "UC07D_ScenarioA",
    individualId = NA_character_,
    populationId = populationName,
    readPopulationFromCSV = TRUE,
    modelParameterSheets = NA_character_,
    applicationProtocol = NA_character_,
    simulationTime = "0, 24, 60",
    simulationTimeUnit = "h",
    steadyState = NA,
    steadyStateTime = NA,
    steadyStateTimeUnit = NA_character_,
    modelFile = modelFile,
    outputPathsIds = defaultOutputPathId
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)

pkScenarioSetup <- data.table::data.table(
    scenario_name = "UC07D_ScenarioA",
    pKParameter = "PK_Plasma"
)
xlsxWriteData(wbScenarios, sheetName = "PKParameter", pkScenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

setupPKPlasmaSheet(pkParameterFile, defaultOutputPathId)

scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
assertOrStop(
    length(scenarioList) == 1,
    "UC-07D requires one population scenario"
)

scenarioResults <- runAndSaveScenarios(pc, scenarioList)
calculatePKParameterForScenarios(pc, scenarioResults)
pkParameterDT <- loadPKParameter(pc, scenarioList)
.validatePKParameterDT(pkParameterDT)

setWorkflowOptions(isValidRun = FALSE)

configureOutputsSheet(pc)

addDefaultConfigForHistograms(
    projectConfiguration = pc,
    pkParameterDT = pkParameterDT,
    sheetName = "UC07D_Histograms",
    overwrite = TRUE
)

addDefaultConfigForDistributionsVsDemographics(
    projectConfiguration = pc,
    pkParameterDT = pkParameterDT,
    sheetName = "UC07D_DistVsDemo",
    overwrite = TRUE
)

wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)

histConfig <- xlsxReadData(
    wbReports,
    sheetName = "UC07D_Histograms",
    skipDescriptionRow = TRUE
)
if ("colorLegend" %in% names(histConfig)) {
    missingLegend <- is.na(histConfig$colorLegend) |
        trimws(as.character(histConfig$colorLegend)) == ""
    histConfig$colorLegend[missingLegend] <- "Scenario"
}
xlsxWriteData(wbReports, sheetName = "UC07D_Histograms", histConfig)
histConfig <- histConfig[!is.na(plotName), ]
assertOrStop(nrow(histConfig) > 0, "No runnable rows in UC07D_Histograms")
histConfigPk <- histConfig[grepl("^pkparameter", plotName), ]
assertOrStop(nrow(histConfigPk) > 0, "No PK-parameter rows in UC07D_Histograms")
histPlotName <- as.character(histConfigPk$plotName[[1]])

rangeConfig <- xlsxReadData(
    wbReports,
    sheetName = "UC07D_DistVsDemo",
    skipDescriptionRow = TRUE
)
if ("colorLegend" %in% names(rangeConfig)) {
    missingLegend <- is.na(rangeConfig$colorLegend) |
        trimws(as.character(rangeConfig$colorLegend)) == ""
    rangeConfig$colorLegend[missingLegend] <- "Scenario"
}
xlsxWriteData(wbReports, sheetName = "UC07D_DistVsDemo", rangeConfig)
openxlsx::saveWorkbook(wbReports, pc$addOns$reportsFile, overwrite = TRUE)
rangeConfig <- rangeConfig[!is.na(plotName), ]
assertOrStop(
    nrow(rangeConfig) > 0,
    "No runnable rows in UC07D_DistVsDemo"
)
rangeConfigPk <- rangeConfig[grepl("^pkparameter", plotName), ]
assertOrStop(
    nrow(rangeConfigPk) > 0,
    "No PK-parameter rows in UC07D_DistVsDemo"
)
rangePlotName <- as.character(rangeConfigPk$plotName[[1]])

histCall <- tryCatch(
    {
        runPlot(
            projectConfiguration = pc,
            nameOfplotFunction = "plotHistograms",
            configTableSheet = "UC07D_Histograms",
            rmdName = "UC07D_Histograms",
            plotNames = histPlotName,
            inputs = list(
                scenarioList = scenarioList,
                pkParameterDT = pkParameterDT
            )
        )
    },
    error = function(e) {
        e
    }
)

assertOrStop(
    !inherits(histCall, "error"),
    paste0("runPlot(plotHistograms) failed: ", histCall$message)
)

rangeCall <- tryCatch(
    {
        runPlot(
            projectConfiguration = pc,
            nameOfplotFunction = "plotDistributionVsDemographics",
            configTableSheet = "UC07D_DistVsDemo",
            rmdName = "UC07D_DistVsDemo",
            plotNames = rangePlotName,
            inputs = list(
                scenarioList = scenarioList,
                pkParameterDT = pkParameterDT,
                aggregationFlag = "GeometricStdDev"
            )
        )
    },
    error = function(e) {
        e
    }
)

assertOrStop(
    !inherits(rangeCall, "error"),
    paste0(
        "runPlot(plotDistributionVsDemographics) failed: ",
        rangeCall$message
    )
)

histReturned <- if (inherits(histCall, "error")) 0 else length(histCall)
rangeReturned <- if (inherits(rangeCall, "error")) 0 else length(rangeCall)

reportLines <- c(
    "# UC-07D Plot generation: Demographics",
    "",
    "## Summary",
    "",
    "This scenario validates runPlot execution for demographic plot generation.",
    "",
    "## Assertions",
    "",
    paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
    paste0("- Exported population: ", populationName),
    paste0(
        "- PK parameters available: ",
        paste(unique(pkParameterDT$pkParameter), collapse = ", ")
    ),
    "- UC07D_Histograms contains at least one runnable row.",
    paste0("- Selected histogram plotName: ", histPlotName),
    "- runPlot(nameOfplotFunction = 'plotHistograms') completed without error.",
    paste0("- Returned histogram plot/table objects: ", histReturned),
    "- UC07D_DistVsDemo contains at least one runnable row.",
    paste0("- Selected distribution-vs-demographics plotName: ", rangePlotName),
    "- runPlot(nameOfplotFunction = 'plotDistributionVsDemographics') completed without error.",
    paste0(
        "- Returned distribution-vs-demographics plot/table objects: ",
        rangeReturned
    )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
