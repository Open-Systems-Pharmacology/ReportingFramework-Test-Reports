library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")
projectDir <- "tests/tmp-uc09-debug-project"
unlink(projectDir, recursive = TRUE, force = TRUE)
dir.create(projectDir, recursive = TRUE, showWarnings = FALSE)
pc <- setupProject(projectDir)
copyModelFiles(pc, "Aciclovir.pkml")
wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
scenariosConfig <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
scenarioOutputs <- xlsxReadData(wbScenarios, sheetName = "OutputPaths")
defaultIndividualId <- as.character(scenariosConfig$individualId[[1]])
defaultOutputPathId <- as.character(scenarioOutputs$outputPathId[[1]])
copyPopulations(pc, files = "adults.csv")
scenarioSetup <- data.table::rbindlist(list(
  makeDefaultScenarioTable(
    "UC09_Scenario1",
    individualId = defaultIndividualId,
    outputPathId = defaultOutputPathId,
    modelFile = "Aciclovir.pkml"
  ),
  makeDefaultScenarioTable(
    "UC09_PopulationScenario",
    outputPathId = defaultOutputPathId,
    modelFile = "Aciclovir.pkml"
  )
), use.names = TRUE)
scenarioSetup[scenario_name == "UC09_PopulationScenario", populationId := "adults"]
scenarioSetup[, readPopulationFromCSV := ifelse(
  scenario_name == "UC09_PopulationScenario",
  "TRUE",
  "FALSE"
)]
xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)
scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
runAndSaveScenarios(pc, scenarioList)
exportSimulationWorkflowToEPackage(
  projectConfiguration = pc,
  wfIdentifier = 1,
  scenarioNames = scenarioNames
)
ePackageFolderPath <- pc$addOns$electronicPackageFolder
cat("RUNNER\n")
cat(paste(readLines(file.path(ePackageFolderPath, "w1_workflow_r.txt")), collapse = "\n"))
cat("\nMANIFEST\n")
manifestPath <- file.path(ePackageFolderPath, "w1_input_files_csv.txt")
if (file.exists(manifestPath)) {
  cat(paste(readLines(manifestPath), collapse = "\n"))
}
cat("\nCONFIG\n")
cat(paste(readLines(file.path(ePackageFolderPath, "w1_config_json.txt")), collapse = "\n"))
