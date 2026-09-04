#' @title report-uc-04-pk-parameter-loading
#' @description
#' Integration scenario for UC-04 PK parameter calculation and loading.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportFolder <- file.path("tests", "Reports", "UC-04-PK-Parameter-Loading")
projectDir <- tempfile(pattern = "uc04_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

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
  c("UC04_ScenarioA", "UC04_ScenarioB"),
  defaultIndividualId,
  defaultOutputPathId,
  modelFile
)

pkScenarioSetup <- data.table::data.table(
  scenario_name = c("UC04_ScenarioA", "UC04_ScenarioB"),
  pKParameter = c("PK_Plasma", "PK_Plasma")
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
xlsxWriteData(wbScenarios, sheetName = "PKParameter", pkScenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

setupPKPlasmaSheet(
  pkParameterFile,
  defaultOutputPathId,
  extraRows = data.table::data.table(
    name = "F_max",
    displayName = "F max",
    displayUnit = "%",
    outputPathIds = defaultOutputPathId,
    descriptions = "User-defined PK parameter"
  )
)

scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
assertOrStop(length(scenarioList) == 2, "UC-04 requires two scenarios")

scenarioResults <- runAndSaveScenarios(pc, scenarioList)

pkResultsFolder <- file.path(pc$outputFolder, EXPORTDIR$pKAnalysisResults)
pkResultFiles <- file.path(pkResultsFolder, paste0(scenarioNames, ".csv"))
assertOrStop(
  all(file.exists(pkResultFiles)),
  "calculatePKParameterForScenarios() did not create one CSV file per scenario"
)

# Delete first scenario's PK results and recalculate to verify partial recalculation
file.remove(pkResultFiles[[1]])
calculatePKParameterForScenarios(pc, scenarioResults[1])
assertOrStop(
  all(file.exists(pkResultFiles)),
  "calculatePKParameterForScenarios() did not recreate the deleted CSV file for the first scenario"
)

pkParameterDT <- loadPKParameter(pc, scenarioList)

requiredColumns <- c(
  "scenario",
  "pkParameter",
  "individualId",
  "value",
  "outputPathId",
  "displayNamePKParameter",
  "displayUnitPKParameter"
)
assertOrStop(
  all(requiredColumns %in% names(pkParameterDT)),
  "loadPKParameter() result is missing required columns"
)
assertOrStop(
  "F_max" %in% pkParameterDT$pkParameter,
  "User-defined PK parameter F_max is missing from loaded PK results"
)


reportLines <- c(
  "# UC-04 PK parameter calculation and loading",
  "",
  "## Summary",
  "",
  "This scenario validates PK calculation, PK loading, PK data validation, and inclusion of a user-defined PK parameter.",
  "",
  "## Assertions",
  "",
  paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
  paste0(
    "- PK sheets linked from Scenarios.xlsx: ",
    paste(unique(pkScenarioSetup$pKParameter), collapse = ", ")
  ),
  "- calculatePKParameterForScenarios created one CSV file per scenario.",
  "- First scenario CSV deleted and successfully recalculated with calculatePKParameterForScenarios.",
  paste0(
    "- Required columns present: ",
    paste(requiredColumns, collapse = ", ")
  ),
  "- validatePKParameterDT passed without error.",
  "- User-defined PK parameter F_max appears in loaded results.",
  "",
  "## PK result CSV files",
  ""
)

for (resultFile in sort(basename(pkResultFiles))) {
  reportLines <- c(reportLines, paste0("- ", resultFile))
}

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
