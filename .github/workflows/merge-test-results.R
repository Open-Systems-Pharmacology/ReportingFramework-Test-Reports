library(jsonlite)

source(".github/workflows/test-results-utils.R")

artifactsDir <- Sys.getenv("ARTIFACTS_DIR", "artifact-data")
reportMappings <- loadReportMappings(simplifyVector = TRUE)
expectedReports <- reportMappings$Report

artifactReportsDir <- file.path(artifactsDir, "tests", "Reports")
artifactResultsDir <- file.path(artifactsDir, "test-results")

missingReports <- expectedReports[!file.exists(file.path(artifactReportsDir, expectedReports))]
missingResults <- expectedReports[!file.exists(file.path(artifactResultsDir, paste0(expectedReports, ".rds")))]

if (length(missingReports) > 0 || length(missingResults) > 0) {
  stop(
    paste(
      c(
        if (length(missingReports) > 0) {
          paste("Missing report artifacts:", paste(missingReports, collapse = ", "))
        },
        if (length(missingResults) > 0) {
          paste("Missing result artifacts:", paste(missingResults, collapse = ", "))
        }
      ),
      collapse = " | "
    )
  )
}

unlink("tests/Reports", recursive = TRUE, force = TRUE)
dir.create("tests/Reports", recursive = TRUE, showWarnings = FALSE)

for (reportName in expectedReports) {
  file.copy(
    from = file.path(artifactReportsDir, reportName),
    to = file.path("tests", "Reports"),
    recursive = TRUE,
    overwrite = TRUE
  )
}

combinedResults <- normalizeTestResults(unlist(lapply(expectedReports, function(reportName) {
  readRDS(file.path(artifactResultsDir, paste0(reportName, ".rds")))
}), recursive = FALSE))

saveRDS(combinedResults, "test-results.rds")
logTestResults(combinedResults, "log.json")
