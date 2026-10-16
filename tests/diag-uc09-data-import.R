#!/usr/bin/env Rscript
# Diagnostic: Check UC09 data import workflow step by step

rm(list = ls())
library(ospsuite.reportingframework)
library(data.table)
source("R/helpers-uc-shared.R")

cat("\n=== UC09 Data Import Diagnostic ===\n\n")

projectDir <- tempfile(pattern = "uc09_diag_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

cat("1. Setting up project...\n")
pc <- setupProject(projectDir)
copyModelFiles(pc, "Aciclovir.pkml")

cat("2. Creating scenarios...\n")
wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
scenariosConfig <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
scenarioOutputs <- xlsxReadData(wbScenarios, sheetName = "OutputPaths")

defaultIndividualId <- as.character(scenariosConfig$individualId[[1]])
defaultOutputPathId <- as.character(scenarioOutputs$outputPathId[[1]])

scenarioSetup <- makeDefaultScenarioTable(
    c("UC09_Scenario1", "UC09_Scenario2"),
    individualId = defaultIndividualId,
    outputPathId = defaultOutputPathId,
    modelFile = "Aciclovir.pkml"
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
runAndSaveScenarios(pc, scenarioList)

cat("  ✓ Scenarios:", paste(scenarioNames, collapse = ", "), "\n\n")

cat("3. Copying data import fixtures...\n")
dataImportSourcePath <- reportInputsPath("UC09_DataImport")
projectScriptsDir <- dirname(pc$scenariosFile)
dataImportDestPath <- file.path(projectScriptsDir, "UC09_DataImport")
dir.create(dataImportDestPath, recursive = TRUE, showWarnings = FALSE)

file.copy(
    from = file.path(dataImportSourcePath, "tp_individual.csv"),
    to = file.path(dataImportDestPath, "tp_individual.csv"),
    overwrite = TRUE
)
file.copy(
    from = file.path(dataImportSourcePath, "tp_aggregated.csv"),
    to = file.path(dataImportDestPath, "tp_aggregated.csv"),
    overwrite = TRUE
)
file.copy(
    from = file.path(dataImportSourcePath, "DataImportConfiguration.xlsx"),
    to = file.path(dataImportDestPath, "DataImportConfiguration.xlsx"),
    overwrite = TRUE
)

cat("  ✓ Fixtures copied to:", dataImportDestPath, "\n")
cat("  ✓ Files:", paste(list.files(dataImportDestPath), collapse = ", "), "\n\n")

cat("4. Creating TLF workflow Rmd...\n")
tlfWorkflowPath <- file.path(projectDir, "uc09_tlf_workflow.Rmd")
tlfSummaryFileName <- "UC09_TLF_Summary.csv"
tlfDataImportSummaryFileName <- "UC09_TLF_DataImport_Summary.csv"

dataImportConfigPath <- file.path(dataImportDestPath, "DataImportConfiguration.xlsx")

createUC09TLFWorkflowWithDataImport(
    workflowPath = tlfWorkflowPath,
    scenarioNames = scenarioNames,
    dataImportConfigFile = dataImportConfigPath,
    summaryFileName = tlfSummaryFileName,
    dataImportSummaryFileName = tlfDataImportSummaryFileName
)

cat("  ✓ Rmd created:", tlfWorkflowPath, "\n\n")

cat("5. Inspecting generated Rmd chunks...\n")
rmdLines <- readLines(tlfWorkflowPath)
dataImportChunkStart <- grep("dataImport-eval", rmdLines)[1]
if (!is.na(dataImportChunkStart)) {
    cat("  ✓ dataImport chunk found at line", dataImportChunkStart, "\n")
    cat("    Lines:\n")
    for (i in dataImportChunkStart:(dataImportChunkStart + 10)) {
        if (i <= length(rmdLines)) {
            cat("      ", rmdLines[i], "\n")
        }
    }
} else {
    cat("  ✗ dataImport chunk NOT FOUND\n")
}

cat("\n6. Attempting to render Rmd directly...\n")
tryCatch(
    {
        rmarkdown::render(
            tlfWorkflowPath,
            output_file = file.path(projectDir, "test_output.html"),
            quiet = TRUE,
            params = list()
        )
        cat("  ✓ Rmd rendering succeeded\n")
    },
    error = function(e) {
        cat("  ✗ Rmd rendering failed:", e$message, "\n")
    }
)

cat("\n=== Diagnostic Complete ===\n\n")
