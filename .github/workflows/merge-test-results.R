library(jsonlite)

source(".github/workflows/test-results-utils.R")

artifactsDir <- Sys.getenv("ARTIFACTS_DIR", "artifact-data")
reportMappings <- loadReportMappings(simplifyVector = TRUE)
expectedReports <- reportMappings$Report

artifactReportsDir <- file.path(artifactsDir, "tests", "Reports")
artifactResultsDir <- file.path(artifactsDir, "test-results")

summarizeReportResult <- function(reportResults) {
  reportResultsDf <- tryCatch(as.data.frame(reportResults), error = function(e) data.frame())
  if (
    nrow(reportResultsDf) == 0 ||
    !all(c("failed", "warning") %in% names(reportResultsDf))
  ) {
    return(list(
      status = "failed",
      failed_tests = NA_integer_,
      warning_tests = NA_integer_,
      message = "Could not parse test result details."
    ))
  }

  failedTests <- sum(reportResultsDf$failed, na.rm = TRUE)
  warningTests <- sum(reportResultsDf$warning, na.rm = TRUE)
  status <- ifelse(failedTests > 0, "failed", "passed")

  list(
    status = status,
    failed_tests = failedTests,
    warning_tests = warningTests,
    message = NA_character_
  )
}

unlink("tests/Reports", recursive = TRUE, force = TRUE)
dir.create("tests/Reports", recursive = TRUE, showWarnings = FALSE)

combinedResultList <- list()
reportStatuses <- vector("list", length(expectedReports))
index <- 1

for (reportName in expectedReports) {
  reportArtifactPath <- file.path(artifactReportsDir, reportName)
  resultArtifactPath <- file.path(artifactResultsDir, paste0(reportName, ".rds"))
  hasReportArtifact <- file.exists(reportArtifactPath)
  hasResultArtifact <- file.exists(resultArtifactPath)

  if (hasReportArtifact) {
    file.copy(
      from = reportArtifactPath,
      to = file.path("tests", "Reports"),
      recursive = TRUE,
      overwrite = TRUE
    )
  }

  reportStatus <- list(
    report = reportName,
    has_report_artifact = hasReportArtifact,
    has_result_artifact = hasResultArtifact,
    status = "failed",
    failed_tests = NA_integer_,
    warning_tests = NA_integer_,
    message = NA_character_
  )

  if (hasResultArtifact) {
    reportResults <- readRDS(resultArtifactPath)
    combinedResultList <- c(combinedResultList, reportResults)
    parsedStatus <- summarizeReportResult(reportResults)
    reportStatus$status <- parsedStatus$status
    reportStatus$failed_tests <- parsedStatus$failed_tests
    reportStatus$warning_tests <- parsedStatus$warning_tests
    reportStatus$message <- parsedStatus$message
  } else {
    reportStatus$message <- "Missing test result artifact."
  }

  if (!hasReportArtifact && is.na(reportStatus$message)) {
    reportStatus$message <- "Missing report artifact."
  } else if (!hasReportArtifact && !is.na(reportStatus$message)) {
    reportStatus$message <- paste(reportStatus$message, "Missing report artifact.")
  }

  reportStatuses[[index]] <- reportStatus
  index <- index + 1
}

combinedResults <- if (length(combinedResultList) > 0) {
  normalizeTestResults(combinedResultList)
} else {
  structure(list(), class = "testthat_results")
}

saveRDS(combinedResults, "test-results.rds")

passedReports <- sum(vapply(reportStatuses, function(status) identical(status$status, "passed"), logical(1)))
totalReports <- length(reportStatuses)
failedReports <- totalReports - passedReports

testsDetail <- vector("list", length(combinedResults))
idx <- 1
for (testResult in combinedResults) {
  resultMessage <- vector("list", length(testResult$results))
  ri <- 1
  for (testResultContent in testResult$results) {
    resultMessage[[ri]] <- list(
      test = testResultContent$test,
      message = testResultContent$message,
      backtrace = backtrace(testResultContent$trace),
      code = as.character(testResultContent$srcref)
    )
    ri <- ri + 1
  }
  testsDetail[[idx]] <- c(
    testResult[setdiff(names(testResult), "results")],
    results = list(resultMessage)
  )
  idx <- idx + 1
}

write_json(
  list(
    summary = list(
      total_reports = totalReports,
      passed_reports = passedReports,
      failed_reports = failedReports
    ),
    reports = reportStatuses,
    tests = testsDetail
  ),
  path = "log.json",
  auto_unbox = TRUE,
  pretty = TRUE
)
