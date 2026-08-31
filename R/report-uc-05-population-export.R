#' @title report-uc-05-population-export
#' @description
#' Integration scenario for UC-05 population export.

rm(list = ls())
pkgload::load_all("../OSPSuite.ReportingFramework", quiet = TRUE)

reportFolder <- file.path("tests", "Reports", "UC-05-Population-Export")
projectDir <- tempfile(pattern = "uc05_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

assertOrStop <- function(condition, message) {
    if (!isTRUE(condition)) {
        stop(message, call. = FALSE)
    }
    invisible(NULL)
}

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

initProject(projectDirectory = projectDir, overwrite = TRUE)

configurationDir <- file.path(projectDir, "Scripts", "ReportingFramework")
projectConfigPath <- file.path(configurationDir, "ProjectConfiguration.xlsx")

pc <- createProjectConfiguration(
    path = projectConfigPath,
    ignoreVersionCheck = FALSE
)

modelFile <- "Aciclovir.pkml"
sourceModelPath <- file.path("Models", modelFile)
targetModelPath <- fs::path_abs(modelFile, start = pc$modelFolder)

assertOrStop(
    file.exists(sourceModelPath),
    paste0("Source model file not found: ", sourceModelPath)
)
if (!file.exists(targetModelPath)) {
    ignore <- file.copy(sourceModelPath, targetModelPath, overwrite = TRUE)
}
assertOrStop(
    file.exists(targetModelPath),
    paste0("Model file not found: ", targetModelPath)
)

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

individualsFile <- file.path(configurationDir, "Individuals.xlsx")
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
