rm(list = ls())

library(data.table)
library(openxlsx)
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

fixtureDir <- reportInputsPath("UC13_DataImport")
dir.create(fixtureDir, recursive = TRUE, showWarnings = FALSE)

replaceSheetTable <- function(wb, sheetName, dataTable) {
  if (sheetName %in% names(wb)) {
    removeWorksheet(wb, sheetName)
  }

  addWorksheet(wb, sheetName)
  writeData(
    wb,
    sheet = sheetName,
    x = as.list(names(dataTable)),
    startRow = 1,
    colNames = FALSE
  )
  writeData(
    wb,
    sheet = sheetName,
    x = as.list(rep("", ncol(dataTable))),
    startRow = 2,
    colNames = FALSE
  )
  writeData(
    wb,
    sheet = sheetName,
    x = dataTable,
    startRow = 3,
    colNames = FALSE
  )
}

tpIndividual <- data.table(
  STUD = c("1234", "1234", "9999"),
  GRPNAME = c("Arm A", "Arm B", "Dropped Arm"),
  ARM = c("ArmA", "ArmB", "ArmDrop"),
  SID = c("SUBJ01", "SUBJ02", "SUBJ03"),
  MOLECULE = c("Plasma", "Plasma", "Plasma"),
  TIME = c(1, 2, 4),
  DV = c(10.5, 12.0, 99.0),
  DVUNIT = c("mg/L", "mg/L", "mg/L"),
  LLOQ = c(0.1, 0.1, 0.1),
  DV_GSD = c(NA_real_, NA_real_, NA_real_),
  DV_MIN = c(NA_real_, NA_real_, NA_real_),
  DV_MAX = c(NA_real_, NA_real_, NA_real_),
  NIND = c(NA_real_, NA_real_, NA_real_),
  NBLQ = c(0, 1, 0),
  AGE = c(35, 42, 50),
  WGHT0 = c(72, 65, 80),
  HGHT0 = c(178, 168, 182),
  SEX = c("Male", "Female", "Female"),
  RACENAME = c("White", "Asian", "White"),
  COUNTRY = c("DE", "JP", "US"),
  DOSE = c(100, 150, 999),
  ROUTE = c("iv", "po", "po"),
  ORGAN = c(
    "PeripheralVenousBlood",
    "PeripheralVenousBlood",
    "PeripheralVenousBlood"
  ),
  COMP = c("Plasma", "Plasma", "Plasma"),
  CLASS = c("tpIndividual", "tpIndividual", "tpIndividual"),
  INCLUDE = c(1, 1, 0),
  ERRTYPE = c("", "", "")
)

tpAggregated <- data.table(
  STUD = c("1234", "1234", "8888"),
  GRPNAME = c("Arm A Summary", "Arm B Summary", "Dropped Summary"),
  ARM = c("ArmA", "ArmB", "ArmDrop"),
  SID = c("AGG01", "AGG02", "AGG03"),
  MOLECULE = c("Plasma", "Plasma", "Plasma"),
  TIME = c(1, 2, 4),
  DV = c(11.2, 8.4, 55.0),
  DVUNIT = c("mg/L", "mg/L", "mg/L"),
  LLOQ = c(0.1, 0.1, 0.1),
  DV_GSD = c(1.25, NA_real_, 1.10),
  DV_MIN = c(9.8, 7.0, 50.0),
  DV_MAX = c(13.6, 9.4, 60.0),
  NIND = c(8, 6, 5),
  NBLQ = c(0, 2, 0),
  AGE = c(35, 42, 50),
  WGHT0 = c(72, 65, 80),
  HGHT0 = c(178, 168, 182),
  SEX = c("Male", "Female", "Female"),
  RACENAME = c("White", "Asian", "White"),
  COUNTRY = c("DE", "JP", "US"),
  DOSE = c(100, 150, 999),
  ROUTE = c("iv", "po", "po"),
  ORGAN = c(
    "PeripheralVenousBlood",
    "PeripheralVenousBlood",
    "PeripheralVenousBlood"
  ),
  COMP = c("Plasma", "Plasma", "Plasma"),
  CLASS = c("tpAggregated", "tpAggregated", "tpAggregated"),
  INCLUDE = c(1, 1, 0),
  ERRTYPE = c(
    "GeometricStdDev",
    "median|5th to 95th percentile",
    "ArithmeticStdDev"
  )
)

pkIndividual <- data.table(
  STUD = c("1234", "1234", "9999"),
  GRPNAME = c("Arm A", "Arm B", "Dropped Arm"),
  ARM = c("ArmA", "ArmB", "ArmDrop"),
  SID = c("SUBJ01", "SUBJ02", "SUBJ03"),
  MOLECULE = c("Plasma", "Plasma", "Plasma"),
  PARAM = c("AUC_tEnd", "C_max", "AUC_tEnd"),
  DV = c(22.5, 3.2, 999.0),
  DVUNIT = c("mg*h/L", "mg/L", "mg*h/L"),
  DV_GSD = c(NA_real_, NA_real_, NA_real_),
  DV_MIN = c(NA_real_, NA_real_, NA_real_),
  DV_MAX = c(NA_real_, NA_real_, NA_real_),
  NIND = c(NA_real_, NA_real_, NA_real_),
  AGE = c(35, 42, 50),
  WGHT0 = c(72, 65, 80),
  HGHT0 = c(178, 168, 182),
  SEX = c("Male", "Female", "Female"),
  RACENAME = c("White", "Asian", "White"),
  COUNTRY = c("DE", "JP", "US"),
  DOSE = c(100, 150, 999),
  ROUTE = c("iv", "po", "po"),
  ORGAN = c(
    "PeripheralVenousBlood",
    "PeripheralVenousBlood",
    "PeripheralVenousBlood"
  ),
  COMP = c("Plasma", "Plasma", "Plasma"),
  CLASS = c("pkIndividual", "pkIndividual", "pkIndividual"),
  INCLUDE = c(1, 1, 0),
  ERRTYPE = c("", "", "")
)

pkAggregated <- data.table(
  STUD = c("1234", "1234", "8888"),
  GRPNAME = c("Arm A Summary", "Arm B Summary", "Dropped Summary"),
  ARM = c("ArmA", "ArmB", "ArmDrop"),
  SID = c("AGG01", "AGG02", "AGG03"),
  MOLECULE = c("Plasma", "Plasma", "Plasma"),
  PARAM = c("AUC_tEnd", "C_max", "AUC_tEnd"),
  DV = c(24.0, 3.5, 777.0),
  DVUNIT = c("mg*h/L", "mg/L", "mg*h/L"),
  DV_GSD = c(1.20, NA_real_, 1.40),
  DV_MIN = c(20.0, 2.9, 700.0),
  DV_MAX = c(28.0, 4.1, 850.0),
  NIND = c(8, 6, 5),
  AGE = c(35, 42, 50),
  WGHT0 = c(72, 65, 80),
  HGHT0 = c(178, 168, 182),
  SEX = c("Male", "Female", "Female"),
  RACENAME = c("White", "Asian", "White"),
  COUNTRY = c("DE", "JP", "US"),
  DOSE = c(100, 150, 999),
  ROUTE = c("iv", "po", "po"),
  ORGAN = c(
    "PeripheralVenousBlood",
    "PeripheralVenousBlood",
    "PeripheralVenousBlood"
  ),
  COMP = c("Plasma", "Plasma", "Plasma"),
  CLASS = c("pkAggregated", "pkAggregated", "pkAggregated"),
  INCLUDE = c(1, 1, 0),
  ERRTYPE = c(
    "GeometricStdDev",
    "median|5th to 95th percentile",
    "ArithmeticStdDev"
  )
)

fwrite(tpIndividual, file.path(fixtureDir, "tp_individual.csv"))
fwrite(tpAggregated, file.path(fixtureDir, "tp_aggregated.csv"))
fwrite(pkIndividual, file.path(fixtureDir, "pk_individual.csv"))
fwrite(pkAggregated, file.path(fixtureDir, "pk_aggregated.csv"))

workbookPath <- file.path(fixtureDir, "DataImportConfiguration.xlsx")
file.copy(
  from = system.file(
    "templates",
    "DataImportConfiguration.xlsx",
    package = "ospsuite.reportingframework",
    mustWork = TRUE
  ),
  to = workbookPath,
  overwrite = TRUE
)

wb <- loadWorkbook(workbookPath)

dataFiles <- data.table(
  FileIdentifier = c(
    "tp_individual",
    "tp_aggregated",
    "pk_individual",
    "pk_aggregated",
    "numeric_values"
  ),
  DataFile = c(
    "../../Data/tp_individual.csv",
    "../../Data/tp_aggregated.csv",
    "../../Data/pk_individual.csv",
    "../../Data/pk_aggregated.csv",
    ""
  ),
  Dictionary = c(
    "tpDictionary",
    "tpDictionary",
    "pkDictionary",
    "pkDictionary",
    "NumericValues"
  ),
  DataFilter = c(
    "INCLUDE == 1",
    "INCLUDE == 1",
    "INCLUDE == 1",
    "INCLUDE == 1",
    ""
  ),
  DataClass = c(
    DATACLASS$tpIndividual,
    DATACLASS$tpAggregated,
    DATACLASS$pkIndividual,
    DATACLASS$pkAggregated,
    DATACLASS$numericValues
  )
)

tpDictionary <- xlsxReadData(
  wb = workbookPath,
  sheetName = "tpDictionary",
  skipDescriptionRow = TRUE,
  emptyAsNA = FALSE,
  convertHeaders = FALSE
)
tpDictionary[
  TargetColumn == "individualId",
  `:=`(
    Filter = "TRUE",
    FilterValue = 'paste(STUD, SID, sep = "_")'
  )
]
tpDictionary[
  TargetColumn == "group",
  `:=`(
    Filter = "TRUE",
    FilterValue = 'paste(STUD, ARM, CLASS, sep = "_")'
  )
]
tpDictionary[
  TargetColumn == "yErrorType",
  `:=`(
    SourceColumn = "",
    Filter = 'ERRTYPE != ""',
    FilterValue = 'paste0("\\\"", ERRTYPE, "\\\"")'
  )
]
tpDictionary[TargetColumn == "yMin", SourceColumn := "DV_MIN"]
tpDictionary[TargetColumn == "yMax", SourceColumn := "DV_MAX"]
tpDictionary[TargetColumn == "numberOfIndividuals", SourceColumn := "NIND"]
tpDictionary[TargetColumn == "nBelowLLOQ", SourceColumn := "NBLQ"]
populationRows <- which(tpDictionary$TargetColumn == "population")
tpDictionary[
  populationRows[[1]],
  `:=`(
    Filter = 'RACENAME == "White"',
    FilterValue = '"European_ICRP_2002"'
  )
]
tpDictionary[
  populationRows[[2]],
  `:=`(
    Filter = 'RACENAME == "Asian"',
    FilterValue = '"Asian_Tanaka_1996"'
  )
]
tpDictionary[
  TargetColumn == "species",
  `:=`(
    Filter = "TRUE",
    FilterValue = '"Human"'
  )
]
tpDictionary[TargetColumn == "dose", SourceColumn := "DOSE"]
tpDictionary[TargetColumn == "route", SourceColumn := "ROUTE"]
tpDictionary[TargetColumn == "molecule", SourceColumn := "MOLECULE"]
tpDictionary[TargetColumn == "organ", SourceColumn := "ORGAN"]
tpDictionary[TargetColumn == "compartment", SourceColumn := "COMP"]

pkDictionary <- xlsxReadData(
  wb = workbookPath,
  sheetName = "pkDictionary",
  skipDescriptionRow = TRUE,
  emptyAsNA = FALSE,
  convertHeaders = FALSE
)
pkDictionary[
  TargetColumn == "individualId",
  `:=`(
    Filter = "TRUE",
    FilterValue = 'paste(STUD, SID, sep = "_")'
  )
]
pkDictionary[
  TargetColumn == "group",
  `:=`(
    Filter = "TRUE",
    FilterValue = 'paste(STUD, ARM, CLASS, sep = "_")'
  )
]
pkDictionary[
  TargetColumn == "pkParameter",
  `:=`(
    Filter = "TRUE",
    FilterValue = "PARAM"
  )
]
pkDictionary[
  TargetColumn == "errorType",
  `:=`(
    SourceColumn = "",
    Filter = 'ERRTYPE != ""',
    FilterValue = 'paste0("\\\"", ERRTYPE, "\\\"")'
  )
]
pkDictionary[TargetColumn == "minValue", SourceColumn := "DV_MIN"]
pkDictionary[TargetColumn == "maxValue", SourceColumn := "DV_MAX"]
pkDictionary[TargetColumn == "numberOfIndividuals", SourceColumn := "NIND"]
populationRows <- which(pkDictionary$TargetColumn == "population")
pkDictionary[
  populationRows[[1]],
  `:=`(
    Filter = 'RACENAME == "White"',
    FilterValue = '"European_ICRP_2002"'
  )
]
pkDictionary[
  populationRows[[2]],
  `:=`(
    Filter = 'RACENAME == "Asian"',
    FilterValue = '"Asian_Tanaka_1996"'
  )
]
pkDictionary[
  TargetColumn == "species",
  `:=`(
    Filter = "TRUE",
    FilterValue = '"Human"'
  )
]
pkDictionary[TargetColumn == "dose", SourceColumn := "DOSE"]
pkDictionary[TargetColumn == "route", SourceColumn := "ROUTE"]
pkDictionary[TargetColumn == "molecule", SourceColumn := "MOLECULE"]
pkDictionary[TargetColumn == "organ", SourceColumn := "ORGAN"]
pkDictionary[TargetColumn == "compartment", SourceColumn := "COMP"]

numericValues <- data.table(
  VariableName = c("Dose", "InfusionDuration", "LowerLimit"),
  Value = c(100, 1.5, 0.05),
  Unit = c("mg", "h", "mg/L"),
  Reference = c("Study 1234", "Protocol", "Bioanalytical report")
)

replaceSheetTable(wb, "DataFiles", dataFiles)
replaceSheetTable(wb, "tpDictionary", tpDictionary)
replaceSheetTable(wb, "pkDictionary", pkDictionary)
replaceSheetTable(wb, "NumericValues", numericValues)
saveWorkbook(wb, workbookPath, overwrite = TRUE)

cat(
  paste(
    "Refreshed UC-13 data-import fixtures:",
    paste("- Workbook:", workbookPath),
    paste("- tp_individual rows:", nrow(tpIndividual)),
    paste("- tp_aggregated rows:", nrow(tpAggregated)),
    paste("- pk_individual rows:", nrow(pkIndividual)),
    paste("- pk_aggregated rows:", nrow(pkAggregated)),
    paste("- numeric values:", nrow(numericValues)),
    sep = "\n"
  ),
  "\n"
)
