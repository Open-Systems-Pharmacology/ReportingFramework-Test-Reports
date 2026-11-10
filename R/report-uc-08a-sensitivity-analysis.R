#' @title report-uc-08a-sensitivity-analysis
#' @description
#' Integration scenario for UC-08A sensitivity analysis plot generation.

rm(list = ls())
library(ospsuite.reportingframework)
library(data.table)
source("R/helpers-uc-shared.R")

# Prevent accidental creation of Rplots.pdf by using a null default device.
originalDeviceOption <- getOption("device")
options(device = function(...) grDevices::pdf(NULL))
on.exit(options(device = originalDeviceOption), add = TRUE)

reportFolder <- file.path("tests", "Reports", "UC-08A-Sensitivity-Analysis")
projectDir <- tempfile(pattern = "uc08a_sensitivity_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

scenarioName <- "meanModel_po"
referenceScenarioName <- "meanModel_iv"
plotConfigSheet <- "UC08a_SensitivityPlots"
sensitivitySheet <- "UC08"
qmdName <- "UC08A_Sensitivity"

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

# Initialize project
pc <- setupProject(projectDir)

updateUC7Project(
  pc,
  scenarioNames = c(scenarioName, referenceScenarioName),
  copyPK = FALSE,
  copySimResult = FALSE
)

# Copy model files required by the workbook-defined mean model scenarios.
copyModelFiles(pc, c("po_3_mg_solution.pkml", "iv_1_mg_5_min.pkml"))

sensitivityResultsPath <- file.path(
  pc$outputFolder,
  EXPORTDIR$sensitivityResults
)
dir.create(sensitivityResultsPath, recursive = TRUE, showWarnings = FALSE)
assertOrStop(
  dir.exists(sensitivityResultsPath),
  paste0(
    "Failed to create sensitivity results directory: ",
    sensitivityResultsPath
  )
)

# Step 1: Validate workbook-driven scenario and normalize the copied UC08 plot row.
wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
scenariosConfigSheet <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
assertOrStop(
  scenarioName %in% scenariosConfigSheet$scenario_name,
  paste0("Scenario not found in Scenarios_UC07.xlsx: ", scenarioName)
)
assertOrStop(
  referenceScenarioName %in% scenariosConfigSheet$scenario_name,
  paste0(
    "Reference scenario not found in Scenarios_UC07.xlsx: ",
    referenceScenarioName
  )
)
scenarioRow <- scenariosConfigSheet[
  scenariosConfigSheet$scenario_name == scenarioName,
]
outputPathId <- as.character(scenarioRow$outputPathsIds[[1]])
modelFile <- as.character(scenarioRow$modelFile[[1]])

wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)
assertOrStop(
  plotConfigSheet %in% openxlsx::getSheetNames(pc$addOns$reportsFile),
  paste0("Sheet not found in Reports_UC07.xlsx: ", plotConfigSheet)
)

# Create scenarios
scenarioList <- createScenariosWrapped(
  pc,
  scenarioNames = c(scenarioName, referenceScenarioName)
)
scenarioNames <- names(scenarioList)

assertOrStop(
  setequal(scenarioNames, c(scenarioName, referenceScenarioName)),
  paste0(
    "Failed to create the expected scenarios. Created: ",
    paste(scenarioNames, collapse = ", ")
  )
)

# Add sensitivity Table
addSensitivityTable(
  projectConfiguration = pc,
  scenarioList = scenarioList,
  sheetName = sensitivitySheet
)

sensitivitySheetData <- .adjustSensitivitySheetWorkbookForUC(
  sensitivityFile = pc$addOns$sensitivityFile,
  sheetName = sensitivitySheet,
  parameterPattern = "CYP3A4",
  normalizeParameterPattern = "CYP3A4 Fraction expressed intracellular",
  normalizeParameterValue = "CYP3A4 Fraction expressed intracellular"
)
dtDataAll <- sensitivitySheetData$rawDataRows
dtData <- sensitivitySheetData$adjustedDataRows

uniqueParameterPathCount <- dtDataAll[, uniqueN(parameterPath)]
uniqueParameterCountInitial <- dtDataAll[, uniqueN(parameter)]

assertOrStop(
  identical(uniqueParameterCountInitial, uniqueParameterPathCount) &
    uniqueParameterPathCount > 0,
  paste0(
    "Failed to create table with unique parameters"
  )
)

uniqueParameterNames <- sort(unique(dtData$parameter))
uniqueParameterCount <- length(uniqueParameterNames)
expectedSensitivityRows <- uniqueParameterCount * 3


runSensitivityAnalysisForScenarios(
  projectConfiguration = pc,
  scenarioList = scenarioList,
  scenarioNames = scenarioName,
  sensitivitysheet = sensitivitySheet
)

absoluteSensitivityResults <- fread(file.path(
  pc$outputFolder,
  EXPORTDIR$sensitivityResults,
  paste0(scenarioName, "_", sensitivitySheet, ".csv")
))

runSensitivityAnalysisForScenarios(
  projectConfiguration = pc,
  scenarioList = scenarioList,
  scenarioNames = scenarioName,
  sensitivitysheet = sensitivitySheet,
  referenceScenario = referenceScenarioName
)

relativeSensitivityResults <- fread(file.path(
  pc$outputFolder,
  EXPORTDIR$sensitivityResults,
  paste0(scenarioName, "_", sensitivitySheet, ".csv")
))

sensitivityDataFiles <- list.files(
  sensitivityResultsPath,
  pattern = "\\.csv$",
  full.names = TRUE
)
sensitivityDataCount <- length(sensitivityDataFiles)
uniquePkParameters <- sort(unique(relativeSensitivityResults$PKParameter))
sensitivityResultColumns <- colnames(relativeSensitivityResults)
parameterPreviewCount <- min(8, uniqueParameterCount)
parameterLabelPreview <- paste(
  utils::head(uniqueParameterNames, parameterPreviewCount),
  collapse = ", "
)
remainingParameterCount <- uniqueParameterCount - parameterPreviewCount
expectedPkParameterCount <- length(uniquePkParameters)

absoluteSensitivityRowCount <- nrow(absoluteSensitivityResults)
relativeSensitivityRowCount <- nrow(relativeSensitivityResults)


assertOrStop(
  absoluteSensitivityRowCount == expectedSensitivityRows,
  paste0(
    "Failed to create the expected number of absolute sensitivity results. Expected ",
    expectedSensitivityRows,
    " rows based on 3 PK parameters per model parameter, got ",
    absoluteSensitivityRowCount,
    "."
  )
)

assertOrStop(
  relativeSensitivityRowCount == expectedSensitivityRows,
  paste0(
    "Failed to create the expected number of relative sensitivity results. Expected ",
    expectedSensitivityRows,
    " rows based on 3 PK parameters per model parameter, got ",
    relativeSensitivityRowCount,
    "."
  )
)

# Step 2: Generate sensitivity plots from calculated sensitivity CSVs

setWorkflowOptions(isValidRun = FALSE)

themeToUse <- ospsuite.plots::theme_osp() +
  theme(legend.position = "top", legend.title = element_blank())
options(knitr.kable.NA = "")


coverage <- loadAndFilterConfigSheet(
  pc,
  sheetName = plotConfigSheet
)

coverage$status <- rep("PENDING", nrow(coverage))
coverage$errorMessage <- rep(NA_character_, nrow(coverage))
coverage$returnedObjects <- rep(NA_real_, nrow(coverage))

# Run each plotName separately to capture coverage statistics.
for (i in seq_len(nrow(coverage))) {
  plotName <- coverage$plotName[[i]]

  rangeCall <- .runStepWithResult(
    runPlot(
      projectConfiguration = pc,
      nameOfplotFunction = "plotSensitivity",
      configTableSheet = plotConfigSheet,
      qmdName = qmdName,
      plotNames = plotName,
      theme = themeToUse,
      inputs = list(
        scenarioList = scenarioList
      )
    )
  )

  if (!isTRUE(rangeCall$success)) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- rangeCall$error
    next
  }

  coverage$returnedObjects[[i]] <- length(rangeCall$result)
  if (coverage$returnedObjects[[i]] == 0) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- "runPlot returned no plot objects"
    next
  }

  coverage$status[[i]] <- "OK"
}

returnedPlots <-
  sum(as.double(unlist(coverage$returnedObjects)), na.rm = TRUE)

failedPlots <- coverage[coverage$status == "FAIL", ]
sensitivityPlotsGenerated <- nrow(failedPlots) == 0
sensitivityPlotCount <- sum(coverage$status == "OK")

if (sensitivityPlotsGenerated) {
  sensitivityPlotResult <- list(error = NA_character_)
} else {
  sensitivityPlotResult <- list(
    error = paste(
      paste0(
        failedPlots$plotName,
        ": ",
        failedPlots$errorMessage
      ),
      collapse = "; "
    )
  )
}

assertOrStop(
  sensitivityPlotsGenerated,
  paste0(
    "runPlot(plotSensitivity) failed for one or more configurations: ",
    sensitivityPlotResult$error
  )
)

setPlotExportOptions(width = 20)

# Run plot for export
runPlot(
  projectConfiguration = pc,
  nameOfplotFunction = "plotSensitivity",
  configTableSheet = plotConfigSheet,
  qmdName = qmdName,
  theme = themeToUse,
  inputs = list(
    scenarioList = scenarioList
  )
)

qmdNames <- qmdName
plotFiles <- verifyAndCopyPlots(
  reportFolder = reportFolder,
  outputsRoot = pc$outputFolder,
  qmdNames = qmdNames
)

sensitivityOutputFiles <- plotFiles
sensitivityPlotsFound <- length(sensitivityOutputFiles) > 0

qmdRenderResult <- renderQmdToMarkdown(
  searchFolder = reportFolder,
  pattern = paste0(qmdName, "\\.qmd$")
)

reportLines <- c(
  "# UC-08A Sensitivity Analysis",
  "",
  "## Summary",
  "",
  "This scenario validates both absolute and relative sensitivity analysis calculations and figure generation via plotSensitivity.",
  "",
  "## Approach",
  "",
  "- Reuses UC07 scenario and report workbooks from ReportInputs to configure sensitivity execution.",
  "- Executes absolute sensitivity for meanModel_po and then relative sensitivity against meanModel_iv.",
  "- Creates the UC08 sensitivity parameter sheet with addSensitivityTable() for the selected scenario.",
  "- Updates and normalizes sensitivity parameter definitions, including many-to-one parameter label mapping.",
  "- Uses UC08a_SensitivityPlots as the plotting configuration sheet to cover outputs from both runs.",
  "- Generates sensitivity figures with runPlot(nameOfplotFunction = 'plotSensitivity') per plotName for coverage.",
  "- Exports figures and renders UC08A_Sensitivity.qmd into markdown content with captions and references.",
  "",
  "## Assertions",
  "",
  paste0("- Scenario created: ", paste(scenarioNames, collapse = ", ")),
  paste0(
    "- Relative sensitivity denominator scenario: ",
    referenceScenarioName,
    "."
  ),
  "- Project setup workbooks copied: Scenarios_UC07.xlsx, PKParameter_UC07.xlsx, Reports_UC07.xlsx.",
  paste0(
    "- Sensitivity parameter workbook created: ",
    basename(pc$addOns$sensitivityFile),
    "."
  ),
  paste0(
    "- Sensitivity parameter sheet created via addSensitivityTable(): ",
    sensitivitySheet
  ),
  paste0("- Sensitivity workbook sheet executed: ", sensitivitySheet),
  paste0("- Plot configuration sheet executed: ", plotConfigSheet),
  paste0(
    "- Unique sensitivity parameter labels after normalization: ",
    uniqueParameterCount,
    "."
  ),
  paste0(
    "- Sensitivity parameter labels used (preview): ",
    parameterLabelPreview,
    if (remainingParameterCount > 0) {
      paste0(" (+", remainingParameterCount, " more)")
    }
  ),
  paste0(
    "- PK parameters evaluated: ",
    paste(uniquePkParameters, collapse = ", ")
  ),
  paste0(
    "- Expected absolute sensitivity rows: ",
    uniqueParameterCount,
    " labels x ",
    expectedPkParameterCount,
    " PK parameters = ",
    expectedSensitivityRows,
    "; actual rows: ",
    absoluteSensitivityRowCount,
    "."
  ),
  paste0(
    "- Expected relative sensitivity rows: ",
    uniqueParameterCount,
    " labels x ",
    expectedPkParameterCount,
    " PK parameters = ",
    expectedSensitivityRows,
    "; actual rows: ",
    relativeSensitivityRowCount,
    "."
  ),
  paste0(
    "- runSensitivityAnalysisForScenarios() executed for scenario ",
    scenarioName,
    " with sensitivity sheet ",
    sensitivitySheet,
    " (absolute run)."
  ),
  paste0(
    "- runSensitivityAnalysisForScenarios() executed for scenario ",
    scenarioName,
    " with reference scenario ",
    referenceScenarioName,
    " and sensitivity sheet ",
    sensitivitySheet,
    " (relative run)."
  ),
  paste0("- Sensitivity CSV files generated: ", sensitivityDataCount, "."),
  if (sensitivityDataCount > 0) {
    paste0(
      "  - CSV files: ",
      paste(basename(sensitivityDataFiles), collapse = ", ")
    )
  },
  if (sensitivityPlotsGenerated) {
    paste0(
      "- runPlot(plotSensitivity) completed for all configurations; successful entries: ",
      sensitivityPlotCount,
      "."
    )
  } else {
    paste0("- runPlot(plotSensitivity) failures: ", sensitivityPlotResult$error)
  },
  paste0(
    "- Exported sensitivity figure files: ",
    length(sensitivityOutputFiles),
    "."
  ),
  if (sensitivityPlotsFound) {
    paste0(
      "  - Figure files: ",
      paste(basename(sensitivityOutputFiles), collapse = ", ")
    )
  },
  paste0(
    "- Sensitivity CSV columns detected: ",
    paste(sensitivityResultColumns, collapse = ", ")
  ),
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC08A_Sensitivity.qmd"
  ),
  coverageReportSection(coverage, plotConfigSheet),
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "Generated Sensitivity Report",
    sectionDescription = "The following content is from the auto-generated UC08A_Sensitivity.qmd with exported sensitivity figures and captions:"
  ),
  ""
)

reportContent <- paste(reportLines, collapse = "\n")
reportPath <- file.path(reportFolder, "Report.md")
writeLines(reportContent, reportPath)

# Verify report creation
assertOrStop(
  file.exists(reportPath),
  "Failed to create report file"
)

assertOrStop(
  sensitivityDataCount > 0,
  "Sensitivity analysis did not produce any CSV output"
)

cat(
  "UC-08A absolute and relative sensitivity analysis functionality validation completed successfully!\n"
)

