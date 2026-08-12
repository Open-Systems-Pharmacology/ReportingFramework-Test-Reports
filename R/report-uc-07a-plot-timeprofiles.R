#' @title report-uc-07a-plot-timeprofiles
#' @description
#' Integration scenario for UC-07A time profile plot generation.

rm(list = ls())
pkgload::load_all("../OSPSuite.ReportingFramework", quiet = TRUE)
set.seed(1)

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

createObservedData <- function(outputPathIds) {
    groups <- c(
        "Set1-A",
        "Set1-B",
        "Set1_Reference-A",
        "Set1_Reference-B",
        "Set2_OD-A",
        "Set2_OD-B"
    )
    subjectByGroup <- list(
        "Set1-A" = c(1001L, 1002L),
        "Set1-B" = c(1003L, 1004L),
        "Set1_Reference-A" = c(2001L, 2002L),
        "Set1_Reference-B" = c(2003L, 2004L),
        "Set2_OD-A" = c(3001L, 3002L),
        "Set2_OD-B" = c(3003L, 3004L)
    )
    times <- c(0, 0.25, 0.5, 1, 2, 6, 12, 24)

    dtObserved <- data.table::rbindlist(lapply(
        seq_along(groups),
        function(gIdx) {
            groupName <- groups[[gIdx]]
            subjects <- subjectByGroup[[groupName]]
            data.table::rbindlist(lapply(seq_along(subjects), function(sIdx) {
                subject <- subjects[[sIdx]]
                data.table::rbindlist(lapply(
                    seq_along(outputPathIds),
                    function(oIdx) {
                        outputId <- outputPathIds[[oIdx]]
                        yValues <- (80 - 2 * gIdx - sIdx) *
                            exp(-0.2 * times) +
                            oIdx
                        data.table::data.table(
                            studyId = "1234",
                            subjectId = as.character(subject),
                            individualId = as.character(subject),
                            group = groupName,
                            outputPathId = outputId,
                            xValues = times,
                            xUnit = "h",
                            yValues = yValues,
                            yUnit = "mol/l",
                            lloq = 0.1,
                            dataType = "observed",
                            dataClass = DATACLASS$tpIndividual
                        )
                    }
                ))
            }))
        }
    ))

    identifierCols <- c(
        "studyId",
        "subjectId",
        "individualId",
        "group",
        "outputPathId",
        "dataType",
        "dataClass"
    )
    timeprofileCols <- c("xValues", "xUnit", "yValues", "yUnit", "lloq")

    for (col in intersect(identifierCols, names(dtObserved))) {
        data.table::setattr(dtObserved[[col]], "columnType", "identifier")
    }
    for (col in intersect(timeprofileCols, names(dtObserved))) {
        data.table::setattr(dtObserved[[col]], "columnType", "timeprofile")
    }

    dtObserved
}

makeConfigRow <- function(
    baseRow,
    plotName,
    scenario,
    outputPathIds,
    dataGroupIds = NA_character_,
    referenceScenario = NA_character_,
    timeOffset = 0,
    timeOffsetReference = 0,
    facetScale = "fixed",
    nFacetColumns = 1,
    ylimitLinear = NA_character_,
    ylimitLog = NA_character_,
    timeRangeTotal = "total",
    timeRangeFirst = NA_character_,
    timeRangeLast = NA_character_,
    withDiagnostics = FALSE,
    splitPerTimeRange = TRUE
) {
    row <- data.table::copy(baseRow)
    row$plotName <- plotName
    row$scenario <- scenario
    row$outputPathIds <- outputPathIds
    row$dataGroupIds <- dataGroupIds
    row$referenceScenario <- referenceScenario
    row$timeOffset <- timeOffset
    row$timeOffset_Reference <- timeOffsetReference
    row$facetScale <- facetScale
    row$nFacetColumns <- nFacetColumns
    row$yScale <- "linear, log"
    row$ylimit_linear <- ylimitLinear
    row$ylimit_log <- ylimitLog
    row$timeRange_total <- timeRangeTotal
    row$timeRange_firstApplication <- timeRangeFirst
    row$timeRange_lastApplication <- timeRangeLast
    row$splitPlotsPerTimeRange <- as.numeric(splitPerTimeRange)
    row$plot_TimeProfiles <- 1
    row$plot_PredictedVsObserved <- as.numeric(withDiagnostics)
    row$plot_ResidualsAsHistogram <- as.numeric(withDiagnostics)
    row$plot_ResidualsVsTime <- as.numeric(withDiagnostics)
    row$plot_ResidualsVsObserved <- as.numeric(withDiagnostics)
    row$plot_QQ <- as.numeric(withDiagnostics)

    if (!is.na(referenceScenario)) {
        row$colorLegend <- "Simulation, Reference"
    } else {
        row$colorLegend <- NA_character_
    }

    row
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
availableOutputPathIds <- as.character(scenarioOutputs$outputPathId)
availableOutputPathIds <- unique(availableOutputPathIds[
    !is.na(availableOutputPathIds)
])
assertOrStop(
    length(availableOutputPathIds) >= 2,
    "UC-07A requires at least two output paths"
)

primaryOutputPathId <- availableOutputPathIds[[1]]
secondaryOutputPathId <- availableOutputPathIds[[2]]

scenarioSetup <- data.table::data.table(
    scenario_name = c("Set1", "Set1_Reference", "Set2_OD"),
    individualId = c(
        defaultIndividualId,
        defaultIndividualId,
        defaultIndividualId
    ),
    populationId = c(NA_character_, NA_character_, NA_character_),
    readPopulationFromCSV = c(NA, NA, NA),
    modelParameterSheets = c(NA_character_, NA_character_, NA_character_),
    applicationProtocol = c(NA_character_, NA_character_, NA_character_),
    simulationTime = c("0, 24, 60", "0, 24, 60", "0, 24, 240"),
    simulationTimeUnit = c("h", "h", "h"),
    steadyState = c(NA, NA, NA),
    steadyStateTime = c(NA, NA, NA),
    steadyStateTimeUnit = c(NA_character_, NA_character_, NA_character_),
    modelFile = c(modelFile, modelFile, modelFile),
    outputPathsIds = c(
        paste(primaryOutputPathId, secondaryOutputPathId, sep = ", "),
        paste(primaryOutputPathId, secondaryOutputPathId, sep = ", "),
        paste(primaryOutputPathId, secondaryOutputPathId, sep = ", ")
    )
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
openxlsx::saveWorkbook(wbScenarios, scenariosFile, overwrite = TRUE)

scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
assertOrStop(length(scenarioList) == 3, "UC-07A requires three scenarios")

scenarioResults <- runAndSaveScenarios(pc, scenarioList)
scenarioResultsForPlots <- loadScenarioResultsToFramework(pc, scenarioNames)

dataObserved <- createObservedData(
    outputPathIds = c(primaryOutputPathId, secondaryOutputPathId)
)
validateObservedData(dataObserved, dataClassType = "timeprofile")
updateDataGroupId(projectConfiguration = pc, dataDT = dataObserved)

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
    dataObserved = dataObserved,
    sheetName = "UC07A_TimeProfiles",
    overwrite = TRUE
)

wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)
dtConfigRaw <- xlsxReadData(
    wbReports,
    sheetName = "UC07A_TimeProfiles",
    skipDescriptionRow = TRUE
)

headerRows <- dtConfigRaw[!is.na(level), ]
plotRows <- dtConfigRaw[is.na(level), ]
assertOrStop(nrow(plotRows) > 0, "No runnable rows in UC07A_TimeProfiles")
baseRow <- plotRows[1]

representativeRows <- data.table::rbindlist(
    list(
        makeConfigRow(
            baseRow = baseRow,
            plotName = "singlePlot_withoutData",
            scenario = "Set1",
            outputPathIds = primaryOutputPathId,
            dataGroupIds = NA_character_
        ),
        makeConfigRow(
            baseRow = baseRow,
            plotName = "singlePlot_withData",
            scenario = "Set1",
            outputPathIds = primaryOutputPathId,
            dataGroupIds = "Set1-A, Set1-B",
            withDiagnostics = TRUE
        ),
        makeConfigRow(
            baseRow = baseRow,
            plotName = "singlePlot_withReference",
            scenario = "Set1",
            outputPathIds = primaryOutputPathId,
            referenceScenario = "Set1_Reference"
        ),
        makeConfigRow(
            baseRow = baseRow,
            plotName = "singlePlot_withOffset",
            scenario = "Set1",
            outputPathIds = primaryOutputPathId,
            referenceScenario = "Set1_Reference",
            timeOffset = -5,
            timeOffsetReference = -10
        ),
        makeConfigRow(
            baseRow = baseRow,
            plotName = "singlePlot_withLimits",
            scenario = "Set1",
            outputPathIds = primaryOutputPathId,
            ylimitLinear = "c(0, 10000)",
            ylimitLog = "c(0.01, 10000)"
        ),
        makeConfigRow(
            baseRow = baseRow,
            plotName = "multiDosePlot",
            scenario = "Set2_OD",
            outputPathIds = primaryOutputPathId,
            dataGroupIds = "Set2_OD-A, Set2_OD-B",
            timeRangeFirst = "c(0, 24)",
            timeRangeLast = "c(12, 24)",
            splitPerTimeRange = TRUE
        ),
        makeConfigRow(
            baseRow = baseRow,
            plotName = "manyPanelPlot",
            scenario = "Set1",
            outputPathIds = paste(
                primaryOutputPathId,
                secondaryOutputPathId,
                sep = ", "
            ),
            dataGroupIds = "Set1-A, Set1-B",
            referenceScenario = "Set1_Reference",
            facetScale = "fixed",
            nFacetColumns = 2
        ),
        makeConfigRow(
            baseRow = baseRow,
            plotName = "manyPanelPlot_col3",
            scenario = "Set1",
            outputPathIds = paste(
                primaryOutputPathId,
                secondaryOutputPathId,
                sep = ", "
            ),
            dataGroupIds = "Set1-A, Set1-B",
            referenceScenario = "Set1_Reference",
            facetScale = "free",
            nFacetColumns = 3
        )
    ),
    fill = TRUE
)

updatedConfig <- data.table::rbindlist(
    list(headerRows, representativeRows),
    fill = TRUE
)
xlsxWriteData(wbReports, sheetName = "UC07A_TimeProfiles", updatedConfig)
openxlsx::saveWorkbook(wbReports, pc$addOns$reportsFile, overwrite = TRUE)

familyCoverage <- data.table::data.table(
    family = c(
        "single-without-data",
        "single-with-data",
        "single-with-reference",
        "single-with-offset",
        "single-with-limits",
        "multidose-time-ranges",
        "many-panel-fixed",
        "many-panel-free-col3"
    ),
    plotName = as.character(representativeRows$plotName),
    status = "PASS",
    returnedObjects = 0L,
    errorMessage = ""
)

for (i in seq_len(nrow(familyCoverage))) {
    plotName <- familyCoverage$plotName[[i]]
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
                    dataObserved = dataObserved
                )
            )
        },
        error = function(e) {
            e
        }
    )

    if (inherits(tpCall, "error")) {
        familyCoverage$status[[i]] <- "FAIL"
        familyCoverage$errorMessage[[i]] <- tpCall$message
    } else {
        familyCoverage$returnedObjects[[i]] <- length(tpCall)
    }
}

assertOrStop(
    !any(familyCoverage$status == "FAIL"),
    paste0(
        "UC-07A family failures: ",
        paste(
            familyCoverage$family[familyCoverage$status == "FAIL"],
            collapse = ", "
        )
    )
)

csvSourcePath <- "H:/VP_auxiliary_functions/plotTimeProfile/tests/testthat/testdata/config_timeprofiles.csv"
reportTable <- c(
    "| Family | Representative Plot Name | Status | Returned Objects |",
    "|---|---|---|---:|"
)

for (i in seq_len(nrow(familyCoverage))) {
    reportTable <- c(
        reportTable,
        paste0(
            "| ",
            familyCoverage$family[[i]],
            " | ",
            familyCoverage$plotName[[i]],
            " | ",
            familyCoverage$status[[i]],
            " | ",
            familyCoverage$returnedObjects[[i]],
            " |"
        )
    )
}

reportLines <- c(
    "# UC-07A Plot generation: Time Profiles",
    "",
    "## Summary",
    "",
    "This scenario validates representative time-profile variant families derived from external config_timeprofiles.csv.",
    paste0("Source variants: ", csvSourcePath),
    "",
    "## Assertions",
    "",
    paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
    "- UC07A_TimeProfiles contains one representative row for each variant family.",
    "- All family-specific runPlot(nameOfplotFunction = 'plotTimeProfiles') calls completed without hard errors.",
    "",
    "## Family Coverage",
    "",
    reportTable
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
