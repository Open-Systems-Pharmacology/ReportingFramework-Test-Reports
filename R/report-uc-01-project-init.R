#' @title report-uc-01-project-init
#' @description
#' Integration scenario for UC-01 full project initialization round-trip.

rm(list = ls())
pkgload::load_all("../OSPSuite.ReportingFramework", quiet = TRUE)

reportFolder <- file.path("tests", "Reports", "UC-01-Project-Initialization")
originalProjectDir <- file.path(reportFolder, "project-original")
restoredProjectDir <- file.path(reportFolder, "project-restored")

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

assertOrStop <- function(condition, message) {
    if (!isTRUE(condition)) {
        stop(message, call. = FALSE)
    }
    invisible(NULL)
}

normalizeAddOnPaths <- function(projectConfiguration) {
    # Compare add-on path semantics relative to the configuration folder.
    relativePaths <- vapply(
        projectConfiguration$addOns,
        function(addOnPath) {
            fs::path_rel(
                addOnPath,
                start = projectConfiguration$configurationsFolder
            )
        },
        FUN.VALUE = character(1)
    )

    sort(relativePaths)
}

initProject(projectDirectory = originalProjectDir, overwrite = TRUE)

originalConfigurationDir <- file.path(
    originalProjectDir,
    "Scripts",
    "ReportingFramework"
)
originalPcPath <- file.path(
    originalConfigurationDir,
    "ProjectConfiguration.xlsx"
)
originalJsonPath <- file.path(
    originalConfigurationDir,
    "ProjectConfiguration.json"
)

assertOrStop(
    file.exists(originalPcPath),
    "initProject() did not create ProjectConfiguration.xlsx"
)
assertOrStop(
    file.exists(originalJsonPath),
    "initProject() did not create ProjectConfiguration.json"
)

pcOriginal <- createProjectConfiguration(
    path = originalPcPath,
    ignoreVersionCheck = FALSE
)
versionOriginal <- pcOriginal$ospsuiteReportingFrameworkVersion
addOnsOriginal <- normalizeAddOnPaths(pcOriginal)

assertOrStop(
    !is.null(versionOriginal) && nzchar(versionOriginal),
    "RF version is missing after createProjectConfiguration()"
)

snapshotData <- snapshotProjectConfigurationRF(
    pcOriginal,
    outputDir = originalConfigurationDir
)
requiredSnapshotKeys <- c(
    "projectConfiguration",
    "projectConfigurationAddons",
    "pKParameterFile",
    "reportsFile"
)

missingSnapshotKeys <- setdiff(requiredSnapshotKeys, names(snapshotData))
assertOrStop(
    length(missingSnapshotKeys) == 0,
    paste0(
        "Snapshot is missing required keys: ",
        paste(missingSnapshotKeys, collapse = ", ")
    )
)

restoredConfigurationDir <- file.path(
    restoredProjectDir,
    "Scripts",
    "ReportingFramework"
)
dir.create(restoredConfigurationDir, recursive = TRUE, showWarnings = FALSE)

pcRestored <- restoreProjectConfigurationRF(
    jsonPath = originalJsonPath,
    outputDir = restoredConfigurationDir
)

restoredPcPath <- file.path(
    restoredConfigurationDir,
    "ProjectConfiguration.xlsx"
)
assertOrStop(
    file.exists(restoredPcPath),
    "restoreProjectConfigurationRF() did not create ProjectConfiguration.xlsx"
)

restoredSheetNames <- sort(openxlsx::getSheetNames(restoredPcPath))
requiredSheets <- c("addons")
missingSheets <- setdiff(requiredSheets, restoredSheetNames)
assertOrStop(
    length(missingSheets) == 0,
    paste0(
        "Restored workbook is missing sheets: ",
        paste(missingSheets, collapse = ", ")
    )
)

restoredConfigSheets <- setdiff(restoredSheetNames, "addons")
assertOrStop(
    length(restoredConfigSheets) == 1,
    paste0(
        "Restored workbook must contain exactly one non-addons sheet. Found: ",
        paste(restoredConfigSheets, collapse = ", ")
    )
)

versionRestored <- pcRestored$ospsuiteReportingFrameworkVersion
assertOrStop(
    identical(versionOriginal, versionRestored),
    "RF version did not survive snapshot/restore round-trip"
)

addOnsRestored <- normalizeAddOnPaths(pcRestored)
assertOrStop(
    identical(names(addOnsOriginal), names(addOnsRestored)),
    "Add-on names differ between original and restored configurations"
)
assertOrStop(
    identical(unname(addOnsOriginal), unname(addOnsRestored)),
    "Add-on paths differ between original and restored configurations"
)

reportLines <- c(
    "# UC-01 Full project initialisation round-trip",
    "",
    "## Summary",
    "",
    "This scenario validates init/create/snapshot/restore workflow for project configuration.",
    "",
    "## Assertions",
    "",
    paste0(
        "- Snapshot keys present: ",
        paste(requiredSnapshotKeys, collapse = ", ")
    ),
    paste0(
        "- Restored workbook sheets include: ",
        paste(requiredSheets, collapse = ", ")
    ),
    paste0("- Restored configuration sheet name: ", restoredConfigSheets[[1]]),
    paste0("- RF version before restore: ", versionOriginal),
    paste0("- RF version after restore: ", versionRestored),
    "- Add-on names and relative paths are preserved.",
    "",
    "## Add-on paths (relative)",
    ""
)

for (addOnName in names(addOnsOriginal)) {
    reportLines <- c(
        reportLines,
        paste0("- ", addOnName, ": ", unname(addOnsOriginal[[addOnName]]))
    )
}

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
