#!/usr/bin/env Rscript
# Test script: Verify ePackage structure and importProjectConfiguration folder creation

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

cat("\n=== UC09 ePackage Structure Verification ===\n\n")

# Setup
projectDir <- tempfile(pattern = "uc09_inspect_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

cat("1. Initializing project...\n")
pc <- setupProject(projectDir)
copyModelFiles(pc, "Aciclovir.pkml")

# Create minimal scenarios
wbScenarios <- openxlsx::loadWorkbook(pc$scenariosFile)
scenariosConfig <- xlsxReadData(wbScenarios, sheetName = "Scenarios")
scenarioOutputs <- xlsxReadData(wbScenarios, sheetName = "OutputPaths")

defaultIndividualId <- as.character(scenariosConfig$individualId[[1]])
defaultOutputPathId <- as.character(scenarioOutputs$outputPathId[[1]])

scenarioSetup <- makeDefaultScenarioTable(
    c("TestScen1", "TestScen2"),
    individualId = defaultIndividualId,
    outputPathId = defaultOutputPathId,
    modelFile = "Aciclovir.pkml"
)

xlsxWriteData(wbScenarios, sheetName = "Scenarios", scenarioSetup)
openxlsx::saveWorkbook(wbScenarios, pc$scenariosFile, overwrite = TRUE)

# Create and run scenarios
scenarioList <- createScenariosWrapped(pc, scenarioNames = NULL)
scenarioNames <- names(scenarioList)
scenarioResults <- runAndSaveScenarios(pc, scenarioList)

cat("  Scenarios created:", paste(scenarioNames, collapse = ", "), "\n")
cat("  Scenarios simulated:", length(scenarioResults), "\n\n")

# Export simulation workflow
cat("2. Exporting simulation workflow...\n")
exportSimulationWorkflowToEPackage(
    projectConfiguration = pc,
    wfIdentifier = 1,
    scenarioNames = scenarioNames
)

ePackageFolderPath <- pc$addOns$electronicPackageFolder
cat("  ePackage folder:", ePackageFolderPath, "\n\n")

# Inspect exported structure
cat("3. Inspecting exported ePackage structure...\n")
ePackageContents <- list.files(
    ePackageFolderPath,
    recursive = TRUE,
    full.names = FALSE
)
cat("  Total files in ePackage:", length(ePackageContents), "\n")
cat("  Exported structure:\n")
for (f in sort(ePackageContents)) {
    cat("    -", f, "\n")
}

# Check key exported files
w1_runner <- file.path(ePackageFolderPath, "w1_workflow_r.txt")
w1_config <- file.path(ePackageFolderPath, "w1_config_json.txt")
w1_manifest <- file.path(ePackageFolderPath, "w1_input_files.csv")

cat("\n  Exported runners:\n")
cat("    w1_workflow_r.txt exists:", file.exists(w1_runner), "\n")
cat("    w1_config_json.txt exists:", file.exists(w1_config), "\n")
cat("    w1_input_files.csv exists:", file.exists(w1_manifest), "\n\n")

# Now test the imported structure
cat("4. Testing importProjectConfiguration folder creation...\n\n")

# Create a clean directory for the imported project
importedProjectDir <- tempfile(pattern = "uc09_imported_")
dir.create(importedProjectDir, recursive = TRUE, showWarnings = FALSE)
on.exit(unlink(importedProjectDir, recursive = TRUE, force = TRUE), add = TRUE)

cat("  Import directory:", importedProjectDir, "\n")

# Change to ePackage directory and import
old_wd <- getwd()
on.exit(setwd(old_wd), add = TRUE)
setwd(ePackageFolderPath)

cat("5. Calling importProjectConfiguration...\n")
importedPC <- tryCatch(
    {
        ospsuite.reportingframework::importWorkflow(
            projectDirectory = importedProjectDir,
            wfIdentifier = 1,
            ePackageFolder = "."
        )
    },
    error = function(e) {
        cat("  ERROR:", e$message, "\n")
        NULL
    }
)

setwd(old_wd)

if (!is.null(importedPC)) {
    cat("  Successfully imported.\n\n")

    cat("6. Inspecting imported project structure...\n")

    # Check folder structure
    folders_to_check <- c(
        "base" = importedProjectDir,
        "Models" = importedPC$modelFolder,
        "Populations" = importedPC$populationsFolder,
        "Output" = importedPC$outputFolder,
        "Config" = dirname(importedPC$scenariosFile)
    )

    cat("  Folder structure:\n")
    for (label in names(folders_to_check)) {
        folder_path <- folders_to_check[[label]]
        exists <- dir.exists(folder_path)
        file_count <- if (exists) {
            length(list.files(folder_path, recursive = TRUE))
        } else {
            0
        }
        cat(sprintf(
            "    %s: %s (path: %s, files: %d)\n",
            label,
            if (exists) "✓" else "✗",
            folder_path,
            file_count
        ))
    }

    cat("\n  Configuration files:\n")
    config_files <- c(
        "Scenarios" = importedPC$scenariosFile,
        "PK Parameters" = importedPC$addOns$pKParameterFile,
        "Reports" = importedPC$addOns$reportsFile
    )

    for (label in names(config_files)) {
        file_path <- config_files[[label]]
        exists <- file.exists(file_path)
        cat(sprintf(
            "    %s: %s (path: %s)\n",
            label,
            if (exists) "✓" else "✗",
            file_path
        ))
    }

    cat("\n  Simulations output folder contents:\n")
    sim_output <- file.path(importedPC$outputFolder, "SimulationResults")
    if (dir.exists(sim_output)) {
        sim_files <- list.files(
            sim_output,
            recursive = TRUE,
            full.names = FALSE
        )
        if (length(sim_files) > 0) {
            for (f in sort(sim_files)) {
                cat("    -", f, "\n")
            }
        } else {
            cat("    (empty)\n")
        }
    } else {
        cat("    (folder does not exist)\n")
    }
} else {
    cat("  Import failed. Skipping structure check.\n")
}

cat("\n=== Verification Complete ===\n\n")
