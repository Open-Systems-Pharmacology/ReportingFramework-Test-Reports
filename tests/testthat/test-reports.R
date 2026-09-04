# Reference reports are in Reports directory
# Tested reports are in tests/Reports directory

resultsToTest <- data.frame(
  name = c(
    "Simulation Results",
    "PK Analysis Results",
    "Sensitivity Results",
    "Goodness of Fit",
    "PK Parameter Tables",
    "Sensitivity Tables",
    "Mass Balance Results",
    "Absorption Results",
    "Demography Results"
  ),
  folder = c(
    "SimulationResults",
    "PKAnalysisResults",
    "SensitivityResults",
    "TimeProfiles",
    "PKAnalysis",
    "Sensitivity",
    "MassBalance",
    "Absorption",
    "Demography"
  )
)

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
  cat(mapping$Report)
  # No reference, only test if report has run
  if (!mapping$Reference) {
    test_that("Report has run", {
      expect_true(file.exists(file.path(
        "..",
        "Reports",
        mapping$Report,
        "Report.md"
      )))
    })
    next
  }

  test_that("Expected Plots", {
    referenceImages <- list.files(
      path = file.path("../..", "Reports", mapping$Report),
      recursive = TRUE,
      full.names = TRUE,
      pattern = "(png|svg)"
    )
    testImages <- list.files(
      path = file.path("..", "Reports", mapping$Report),
      recursive = TRUE,
      full.names = TRUE,
      pattern = "(png|svg)"
    )
    for (imageIndex in seq_along(referenceImages)) {
      expectKnownImage(testImages[imageIndex], referenceImages[imageIndex])
    }
  })

  for (resultIndex in seq_along(resultsToTest$name)) {
    test_that(paste("Expected", resultsToTest$name[resultIndex]), {
      referenceResults <- list.files(
        path = file.path(
          "../..",
          "Reports",
          mapping$Report,
          resultsToTest$folder[resultIndex]
        ),
        recursive = TRUE,
        full.names = TRUE,
        pattern = "csv"
      )
      testResults <- list.files(
        path = file.path(
          "..",
          "Reports",
          mapping$Report,
          resultsToTest$folder[resultIndex]
        ),
        recursive = TRUE,
        full.names = TRUE,
        pattern = "csv"
      )
      for (resultIndex in seq_along(referenceResults)) {
        expectKnownReport(
          testResults[resultIndex],
          referenceResults[resultIndex]
        )
      }
    })
  }
}
