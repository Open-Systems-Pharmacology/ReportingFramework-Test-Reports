#' @title report-uc-05-population-export
#' @description
#' Integration scenario for UC-05 population export.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportFolder <- file.path("tests", "Reports", "UC-05-Population-Export")
projectDir <- tempfile(pattern = "uc05_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

pc <- setupProject(projectDir)

assertHasCorePopulationColumns <- function(dt, context) {
    requiredColumns <- c("IndividualId", "Gender", "Population")
    assertOrStop(
        all(requiredColumns %in% names(dt)),
        paste0(
            context,
            " is missing one of expected columns: ",
            paste(requiredColumns, collapse = ", ")
        )
    )

    hasAge <- any(c("Age", "Organism|Age") %in% names(dt))
    assertOrStop(
        hasAge,
        paste0(context, " is missing expected age column (Age or Organism|Age)")
    )
    invisible(NULL)
}

modelFile <- "Aciclovir.pkml"
copyModelFile(pc, modelFile)

randomPopulationName <- "TestPopulation_noOnto"
exportRandomPopulations(
    projectConfiguration = pc,
    populationNames = randomPopulationName,
    overwrite = TRUE
)

randomPopulationFile <- file.path(
    pc$populationsFolder,
    paste0(randomPopulationName, ".csv")
)
assertOrStop(
    file.exists(randomPopulationFile),
    "exportRandomPopulations() did not create the expected population CSV"
)

randomPopulationData <- data.table::fread(randomPopulationFile)
assertOrStop(
    nrow(randomPopulationData) > 0,
    "Random population CSV is empty"
)
assertHasCorePopulationColumns(
    dt = randomPopulationData,
    context = "Random population CSV"
)

individualsFile <- file.path(dirname(pc$scenariosFile), "Individuals.xlsx")
wbIndividuals <- openxlsx::loadWorkbook(individualsFile)

virtualTwinPopulationName <- "VT_Indiv1"
virtualTwinConfig <- data.table::data.table(
    populationName = virtualTwinPopulationName,
    dataGroups = "",
    individualId = "Indiv1",
    modelParameterSheets = "",
    applicationProtocol = ""
)

if ("VirtualTwinPopulation" %in% wbIndividuals$sheet_names) {
    xlsxWriteData(
        wb = wbIndividuals,
        sheetName = "VirtualTwinPopulation",
        dt = virtualTwinConfig
    )
} else {
    xlsxAddSheet(
        wb = wbIndividuals,
        sheetName = "VirtualTwinPopulation",
        dt = virtualTwinConfig
    )
}
openxlsx::saveWorkbook(wbIndividuals, file = individualsFile, overwrite = TRUE)

exportVirtualTwinPopulations(
    projectConfiguration = pc,
    modelFile = modelFile,
    populationNames = virtualTwinPopulationName,
    overwrite = TRUE
)

virtualTwinPopulationFile <- file.path(
    pc$populationsFolder,
    paste0(virtualTwinPopulationName, ".csv")
)
assertOrStop(
    file.exists(virtualTwinPopulationFile),
    "exportVirtualTwinPopulations() did not create the expected virtual twin CSV"
)

virtualTwinData <- data.table::fread(virtualTwinPopulationFile)
assertOrStop(
    nrow(virtualTwinData) > 0,
    "Virtual twin population CSV is empty"
)
assertHasCorePopulationColumns(
    dt = virtualTwinData,
    context = "Virtual twin population CSV"
)

reportLines <- c(
    "# UC-05 Population export",
    "",
    "## Summary",
    "",
    "This scenario validates random and virtual twin population exports to CSV files.",
    "",
    "## Assertions",
    "",
    paste0("- Random population exported: ", basename(randomPopulationFile)),
    paste0(
        "- Virtual twin population exported: ",
        basename(virtualTwinPopulationFile)
    ),
    "- Both population CSV files are non-empty.",
    "- Both CSV files contain expected columns: IndividualId, Gender, Population, and an age column.",
    "",
    "## Exported population CSV files",
    "",
    paste0("- ", basename(randomPopulationFile)),
    paste0("- ", basename(virtualTwinPopulationFile))
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
