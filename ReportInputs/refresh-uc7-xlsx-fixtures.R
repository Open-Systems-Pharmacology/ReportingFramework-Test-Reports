# ============================================================================
# UC07 Workbook Refresh Runner
# ============================================================================
#
# Purpose:
#   Entry point for refreshing UC07 test fixture workbooks. This script:
#   1. Generates fresh workbooks from the ospsuite.reportingframework package
#   2. Overlays target data from existing checked-in workbooks
#   3. Handles workbook-specific formatting (description rows, custom sheets)
#   4. Publishes updated workbooks to ReportInputs/
#
# Configuration:
#   - settings: Per-workbook refresh rules (description row handling, sheet mapping)
#   - targetFiles: Paths to the three UC07 workbooks to refresh
#
# Workflow:
#   - Stage: Create fresh workbooks from framework in temp directory
#   - Refresh: Copy data from target workbooks into generated workbooks
#   - Publish: Move refreshed workbooks to ReportInputs/
#   - Report: Print summary of refresh operation
#
# Dependencies:
#   - ospsuite.reportingframework: Template workbook generation
#   - openxlsx: Low-level Excel workbook manipulation
#   - data.table: Efficient data manipulation
#   - helpers-uc-shared.R: Shared utility functions
#   - helpers-refresh-uc7-xlsx-fixtures.R: Refresh orchestration and data functions
#
# Usage:
#   Rscript ReportInputs/refresh-uc7-xlsx-fixtures.R
#
# ============================================================================

rm(list = ls())

library(data.table)
library(openxlsx)
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")
source("ReportInputs/helpers-refresh-uc7-xlsx-fixtures.R")


# ============================================================================
# CONFIGURATION: UC07 Workbook Refresh Settings
# ============================================================================
#
# Per-workbook configuration for refresh behavior. Each workbook has three
# configuration parameters that control how data is overlaid onto generated
# workbooks:
#
# - customReportSheetMap:
#     Maps custom plot sheet names (left) to framework template sheet names (right).
#     For Reports: Maps UC07A_TimeProfiles -> TimeProfiles (from framework),
#                  UC07B_PK_Boxplot -> PKParameter_Boxplot, etc.
#     For PKParameter: Maps PK_Plasma -> Template (custom sheet from framework)
#     For Scenarios: Empty (no custom sheets, all same-name sheets)
#
# - hasDescriptionRow:
#     Whether sheet 1 contains headers (row 1) and descriptions (row 2).
#     TRUE: Reports & PKParameter (preserve rows 1-2, write data from row 3)
#     FALSE: Scenarios (write data from row 2, no description row)
#
# - shouldDeleteMappedTemplateSheets:
#     Whether to delete framework template sheets after data is cloned to
#     custom names. Used by Reports (delete framework sheets after cloning
#     to UC07 plot names). Set FALSE for PKParameter/Scenarios.
#

settings <- list(
  # ---- Reports_UC07.xlsx ----
  # Base sheets: Scenarios, DataGroups, Outputs, ModelParameter, TimeRange
  # Custom sheets: UC07A_TimeProfiles, UC07B_PK_Boxplot, etc. (cloned from framework)
  # Behavior: Preserve description row 2; remove framework plot sheets after cloning
  Reports = list(
    customReportSheetMap = c(
      UC07J_SensitivityPlots = "SensitivityPlots",
      UC07A_TimeProfiles = "TimeProfiles",
      UC07B_PK_Boxplot = "PKParameter_Boxplot",
      UC07C_PK_Forest = "PKParameter_Forest",
      UC07D_PK_Forest = "PKParameter_Forest",
      UC07E_PK_Forest = "PKParameter_Forest",
      UC07F_PK_Forest = "PKParameter_Forest",
      UC07G_Histograms = "Histograms",
      UC07H_DistVsDemo = "DistributionVsRange"
    ),
    hasDescriptionRow = TRUE,
    shouldDeleteMappedTemplateSheets = TRUE
  ),

  # ---- PKParameter_UC07.xlsx ----
  # Sheets: PKParameter (always present), PK_Plasma (custom, cloned from Template)
  # Behavior: Preserve description row 2; keep framework Template sheet in output
  PKParameter = list(
    customReportSheetMap = c(PK_Plasma = "Template"),
    hasDescriptionRow = TRUE,
    shouldDeleteMappedTemplateSheets = FALSE
  ),

  # ---- Scenarios_UC07.xlsx ----
  # Sheets: Scenarios, OutputPaths, PKParameter (all same-name, no custom mapping)
  # Behavior: No description row (write from row 2); no template sheets to delete
  Scenarios = list(
    customReportSheetMap = c(),
    hasDescriptionRow = FALSE,
    shouldDeleteMappedTemplateSheets = FALSE
  )
)

# ============================================================================
# TARGET WORKBOOK PATHS
# ============================================================================
#
# The three UC07 workbooks to refresh. These are the checked-in fixture files
# that will receive data overlaid from generated framework workbooks.
#

targetFiles <- c(
  Scenarios = file.path(resolveReportInputsRoot(), "Scenarios_UC07.xlsx"),
  Reports = file.path(resolveReportInputsRoot(), "Reports_UC07.xlsx"),
  PKParameter = file.path(resolveReportInputsRoot(), "PKParameter_UC07.xlsx")
)

# Verify all target workbooks exist before proceeding
invisible(sapply(targetFiles, checkmate::assertFileExists))


# ============================================================================
# EXECUTION: Refresh Workflow
# ============================================================================
#
# The refresh process follows a three-stage workflow:
#   1. STAGE:   Generate fresh workbooks from ospsuite.reportingframework
#   2. REFRESH: Overlay target data and handle workbook-specific formatting
#   3. PUBLISH: Copy refreshed workbooks to final ReportInputs/ location
#

# Create temporary staging directory for generated workbooks
# This keeps the staging area isolated from the final location and allows
# for cleanup on exit (whether the script succeeds or fails).
#
stageDir <- tempfile(pattern = "uc07_xlsx_stage_")
dir.create(stageDir, recursive = TRUE, showWarnings = FALSE)
# Ensure staging directory is cleaned up on exit
on.exit(unlink(stageDir, recursive = TRUE, force = TRUE), add = TRUE)

# STAGE (Step 1): Generate fresh workbooks from ospsuite.reportingframework
# package templates and place them in the staging directory.
#
generatedFiles <- stageGeneratedUC7Workbooks(
  targetFiles = targetFiles,
  stageDir = stageDir
)

# REFRESH (Step 2): Overlay data from target (checked-in) workbooks into the
# generated workbooks. This process:
#   - Copies same-name sheets directly (e.g., Scenarios sheet to Scenarios sheet)
#   - Clones framework template sheets to custom names (e.g., TimeProfiles -> UC07A_TimeProfiles)
#   - Overlays target data while preserving formatting (headers, description rows)
#   - Removes empty-cell #NA markers
#   - Deletes framework template sheets after cloning (Reports only)
#
refreshUC7Workbook(generatedFiles, targetFiles, settings)

# PUBLISH (Step 3): Move refreshed workbooks from staging directory to final
# ReportInputs/ location. This replaces the previously checked-in fixture files.
#
publishUC7Workbooks(generatedFiles, targetFiles)

# REPORT (Step 4): Print a summary of the refresh operation to the console
# showing which workbooks were refreshed and completion status.
#
printUC7WorkbookRefreshSummary(targetFiles)
