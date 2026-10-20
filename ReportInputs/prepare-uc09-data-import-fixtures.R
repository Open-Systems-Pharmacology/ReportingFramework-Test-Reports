#!/usr/bin/env Rscript
# Prepare UC09 data import fixtures from UC10
# Copy time-profile CSVs and trim DataImportConfiguration.xlsx to TP only

rm(list = ls())
library(data.table)
library(openxlsx)
library(ospsuite.reportingframework)

# Paths
uc10Dir <- "ReportInputs/UC10_DataImport"
uc09Dir <- "ReportInputs/UC09_DataImport"

# Create UC09 directory
dir.create(uc09Dir, recursive = TRUE, showWarnings = FALSE)

cat("=== UC09 Data Import Fixtures Preparation ===\n\n")

# 1. Copy time-profile CSVs
cat("1. Copying time-profile CSVs...\n")
file.copy(
    from = file.path(uc10Dir, "tp_individual.csv"),
    to = file.path(uc09Dir, "tp_individual.csv"),
    overwrite = TRUE
)
cat("   ✓ tp_individual.csv copied\n")

file.copy(
    from = file.path(uc10Dir, "tp_aggregated.csv"),
    to = file.path(uc09Dir, "tp_aggregated.csv"),
    overwrite = TRUE
)
cat("   ✓ tp_aggregated.csv copied\n")

# 2. Copy and trim DataImportConfiguration.xlsx
cat("\n2. Trimming DataImportConfiguration.xlsx...\n")

# Copy template
file.copy(
    from = file.path(uc10Dir, "DataImportConfiguration.xlsx"),
    to = file.path(uc09Dir, "DataImportConfiguration.xlsx"),
    overwrite = TRUE
)

# Load the workbook
wb <- loadWorkbook(file.path(uc09Dir, "DataImportConfiguration.xlsx"))

# Read and trim DataFiles sheet (keep only rows for tp_individual and tp_aggregated)
dataFilesPath <- file.path(uc09Dir, "DataImportConfiguration.xlsx")
dataFiles <- xlsxReadData(
    wb = dataFilesPath,
    sheetName = "DataFiles",
    skipDescriptionRow = TRUE,
    emptyAsNA = FALSE
)

# Filter to keep only tp_individual and tp_aggregated
# DataFiles sheet has: FileIdentifier, DataFile, Dictionary, DataFilter, DataClass
# We want rows 1-2 (tp_individual, tp_aggregated)
dataFilesTrimmed <- dataFiles[1:2, ]

cat("   DataFiles sheet trimmed to:\n")
for (i in seq_len(nrow(dataFilesTrimmed))) {
    cat("     -", dataFilesTrimmed[[i, 1]], "\n")
}

# Remove sheets for PK and Numeric data
cat("\n3. Removing unused sheets...\n")
if ("pkDictionary" %in% names(wb)) {
    removeWorksheet(wb, "pkDictionary")
    cat("   ✓ Removed pkDictionary sheet\n")
}

if ("NumericValues" %in% names(wb)) {
    removeWorksheet(wb, "NumericValues")
    cat("   ✓ Removed NumericValues sheet\n")
}

# Update DataFiles sheet with trimmed data
cat("\n4. Updating DataFiles sheet...\n")
if ("DataFiles" %in% names(wb)) {
    removeWorksheet(wb, "DataFiles")
}
addWorksheet(wb, "DataFiles")
writeData(
    wb,
    sheet = "DataFiles",
    x = dataFilesTrimmed,
    startRow = 1,
    colNames = TRUE
)
cat("   ✓ DataFiles sheet updated\n")

# Save the trimmed workbook
saveWorkbook(
    wb,
    file.path(uc09Dir, "DataImportConfiguration.xlsx"),
    overwrite = TRUE
)

cat("\n=== Preparation Complete ===\n")
cat("✓ UC09_DataImport folder created at:", uc09Dir, "\n")
cat("✓ Fixtures ready for UC09 TLF workflow with data import\n\n")
