#' @title report-uc-10-data-dictionary
#' @description
#' Integration scenario for UC-10 dictionary-driven import coverage across
#' time profiles, PK parameters, and numeric values.

rm(list = ls())
library(openxlsx)
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportFolder <- file.path(
  "tests",
  "Reports",
  "UC-10-Data-Dictionary-Operations"
)
projectDir <- tempfile(pattern = "uc10_dict_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

readConfigSheet <- function(workbookPath, sheetName) {
  xlsxReadData(
    wb = workbookPath,
    sheetName = sheetName,
    skipDescriptionRow = TRUE,
    emptyAsNA = FALSE,
    convertHeaders = FALSE
  )
}

safeSheetRows <- function(workbookPath, sheetName) {
  dataTable <- tryCatch(
    xlsxReadData(
      wb = workbookPath,
      sheetName = sheetName,
      skipDescriptionRow = TRUE
    ),
    error = function(e) data.table::data.table()
  )
  nrow(dataTable)
}

countNonMissing <- function(values) {
  if (is.character(values)) {
    sum(!is.na(values) & nzchar(values))
  } else {
    sum(!is.na(values))
  }
}

stripOuterQuotes <- function(values) {
  output <- as.character(values)
  output[is.na(values)] <- NA_character_
  sub('^"(.*)"$', '\\1', output)
}

assertColumnsPresent <- function(dataTable, expectedColumns, label) {
  missingColumns <- setdiff(expectedColumns, names(dataTable))
  assertOrStop(
    length(missingColumns) == 0,
    paste0(
      label,
      " is missing expected columns: ",
      paste(missingColumns, collapse = ", ")
    )
  )
}

assertPopulatedColumns <- function(dataTable, columns, label) {
  emptyColumns <- vapply(
    columns,
    function(columnName) {
      countNonMissing(dataTable[[columnName]]) == 0
    },
    logical(1)
  )

  assertOrStop(
    !any(emptyColumns),
    paste0(
      label,
      " has empty imported columns: ",
      paste(columns[emptyColumns], collapse = ", ")
    )
  )
}

pc <- setupProject(projectDir)
copyUC10DataImportFixtures(pc)

expectedSheets <- c(
  "DataFiles",
  "tpDictionary",
  "pkDictionary",
  "NumericValues"
)
sheetNames <- openxlsx::getSheetNames(pc$addOns$dataImportMapFile)
assertOrStop(
  all(expectedSheets %in% sheetNames),
  paste0(
    "Fixture workbook is missing required sheets: ",
    paste(setdiff(expectedSheets, sheetNames), collapse = ", ")
  )
)

dataFilesConfig <- readConfigSheet(
  pc$addOns$dataImportMapFile,
  "DataFiles"
)
tpDictionary <- readConfigSheet(
  pc$addOns$dataImportMapFile,
  "tpDictionary"
)
pkDictionary <- readConfigSheet(
  pc$addOns$dataImportMapFile,
  "pkDictionary"
)
numericValuesConfig <- readConfigSheet(
  pc$addOns$dataImportMapFile,
  "NumericValues"
)


tpObserved <- suppressWarnings(readObservedDataByDictionary(
  projectConfiguration = pc,
  spreadData = FALSE,
  dataClassType = "timeprofile"
))
pkObserved <- suppressWarnings(readObservedDataByDictionary(
  projectConfiguration = pc,
  spreadData = FALSE,
  dataClassType = "pkParameter"
))
numericValues <- suppressWarnings(readObservedDataByDictionary(
  projectConfiguration = pc,
  spreadData = FALSE,
  dataClassType = "numericValues"
))

assertOrStop(
  data.table::is.data.table(tpObserved),
  "Time-profile import did not return a data.table"
)
assertOrStop(
  data.table::is.data.table(pkObserved),
  "PK import did not return a data.table"
)
assertOrStop(
  data.table::is.data.table(numericValues),
  "NumericValues import did not return a data.table"
)

assertOrStop(
  nrow(tpObserved) == 4,
  "Time-profile import should return 4 filtered rows"
)
assertOrStop(nrow(pkObserved) == 4, "PK import should return 4 filtered rows")
assertOrStop(
  nrow(numericValues) == 3,
  "NumericValues import should return 3 rows"
)

expectedTpColumns <- c(
  unique(tpDictionary$TargetColumn),
  "xUnit",
  "dataClass",
  "dataType"
)
expectedPkColumns <- c(
  unique(pkDictionary$TargetColumn),
  "dataClass",
  "dataType"
)
expectedNumericColumns <- c("variableName", "value", "unit", "reference")

assertColumnsPresent(tpObserved, expectedTpColumns, "Time-profile import")
assertColumnsPresent(pkObserved, expectedPkColumns, "PK import")
assertColumnsPresent(
  numericValues,
  expectedNumericColumns,
  "NumericValues import"
)

tpGeneralColumns <- c(
  "studyId",
  "studyArm",
  "subjectId",
  "individualId",
  "group",
  "outputPathId",
  "xValues",
  "yValues",
  "yUnit",
  "lloq",
  "age",
  "weight",
  "height",
  "gender",
  "population",
  "species",
  "country",
  "dose",
  "route",
  "molecule",
  "organ",
  "compartment",
  "xUnit",
  "dataClass",
  "dataType"
)
pkGeneralColumns <- c(
  "studyId",
  "studyArm",
  "subjectId",
  "individualId",
  "group",
  "outputPathId",
  "pkParameter",
  "values",
  "unit",
  "age",
  "weight",
  "height",
  "gender",
  "population",
  "species",
  "country",
  "dose",
  "route",
  "molecule",
  "organ",
  "compartment",
  "dataClass",
  "dataType"
)

assertPopulatedColumns(tpObserved, tpGeneralColumns, "Time-profile import")
assertPopulatedColumns(pkObserved, pkGeneralColumns, "PK import")
assertPopulatedColumns(
  numericValues,
  expectedNumericColumns,
  "NumericValues import"
)

tpIndividualObserved <- tpObserved[
  tpObserved[["dataClass"]] == DATACLASS$tpIndividual,
]
tpAggregatedObserved <- tpObserved[
  tpObserved[["dataClass"]] == DATACLASS$tpAggregated,
]
pkIndividualObserved <- pkObserved[
  pkObserved[["dataClass"]] == DATACLASS$pkIndividual,
]
pkAggregatedObserved <- pkObserved[
  pkObserved[["dataClass"]] == DATACLASS$pkAggregated,
]

assertOrStop(
  nrow(tpIndividualObserved) == 2,
  "Time-profile individual fixture rows were not imported as expected"
)
assertOrStop(
  nrow(tpAggregatedObserved) == 2,
  "Time-profile aggregated fixture rows were not imported as expected"
)
assertOrStop(
  nrow(pkIndividualObserved) == 2,
  "PK individual fixture rows were not imported as expected"
)
assertOrStop(
  nrow(pkAggregatedObserved) == 2,
  "PK aggregated fixture rows were not imported as expected"
)

assertOrStop(
  identical(sort(unique(tpObserved[["studyId"]])), "1234"),
  "Time-profile DataFiles filters did not remove the excluded study rows"
)
assertOrStop(
  identical(sort(unique(pkObserved[["studyId"]])), "1234"),
  "PK DataFiles filters did not remove the excluded study rows"
)

assertOrStop(
  setequal(
    unique(tpObserved[["group"]]),
    c(
      "1234_ArmA_tpIndividual",
      "1234_ArmB_tpIndividual",
      "1234_ArmA_tpAggregated",
      "1234_ArmB_tpAggregated"
    )
  ),
  "Time-profile group mappings do not match the dictionary FilterValue definitions"
)
assertOrStop(
  setequal(
    unique(pkObserved[["group"]]),
    c(
      "1234_ArmA_pkIndividual",
      "1234_ArmB_pkIndividual",
      "1234_ArmA_pkAggregated",
      "1234_ArmB_pkAggregated"
    )
  ),
  "PK group mappings do not match the dictionary FilterValue definitions"
)

assertOrStop(
  setequal(
    unique(tpObserved[["population"]]),
    c("European_ICRP_2002", "Asian_Tanaka_1996")
  ),
  "Time-profile population filter rows were not both exercised"
)
assertOrStop(
  setequal(
    unique(pkObserved[["population"]]),
    c("European_ICRP_2002", "Asian_Tanaka_1996")
  ),
  "PK population filter rows were not both exercised"
)

assertOrStop(
  identical(sort(unique(tpObserved[["species"]])), "Human"),
  "Time-profile species FilterValue mapping did not produce the expected value"
)
assertOrStop(
  identical(sort(unique(pkObserved[["species"]])), "Human"),
  "PK species FilterValue mapping did not produce the expected value"
)
assertOrStop(
  setequal(unique(tpObserved[["route"]]), c("iv", "po")),
  "Time-profile route values were not imported from the dictionary source column"
)
assertOrStop(
  setequal(unique(pkObserved[["route"]]), c("iv", "po")),
  "PK route values were not imported from the dictionary source column"
)
assertOrStop(
  identical(sort(unique(tpObserved[["molecule"]])), "Plasma"),
  "Time-profile molecule values were not imported from the dictionary source column"
)
assertOrStop(
  identical(sort(unique(pkObserved[["molecule"]])), "Plasma"),
  "PK molecule values were not imported from the dictionary source column"
)
assertOrStop(
  identical(sort(unique(tpObserved[["organ"]])), "PeripheralVenousBlood"),
  "Time-profile organ values were not imported from the dictionary source column"
)
assertOrStop(
  identical(sort(unique(pkObserved[["organ"]])), "PeripheralVenousBlood"),
  "PK organ values were not imported from the dictionary source column"
)
assertOrStop(
  identical(sort(unique(tpObserved[["compartment"]])), "Plasma"),
  "Time-profile compartment values were not imported from the dictionary source column"
)
assertOrStop(
  identical(sort(unique(pkObserved[["compartment"]])), "Plasma"),
  "PK compartment values were not imported from the dictionary source column"
)

assertOrStop(
  countNonMissing(tpAggregatedObserved[["yMin"]]) == 2,
  "Time-profile aggregated yMin values were not imported for both aggregated rows"
)
assertOrStop(
  countNonMissing(tpAggregatedObserved[["yMax"]]) == 2,
  "Time-profile aggregated yMax values were not imported for both aggregated rows"
)
assertOrStop(
  countNonMissing(tpAggregatedObserved[["numberOfIndividuals"]]) == 2,
  "Time-profile aggregated numberOfIndividuals values were not imported for both aggregated rows"
)
assertOrStop(
  countNonMissing(tpAggregatedObserved[["nBelowLLOQ"]]) == 2,
  "Time-profile aggregated nBelowLLOQ values were not imported for both aggregated rows"
)
assertOrStop(
  countNonMissing(tpAggregatedObserved[["yErrorValues"]]) == 1,
  "Time-profile aggregated yErrorValues coverage does not match the fixture design"
)
assertOrStop(
  setequal(
    na.omit(stripOuterQuotes(tpAggregatedObserved[["yErrorType"]])),
    c("GeometricStdDev", "median|5th to 95th percentile")
  ),
  "Time-profile aggregated yErrorType values do not match the fixture definitions"
)

assertOrStop(
  countNonMissing(pkAggregatedObserved[["minValue"]]) == 2,
  "PK aggregated minValue values were not imported for both aggregated rows"
)
assertOrStop(
  countNonMissing(pkAggregatedObserved[["maxValue"]]) == 2,
  "PK aggregated maxValue values were not imported for both aggregated rows"
)
assertOrStop(
  countNonMissing(pkAggregatedObserved[["numberOfIndividuals"]]) == 2,
  "PK aggregated numberOfIndividuals values were not imported for both aggregated rows"
)
assertOrStop(
  countNonMissing(pkAggregatedObserved[["errorValues"]]) == 1,
  "PK aggregated errorValues coverage does not match the fixture design"
)
assertOrStop(
  setequal(
    na.omit(stripOuterQuotes(pkAggregatedObserved[["errorType"]])),
    c("GeometricStdDev", "median|5th to 95th percentile")
  ),
  "PK aggregated errorType values do not match the fixture definitions"
)

tpFilteredIndividual <- suppressWarnings(readObservedDataByDictionary(
  projectConfiguration = pc,
  spreadData = FALSE,
  dataClassType = "timeprofile",
  fileIds = "tp_individual"
))
tpFilteredAggregated <- suppressWarnings(readObservedDataByDictionary(
  projectConfiguration = pc,
  spreadData = FALSE,
  dataClassType = "timeprofile",
  fileIds = "tp_aggregated"
))
pkFilteredIndividual <- suppressWarnings(readObservedDataByDictionary(
  projectConfiguration = pc,
  spreadData = FALSE,
  dataClassType = "pkParameter",
  fileIds = "pk_individual"
))
pkFilteredAggregated <- suppressWarnings(readObservedDataByDictionary(
  projectConfiguration = pc,
  spreadData = FALSE,
  dataClassType = "pkParameter",
  fileIds = "pk_aggregated"
))

assertOrStop(
  nrow(tpFilteredIndividual) == 2,
  "fileIds filtering for tp_individual should return 2 rows"
)
assertOrStop(
  nrow(tpFilteredAggregated) == 2,
  "fileIds filtering for tp_aggregated should return 2 rows"
)
assertOrStop(
  nrow(pkFilteredIndividual) == 2,
  "fileIds filtering for pk_individual should return 2 rows"
)
assertOrStop(
  nrow(pkFilteredAggregated) == 2,
  "fileIds filtering for pk_aggregated should return 2 rows"
)
assertOrStop(
  identical(
    unique(tpFilteredIndividual[["dataClass"]]),
    DATACLASS$tpIndividual
  ),
  "fileIds filtering for tp_individual returned the wrong data class"
)
assertOrStop(
  identical(
    unique(tpFilteredAggregated[["dataClass"]]),
    DATACLASS$tpAggregated
  ),
  "fileIds filtering for tp_aggregated returned the wrong data class"
)
assertOrStop(
  identical(
    unique(pkFilteredIndividual[["dataClass"]]),
    DATACLASS$pkIndividual
  ),
  "fileIds filtering for pk_individual returned the wrong data class"
)
assertOrStop(
  identical(
    unique(pkFilteredAggregated[["dataClass"]]),
    DATACLASS$pkAggregated
  ),
  "fileIds filtering for pk_aggregated returned the wrong data class"
)

invalidFileIdError <- tryCatch(
  {
    readObservedDataByDictionary(
      projectConfiguration = pc,
      spreadData = FALSE,
      dataClassType = "timeprofile",
      fileIds = "invalid_file_id"
    )
    FALSE
  },
  error = function(e) {
    TRUE
  }
)
assertOrStop(
  isTRUE(invalidFileIdError),
  "Invalid fileIds input should trigger an error"
)

assertOrStop(
  identical(
    sort(numericValues[["variableName"]]),
    sort(c("Dose", "InfusionDuration", "LowerLimit"))
  ),
  "NumericValues variable names do not match the fixture rows"
)
assertOrStop(
  length(unique(numericValues[["variableName"]])) == nrow(numericValues),
  "NumericValues variable names should be unique"
)
assertOrStop(
  identical(
    numericValues[numericValues[["variableName"]] == "Dose", ][["value"]],
    100
  ),
  "NumericValues did not return the expected Dose value"
)
assertOrStop(
  identical(
    numericValues[numericValues[["variableName"]] == "InfusionDuration", ][[
      "unit"
    ]],
    "h"
  ),
  "NumericValues did not return the expected InfusionDuration unit"
)
assertOrStop(
  identical(
    numericValues[numericValues[["variableName"]] == "LowerLimit", ][[
      "reference"
    ]],
    "Bioanalytical report"
  ),
  "NumericValues did not return the expected LowerLimit reference"
)

individualBiometricsRowsBefore <- safeSheetRows(
  pc[["individualsFile"]],
  "IndividualBiometrics"
)
suppressWarnings(readObservedDataByDictionary(
  projectConfiguration = pc,
  spreadData = TRUE,
  dataClassType = "timeprofile"
))
individualBiometricsRowsAfter <- safeSheetRows(
  pc[["individualsFile"]],
  "IndividualBiometrics"
)

assertOrStop(
  individualBiometricsRowsAfter > individualBiometricsRowsBefore,
  "spreadData = TRUE did not populate Individuals.xlsx / IndividualBiometrics"
)

reportLines <- c(
  "# UC-10 Data Dictionary Operations",
  "",
  "## Summary",
  "",
  "This scenario validates dictionary-driven observed-data import for time profiles and PK parameters in both individual and aggregated forms, plus NumericValues. It uses a repo-local workbook fixture generated from the installed package template and verifies DataFiles filtering, dictionary Filter/FilterValue mappings, and spreadData propagation into Individuals.xlsx.",
  "",
  "## Assertions",
  "",
  "- Fixture workbook sheets present: DataFiles, tpDictionary, pkDictionary, NumericValues.",
  paste0("- DataFiles rows configured: ", nrow(dataFilesConfig), "."),
  paste0(
    "- Dictionary rows configured: tpDictionary=",
    nrow(tpDictionary),
    ", pkDictionary=",
    nrow(pkDictionary),
    ", NumericValues=",
    nrow(numericValuesConfig),
    "."
  ),
  paste0(
    "- Time-profile import returned ",
    nrow(tpObserved),
    " rows across data classes: ",
    paste(sort(unique(tpObserved[["dataClass"]])), collapse = ", "),
    "."
  ),
  paste0(
    "- PK import returned ",
    nrow(pkObserved),
    " rows across data classes: ",
    paste(sort(unique(pkObserved[["dataClass"]])), collapse = ", "),
    "."
  ),
  paste0(
    "- NumericValues import returned ",
    nrow(numericValues),
    " rows: ",
    paste(numericValues[["variableName"]], collapse = ", "),
    "."
  ),
  "- DataFiles filters removed the excluded source rows from TP and PK imports (only studyId 1234 remains after import).",
  "- Dictionary Filter/FilterValue rows populated individualId, group, population, species, and metadata columns for TP and PK imports.",
  "- Aggregated TP rows imported yErrorType/yErrorValues/yMin/yMax/numberOfIndividuals/nBelowLLOQ from source fixtures rather than deriving them in the UC.",
  "- Aggregated PK rows imported errorType/errorValues/minValue/maxValue/numberOfIndividuals from source fixtures rather than deriving them in the UC.",
  "- fileIds filtering isolated TP and PK individual versus aggregated fixture rows.",
  "- Invalid fileIds triggered the expected import error.",
  paste0(
    "- spreadData = TRUE expanded Individuals.xlsx / IndividualBiometrics from ",
    individualBiometricsRowsBefore,
    " to ",
    individualBiometricsRowsAfter,
    " rows."
  ),
  "",
  "## Result files",
  "- ReportInputs/DataImportMap_UC10.xlsx - dedicated UC-10 import configuration workbook",
  "- ReportInputs/dataFiles/tp_individual.csv - individual time-profile source data",
  "- ReportInputs/dataFiles/tp_aggregated.csv - aggregated time-profile source data",
  "- ReportInputs/dataFiles/pk_individual.csv - individual PK source data",
  "- ReportInputs/dataFiles/pk_aggregated.csv - aggregated PK source data",
  "- ReportInputs/refresh-uc10-data-import-fixtures.R - fixture refresh script for the UC-10 import matrix",
  ""
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
