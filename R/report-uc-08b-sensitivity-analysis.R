#' @title report-uc-08b-sensitivity-analysis
#' @description
#' Integration scenario for UC-08B representative sensitivity analysis using
#' population scenarios.

rm(list = ls())
library(ospsuite.reportingframework)
pkgload::load_all(path = file.path('..', 'OSPSuite.ReportingFramework'))
source("R/helpers-uc-shared.R")

reportFolder <- file.path(
  "tests",
  "Reports",
  "UC-08B-Sensitivity-Analysis"
)
projectDir <- tempfile(pattern = "uc08b_sensitivity_representative_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

selectedScenarioNames <- c(
  "adolescents_po",
  "children_po",
  "school_children_po",
  "toddler_po"
)
plotConfigSheet <- "UC08b_SensitivityPlots"
sensitivitySheet <- "UC08"
qmdName <- "UC08B_Sensitivity_Representatives"

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

# Initialize project
pc <- setupProject(projectDir)

updateUC7Project(
  pc,
  scenarioNames = selectedScenarioNames,
  copyPK = TRUE,
  copySimResult = TRUE
)

# Copy model file required by the workbook-defined mean model scenario.
copyModelFiles(pc, "po_3_mg_solution.pkml")

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

# Step 1: Validate workbook-driven scenarios and normalize the copied UC08 plot rows.
wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
scenariosConfigSheet <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
missingScenarios <- setdiff(
  selectedScenarioNames,
  scenariosConfigSheet$scenario_name
)
assertOrStop(
  length(missingScenarios) == 0,
  paste0(
    "Scenario(s) not found in Scenarios_UC07.xlsx: ",
    paste(missingScenarios, collapse = ", ")
  )
)

wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)
assertOrStop(
  plotConfigSheet %in% openxlsx::getSheetNames(pc$addOns$reportsFile),
  paste0("Sheet not found in Reports_UC07.xlsx: ", plotConfigSheet)
)

# Create scenarios
scenarioList <- createScenariosWrapped(
  pc,
  scenarioNames = selectedScenarioNames
)
createdScenarioNames <- names(scenarioList)

assertOrStop(
  setequal(createdScenarioNames, selectedScenarioNames),
  paste0(
    "Failed to create the expected scenarios. Created: ",
    paste(createdScenarioNames, collapse = ", ")
  )
)

# Add sensitivity Table
addSensitivityTable(
  projectConfiguration = pc,
  scenarioList = scenarioList,
  sheetName = sensitivitySheet
)

sensitivitySheetData <- adjustSensitivitySheetWorkbookForUC(
  sensitivityFile = pc$addOns$sensitivityFile,
  sheetName = sensitivitySheet,
  parameterPattern = "^DrugX-CYP3A4",
  keepTopN = 6
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

# use only top-level CYP3A4 entries that are stable across scenarios
assertOrStop(
  nrow(dtData) > 0,
  "No top-level CYP3A4 sensitivity parameters found for UC08B selection"
)

uniqueParameterNames <- sort(unique(dtData$parameter))
uniqueParameterCount <- length(uniqueParameterNames)
expectedSensitivityFiles <- paste0(
  selectedScenarioNames,
  "_",
  sensitivitySheet,
  "_representatives.csv"
)

runRepresentativeSensitivityAnalysisForScenarios(
  projectConfiguration = pc,
  scenarioList = scenarioList,
  scenarioNames = selectedScenarioNames,
  sensitivitysheet = sensitivitySheet
)

sensitivityDataFiles <- list.files(
  sensitivityResultsPath,
  pattern = paste0("_", sensitivitySheet, "_representatives\\.csv$"),
  full.names = TRUE
)
sensitivityDataBasenames <- basename(sensitivityDataFiles)

missingSensitivityFiles <- setdiff(
  expectedSensitivityFiles,
  sensitivityDataBasenames
)
assertOrStop(
  length(missingSensitivityFiles) == 0,
  paste0(
    "Representative sensitivity output file(s) missing: ",
    paste(missingSensitivityFiles, collapse = ", ")
  )
)

sensitivityResults <- data.table::rbindlist(
  lapply(
    expectedSensitivityFiles,
    function(fileName) {
      data.table::fread(file.path(sensitivityResultsPath, fileName))
    }
  ),
  idcol = "scenarioIndex"
)

sensitivityDataCount <- length(expectedSensitivityFiles)
uniquePkParameters <- sort(unique(sensitivityResults$PKParameter))
sensitivityResultColumns <- colnames(sensitivityResults)
parameterPreviewCount <- min(8, uniqueParameterCount)
parameterLabelPreview <- paste(
  utils::head(uniqueParameterNames, parameterPreviewCount),
  collapse = ", "
)
remainingParameterCount <- uniqueParameterCount - parameterPreviewCount
expectedRepresentativeColumns <- c(
  "RepresentativeQuantile",
  "RepresentativeIndividualId"
)

assertOrStop(
  nrow(sensitivityResults) > 0,
  "Representative sensitivity analysis did not produce any result rows"
)

assertOrStop(
  all(expectedRepresentativeColumns %in% sensitivityResultColumns),
  paste0(
    "Missing representative sensitivity columns: ",
    paste(
      setdiff(expectedRepresentativeColumns, sensitivityResultColumns),
      collapse = ", "
    )
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

  rangeCall <- tryCatch(
    {
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
    },
    error = function(e) {
      e
    }
  )

  if (inherits(rangeCall, "error")) {
    coverage$status[[i]] <- "FAIL"
    coverage$errorMessage[[i]] <- rangeCall$message
    next
  }

  coverage$returnedObjects[[i]] <- length(rangeCall)
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
  "# UC-08B Representative Sensitivity Analysis",
  "",
  "## Summary",
  "",
  "This scenario validates representative-individual sensitivity analysis and figure generation for population scenarios.",
  "",
  "## Approach",
  "",
  "- Reuses UC07 scenario/report workbooks and PK fixtures from ReportInputs to configure population scenario execution.",
  "- Creates the UC08 sensitivity parameter sheet with addSensitivityTable(), then keeps a focused parameter subset.",
  "- Executes runRepresentativeSensitivityAnalysisForScenarios() for population scenarios with representative quantiles.",
  "- Verifies scenario-level representative CSV outputs and required representative columns.",
  "- Generates sensitivity figures with runPlot(nameOfplotFunction = 'plotSensitivity') and renders UC08B_Sensitivity_Representatives.qmd.",
  "",
  "## Assertions",
  "",
  paste0("- Scenarios created: ", paste(createdScenarioNames, collapse = ", ")),
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
    "- Representative sensitivity rows generated: ",
    nrow(sensitivityResults),
    "."
  ),
  paste0(
    "- runRepresentativeSensitivityAnalysisForScenarios() executed for ",
    length(selectedScenarioNames),
    " scenarios and sensitivity sheet ",
    sensitivitySheet,
    "."
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
  "- Combined multi-scenario representative plot generated from representative sensitivity outputs.",
  qmdRenderAssertionLine(
    qmdRenderResult,
    assertionPrefix = "UC08B_Sensitivity_Representatives.qmd"
  ),
  "",
  "## Combined Multi-Scenario Representative Plot",
  "",
  "Scenario is encoded by color and representative quantile is encoded by point symbol.",
  "",
  "![](UC08B_Sensitivity_MultiScenario.png)",
  "",
  coverageReportSection(coverage, plotConfigSheet),
  qmdRenderContentSection(
    qmdRenderResult,
    sectionTitle = "Generated Sensitivity Report",
    sectionDescription = "The following content is from the auto-generated UC08B_Sensitivity_Representatives.qmd with exported sensitivity figures and captions:"
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
  "UC-08B representative sensitivity analysis functionality validation completed successfully!\n"
)
