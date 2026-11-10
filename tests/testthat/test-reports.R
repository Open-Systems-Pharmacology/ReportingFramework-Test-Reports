# Reference reports are in Reports directory
# Tested reports are in tests/Reports directory

.listReportFiles <- function(basePath, reportName, pattern, folder = NULL) {
  list.files(
    path = file.path(basePath, "Reports", reportName, folder),
    recursive = TRUE,
    full.names = TRUE,
    pattern = pattern
  )
}

.expectKnownFiles <- function(testFiles, referenceFiles, expectationFunction) {
  for (fileIndex in seq_along(referenceFiles)) {
    expectationFunction(testFiles[fileIndex], referenceFiles[fileIndex])
  }
}

.runExpectedPlotsTest <- function(mapping) {
  test_that("Expected Plots", {
    referenceImages <- .listReportFiles(
      basePath = "../..",
      reportName = mapping$Report,
      pattern = "(png|svg)"
    )
    testImages <- .listReportFiles(
      basePath = "..",
      reportName = mapping$Report,
      pattern = "(png|svg)"
    )

    .expectKnownFiles(
      testFiles = testImages,
      referenceFiles = referenceImages,
      expectationFunction = expectKnownImage
    )
  })
}

.runExpectedCaptionsTest <- function(mapping) {
  test_that("Expected Captions", {
    referenceCaptions <- .listReportFiles(
      basePath = "../..",
      reportName = mapping$Report,
      pattern = "\\.captions$"
    )
    testCaptions <- .listReportFiles(
      basePath = "..",
      reportName = mapping$Report,
      pattern = "\\.captions$"
    )

    .expectKnownFiles(
      testFiles = testCaptions,
      referenceFiles = referenceCaptions,
      expectationFunction = expectKnownCaption
    )
  })
}

.runExpectedResultsTests <- function(mapping) {
  for (resultIndex in seq_along(resultsToTest$name)) {
    test_that(paste("Expected", resultsToTest$name[resultIndex]), {
      referenceResults <- .listReportFiles(
        basePath = "../..",
        reportName = mapping$Report,
        pattern = "csv",
        folder = resultsToTest$folder[resultIndex]
      )
      testResults <- .listReportFiles(
        basePath = "..",
        reportName = mapping$Report,
        pattern = "csv",
        folder = resultsToTest$folder[resultIndex]
      )

      .expectKnownFiles(
        testFiles = testResults,
        referenceFiles = referenceResults,
        expectationFunction = expectKnownReport
      )
    })
  }
}

.runReportTests <- function(mapping) {
  cat(mapping$Report)

  if (!mapping$Reference) {
    test_that("Report has run", {
      expect_true(file.exists(file.path(
        "..",
        "Reports",
        mapping$Report,
        "Report.md"
      )))
    })
    return(invisible(NULL))
  }

  .runExpectedPlotsTest(mapping)
  .runExpectedCaptionsTest(mapping)
  .runExpectedResultsTests(mapping)

  invisible(NULL)
}

reportMappings <- jsonlite::fromJSON(
  "report-mapping.json",
  simplifyVector = FALSE
)
selectedReport <- Sys.getenv("REPORT_NAME")

if (nzchar(selectedReport)) {
  reportMappings <- Filter(
    function(mapping) identical(mapping$Report, selectedReport),
    reportMappings
  )
}

if (length(reportMappings) == 0) {
  stop("No report mappings selected for testing.")
}

for (mapping in reportMappings) {
  .runReportTests(mapping)
}
