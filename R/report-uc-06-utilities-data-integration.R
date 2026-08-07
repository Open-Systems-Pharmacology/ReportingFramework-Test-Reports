#' @title report-uc-06-utilities-data-integration
#' @description
#' Integration scenario for utilities-data import and transformation workflow.

rm(list = ls())
pkgload::load_all("../OSPSuite.ReportingFramework", quiet = TRUE)

reportFolder <- file.path(
    "tests",
    "Reports",
    "UC-06-Utilities-Data-Integration"
)
projectDir <- tempfile(pattern = "uc06_util_data_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

assertOrStop <- function(condition, message) {
    if (!isTRUE(condition)) {
        stop(message, call. = FALSE)
    }
    invisible(NULL)
}

makeUtilitiesDataProjectConfiguration <- function(projectDir) {
    dir.create(projectDir, recursive = TRUE, showWarnings = FALSE)

    tutorialDir <- system.file(
        "extdata",
        "Tutorial",
        package = "ospsuite.reportingframework"
    )

    filesToCopy <- c(
        "DataImportConfiguration.xlsx",
        "Individuals.xlsx",
        "Plots.xlsx",
        "Scenarios.xlsx"
    )

    file.copy(
        from = file.path(tutorialDir, filesToCopy),
        to = file.path(projectDir, filesToCopy),
        overwrite = TRUE
    )

    dataDir <- file.path(projectDir, "Data")
    dir.create(dataDir, recursive = TRUE, showWarnings = FALSE)
    dataFiles <- c(
        "timeprofiles_study1234_iv.csv",
        "timeprofiles_study1234_po.csv"
    )
    file.copy(
        from = file.path(tutorialDir, dataFiles),
        to = file.path(dataDir, dataFiles),
        overwrite = TRUE
    )

    for (rootDir in unique(c(
        tempdir(),
        dirname(tempdir()),
        dirname(dirname(tempdir())),
        projectDir
    ))) {
        tempDataDir <- file.path(rootDir, "Data")
        dir.create(tempDataDir, recursive = TRUE, showWarnings = FALSE)
        srcFiles <- file.path(dataDir, dataFiles)
        dstFiles <- file.path(tempDataDir, dataFiles)
        if (
            !all(
                normalizePath(srcFiles, winslash = "/") ==
                    normalizePath(dstFiles, winslash = "/", mustWork = FALSE)
            )
        ) {
            file.copy(
                from = srcFiles,
                to = dstFiles,
                overwrite = TRUE
            )
        }
    }

    list(
        dataImporterConfigurationFile = file.path(
            projectDir,
            "DataImportConfiguration.xlsx"
        ),
        projectConfigurationDirPath = tempdir(),
        individualsFile = file.path(projectDir, "Individuals.xlsx"),
        scenariosFile = file.path(projectDir, "Scenarios.xlsx"),
        addOns = list(reportsFile = file.path(projectDir, "Plots.xlsx"))
    )
}

pc <- makeUtilitiesDataProjectConfiguration(projectDir)

dataObserved <- suppressWarnings(readObservedDataByDictionary(
    projectConfiguration = pc,
    spreadData = FALSE
))

assertOrStop(
    data.table::is.data.table(dataObserved),
    "Observed data is not a data.table"
)
assertOrStop(
    nrow(dataObserved) == 396,
    "Observed data row count is not the expected 396"
)

wb <- openxlsx::loadWorkbook(pc$dataImporterConfigurationFile)
dataFilesConfig <- xlsxReadData(
    wb = wb,
    sheetName = "DataFiles",
    skipDescriptionRow = TRUE
)
fileIds <- unique(dataFilesConfig$fileIdentifier)
assertOrStop(
    length(fileIds) >= 2,
    "Expected at least two file identifiers in DataFiles sheet"
)

filteredData <- suppressWarnings(readObservedDataByDictionary(
    projectConfiguration = pc,
    spreadData = FALSE,
    fileIds = fileIds[1]
))
assertOrStop(
    nrow(filteredData) < nrow(dataObserved),
    "Filtering by fileId did not reduce rows"
)

invalidFileIdError <- tryCatch(
    {
        readObservedDataByDictionary(
            projectConfiguration = pc,
            fileIds = "invalid_file_id"
        )
        FALSE
    },
    error = function(e) {
        grepl("subset", e$message, fixed = TRUE)
    }
)
assertOrStop(
    isTRUE(invalidFileIdError),
    "Invalid fileId did not trigger expected subset error"
)

identifierColumns <- getColumnsForColumnType(
    dt = dataObserved,
    columnTypes = "identifier"
)
assertOrStop(
    all(
        c("studyId", "subjectId", "individualId", "group", "outputPathId") %in%
            identifierColumns
    ),
    "Identifier columns are missing expected names"
)

dtWithCommas <- data.table::data.table(
    idA = c("a,b", "c,d"),
    idB = c("x,y", "1,2"),
    value = c(1, 2)
)
convertedIds <- suppressWarnings(convertIdentifierColumns(
    dtWithCommas,
    c("idA", "idB")
))
assertOrStop(
    convertedIds$idA[1] == "a_b",
    "convertIdentifierColumns did not replace comma in idA"
)
assertOrStop(
    convertedIds$idB[1] == "x_y",
    "convertIdentifierColumns did not replace comma in idB"
)

individualGroups <- getIndividualDataGroups(
    dataObserved = dataObserved,
    groups = NULL,
    minN = 2
)
assertOrStop(
    length(individualGroups) > 0,
    "No eligible individual groups returned by getIndividualDataGroups"
)
assertOrStop(
    all(individualGroups %in% unique(dataObserved$group)),
    "Returned groups are not part of observed data"
)

reportLines <- c(
    "# UC-06 Utilities-data integration",
    "",
    "## Summary",
    "",
    "This scenario validates observed-data import and key utilities-data helpers with tutorial-backed configuration files.",
    "",
    "## Assertions",
    "",
    paste0(
        "- readObservedDataByDictionary returned ",
        nrow(dataObserved),
        " rows."
    ),
    "- fileIds filtering reduced row count.",
    "- Invalid fileId triggers expected subset error.",
    "- getColumnsForColumnType returned required identifier columns.",
    "- convertIdentifierColumns replaced commas with underscores.",
    "- getIndividualDataGroups returned valid groups for aggregation/twin workflows.",
    "",
    "## Diagnostic values",
    "",
    paste0("- Distinct file identifiers: ", paste(fileIds, collapse = ", ")),
    paste0(
        "- Eligible groups (minN=2): ",
        paste(individualGroups, collapse = ", ")
    )
)

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
