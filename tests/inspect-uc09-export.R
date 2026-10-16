#!/usr/bin/env Rscript
# UC09 Export Inspection: Check what gets exported and executed

rm(list = ls())
library(ospsuite.reportingframework)
library(data.table)
source("R/helpers-uc-shared.R")

cat("\n=== UC09 Export Inspection ===\n\n")

projectDir <- tempfile(pattern = "uc09_export_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

cat("1. Setting up project and scenarios...\n")
pc <- setupProject(projectDir)
copyModelFiles(pc, "Aciclovir.pkml")

wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
scenariosConfig <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
scenarioOutputs <- xlsxReadData(wbScenarios, sheetName = "OutputPaths")

scenarioSetup <- makeDefaultScenarioTable(
    c("UC09_Scenario1", "UC09_Scenario2"),
    individualId = as.character(scenariosConfig$individualId[[1]]),
    outputPathId = as.character(scenarioOutputs$outputPathId[[1]]),
    modelFile = "Aciclovir.pkml"
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
runAndSaveScenarios(pc, scenarioList)

cat("  ✓ Project ready\n\n")

cat("2. Setting up data import fixtures...\n")
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

cat("  ✓ Fixtures ready\n\n")

cat("3. Creating TLF workflow...\n")
tlfWorkflowPath <- file.path(projectDir, "uc09_tlf_workflow.Rmd")
tlfSummaryFileName <- "UC09_TLF_Summary.csv"
tlfDataImportSummaryFileName <- "UC09_TLF_DataImport_Summary.csv"

createUC09TLFWorkflowWithDataImport(
    workflowPath = tlfWorkflowPath,
    scenarioNames = scenarioNames,
    dataImportConfigFile = file.path(dataImportDestPath, "DataImportConfiguration.xlsx"),
    summaryFileName = tlfSummaryFileName,
    dataImportSummaryFileName = tlfDataImportSummaryFileName
)

cat("  ✓ Rmd created\n\n")

cat("4. Exporting TLF workflow to ePackage...\n")
tlfExportResult <- tryCatch(
    {
        exportTLFWorkflowToEPackage(
            projectConfiguration = pc,
            wfIdentifier = 2,
            workflowRmd = tlfWorkflowPath
        )
        list(success = TRUE, error = NA_character_)
    },
    error = function(e) {
        list(success = FALSE, error = e$message)
    }
)

if (tlfExportResult$success) {
    cat("  ✓ Export succeeded\n\n")
} else {
    cat("  ✗ Export failed:", tlfExportResult$error, "\n\n")
}

cat("5. Inspecting exported ePackage...\n")
ePackagePath <- pc$addOns$electronicPackageFolder
ePackageFiles <- list.files(ePackagePath, recursive = TRUE, full.names = FALSE)

cat("  Files in ePackage:\n")
for (f in sort(ePackageFiles)) {
    cat("    -", f, "\n")
}

cat("\n6. Checking w2_workflow_r.txt...\n")
w2RunnerFile <- file.path(ePackagePath, "w2_workflow_r.txt")
if (file.exists(w2RunnerFile)) {
    cat("  ✓ Runner file found\n")
    allLines <- readLines(w2RunnerFile)
    cat("  Total lines:", length(allLines), "\n")
    
    cat("\n  Full runner content (all lines):\n")
    for (i in 1:min(length(allLines), 110)) {
        cat(sprintf("    %3d: %s\n", i, allLines[i]))
    }
    
    # Search for dataImport-related content
    dataImportLines <- grep("dataImport|UC09_TLF_DataImport", allLines, ignore.case = TRUE, value = TRUE)
    if (length(dataImportLines) > 0) {
        cat("\n  Data import references found in runner:\n")
        for (line in dataImportLines[1:min(5, length(dataImportLines))]) {
            cat("    -", line, "\n")
        }
    } else {
        cat("\n  ⚠ No data import references found in runner!\n")
    }
} else {
    cat("  ✗ Runner file NOT found\n")
}

cat("\n7. Checking input files manifest...\n")
w2ManifestFile <- file.path(ePackagePath, "w2_input_files.csv")
if (file.exists(w2ManifestFile)) {
    cat("  ✓ Manifest found\n")
    manifestContent <- read.csv(w2ManifestFile, stringsAsFactors = FALSE)
    cat("  Manifest entries (", nrow(manifestContent), " files):\n")
    for (i in 1:min(20, nrow(manifestContent))) {
        cat("    -", manifestContent[i, 1], "\n")
    }
    if (nrow(manifestContent) > 20) {
        cat("    ... and", nrow(manifestContent) - 20, "more\n")
    }
} else {
    cat("  ✗ Manifest NOT found\n")
}

cat("\n=== Inspection Complete ===\n\n")
