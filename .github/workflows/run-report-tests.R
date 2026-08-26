library(testthat)
library(jsonlite)

source(".github/workflows/test-results-utils.R")
source("tests/testthat/helper-reports.R")

reportName <- Sys.getenv("REPORT_NAME")
reportScript <- Sys.getenv("REPORT_SCRIPT")

if (!nzchar(reportName) || !nzchar(reportScript)) {
  stop("REPORT_NAME and REPORT_SCRIPT must be set.")
}

dir.create("tests/Reports", recursive = TRUE, showWarnings = FALSE)
dir.create("test-results", recursive = TRUE, showWarnings = FALSE)
unlink(file.path("tests", "Reports", reportName), recursive = TRUE, force = TRUE)

source(
  file.path("R", paste0(reportScript, ".R")),
  local = new.env(parent = globalenv()),
  encoding = "UTF-8"
)

testResultsRaw <- test_file(
  "tests/testthat/test-reports.R",
  reporter = ListReporter,
  stop_on_failure = FALSE
)

saveRDS(testResultsRaw, file.path("test-results", paste0(reportName, ".rds")))
logTestResults(testResultsRaw, file.path("test-results", paste0(reportName, ".json")))
