#!/usr/bin/env Rscript
# Diagnostic: Examine generated Rmd and exported workflow for data import

rm(list = ls())
library(ospsuite.reportingframework)
library(data.table)
source("R/helpers-uc-shared.R")

# Setup
projectDir <- tempfile()
dir.create(projectDir, recursive = TRUE)

pc <- createTestScenariosUC09(
    projectDir,
    c("UC09_Scenario1", "UC09_Scenario2")
)

# Step 1: Generate TLF workflow
tlfWorkflowPath <- file.path(projectDir, "uc09_tlf_workflow.Rmd")
createUC09TLFWorkflowWithDataImport(
    tlfWorkflowPath,
    c("UC09_Scenario1", "UC09_Scenario2"),
    dataImportConfigFile = "DataImportConfiguration.xlsx"
)

cat("=== Generated TLF Workflow Rmd ===\n\n")
rmdLines <- readLines(tlfWorkflowPath)
cat("Total lines in Rmd:", length(rmdLines), "\n\n")

# Show loadResults chunk
cat("--- loadResults-copy chunk (lines with 'tpIndividual' or 'INCLUDE') ---\n")
for (i in seq_along(rmdLines)) {
    if (grepl("tpIndividual|INCLUDE|dataImportResults", rmdLines[i])) {
        cat(sprintf("[%3d] %s\n", i, rmdLines[i]))
    }
}

cat("\n--- runPlot-copy chunk (lines with 'dataImportResults' or 'fwrite') ---\n")
for (i in seq_along(rmdLines)) {
    if (grepl("dataImportResults|UC09_TLF_DataImport_Summary|fwrite.*dataImportCsv", rmdLines[i])) {
        cat(sprintf("[%3d] %s\n", i, rmdLines[i]))
    }
}

# Step 2: Export to ePackage  
ePackagePath <- file.path(projectDir, "ePackage")
dir.create(ePackagePath, showWarnings = FALSE)

cat("\n\n=== Exporting TLF Workflow ===\n")
exportResult <- tryCatch({
    exportTLFWorkflowToEPackage(
        projectConfiguration = pc,
        workflowFiles = tlfWorkflowPath,
        ePackageFolder = ePackagePath
    )
    list(success = TRUE, error = NULL)
}, error = function(e) {
    list(success = FALSE, error = as.character(e))
})

if (!exportResult$success) {
    cat("ERROR during export:", exportResult$error, "\n")
} else {
    cat("Export successful!\n")
}

# Step 3: Check exported workflow
exportedWorkflowFile <- file.path(ePackagePath, "w2_workflow_r.txt")
if (file.exists(exportedWorkflowFile)) {
    cat("\n=== Exported Workflow (w2_workflow_r.txt) ===\n\n")
    exportedLines <- readLines(exportedWorkflowFile)
    cat("Total lines in exported workflow:", length(exportedLines), "\n\n")
    
    # Find data import related lines
    cat("--- Lines with data import references ---\n")
    for (i in seq_along(exportedLines)) {
        if (grepl("tpIndividual|tpAggregated|INCLUDE|dataImportResults", exportedLines[i])) {
            cat(sprintf("[%3d] %s\n", i, exportedLines[i]))
        }
    }
    
    cat("\n--- Lines with dataImportCsv/fwrite ---\n")
    for (i in seq_along(exportedLines)) {
        if (grepl("dataImportCsv|UC09_TLF_DataImport_Summary|fwrite", exportedLines[i])) {
            cat(sprintf("[%3d] %s\n", i, exportedLines[i]))
        }
    }
} else {
    cat("ERROR: Exported workflow file not found!\n")
}

# Cleanup
unlink(projectDir, recursive = TRUE)
cat("\n\n=== Diagnostic Complete ===\n")
