backtrace <- function(errorTrace) {
  if (is.null(errorTrace)) {
    return()
  }
  paste0(
    "Call ", errorTrace$parent, ", in ",
    errorTrace$namespace, " (", errorTrace$scope, ") ",
    errorTrace$call
  )
}

logTestResults <- function(testResultsRaw, logFile = "log.json") {
  jsonResults <- vector("list", length(testResultsRaw))
  index <- 1
  for (testResult in testResultsRaw) {
    resultMessage <- vector("list", length(testResult$results))
    resultIndex <- 1
    for (testResultContent in testResult$results) {
      resultMessage[[resultIndex]] <- list(
        test = testResultContent$test,
        message = testResultContent$message,
        backtrace = backtrace(testResultContent$trace),
        code = as.character(testResultContent$srcref)
      )
      resultIndex <- resultIndex + 1
    }
    jsonResults[[index]] <- c(
      testResult[setdiff(names(testResult), "results")],
      results = list(resultMessage)
    )
    index <- index + 1
  }
  jsonlite::write_json(jsonResults, auto_unbox = TRUE, pretty = TRUE, path = logFile)
  invisible()
}

normalizeTestResults <- function(testResultsRaw) {
  if (inherits(testResultsRaw, "testthat_results")) {
    return(testResultsRaw)
  }

  structure(testResultsRaw, class = "testthat_results")
}

loadReportMappings <- function(path = "tests/testthat/report-mapping.json", simplifyVector = TRUE) {
  jsonlite::fromJSON(path, simplifyVector = simplifyVector)
}
