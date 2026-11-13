# Reference reports are in Reports directory
# Tested reports are in tests/Reports directory

.listReportFiles <- function(
  basePath,
  reportName,
  pattern,
  folder = NULL,
  recursive = TRUE
) {
  reportPath <- file.path(basePath, "Reports", reportName)
  if (!is.null(folder) && nzchar(folder)) {
    reportPath <- file.path(reportPath, folder)
  }

  list.files(
    path = reportPath,
    recursive = recursive,
    full.names = TRUE,
    pattern = pattern
  )
}

.relativeReportPaths <- function(files) {
  if (length(files) == 0) {
    return(character(0))
  }

  normalized <- normalizePath(files, winslash = "/", mustWork = FALSE)
  sub("^.*?/Reports/[^/]+/?", "", normalized)
}

.expectKnownFiles <- function(
  testFiles,
  referenceFiles,
  expectationFunction,
  excludedRelativePaths = character(0)
) {
  expect_equal(
    length(testFiles),
    length(referenceFiles),
    label = "Different number of generated and reference files"
  )
  if (length(testFiles) != length(referenceFiles)) {
    return(invisible(NULL))
  }

  testRelativePaths <- .relativeReportPaths(testFiles)
  referenceRelativePaths <- .relativeReportPaths(referenceFiles)

  expect_equal(
    anyDuplicated(testRelativePaths),
    0,
    label = "Generated files contain duplicate relative paths"
  )
  expect_equal(
    anyDuplicated(referenceRelativePaths),
    0,
    label = "Reference files contain duplicate relative paths"
  )

  if (length(excludedRelativePaths) > 0) {
    testKeep <- !(testRelativePaths %in% excludedRelativePaths)
    referenceKeep <- !(referenceRelativePaths %in% excludedRelativePaths)
    testFiles <- testFiles[testKeep]
    referenceFiles <- referenceFiles[referenceKeep]
    testRelativePaths <- testRelativePaths[testKeep]
    referenceRelativePaths <- referenceRelativePaths[referenceKeep]
  }

  expect_equal(
    sort(testRelativePaths),
    sort(referenceRelativePaths),
    label = "Generated and reference file identities differ"
  )
  if (!identical(sort(testRelativePaths), sort(referenceRelativePaths))) {
    return(invisible(NULL))
  }

  for (relativePath in sort(referenceRelativePaths)) {
    testPath <- testFiles[match(relativePath, testRelativePaths)]
    referencePath <- referenceFiles[match(relativePath, referenceRelativePaths)]
    expectationFunction(testPath, referencePath)
  }
}

.runExpectedPlotsTest <- function(mapping) {
  test_that("Expected Plots", {
    plotFolder <- if (!is.null(mapping$PlotFolder)) mapping$PlotFolder else NULL

    referenceImages <- .listReportFiles(
      basePath = "../..",
      reportName = mapping$Report,
      pattern = "png",
      folder = plotFolder
    )
    testImages <- .listReportFiles(
      basePath = "..",
      reportName = mapping$Report,
      pattern = "png",
      folder = plotFolder
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
    captionFolder <- if (!is.null(mapping$PlotFolder)) {
      mapping$PlotFolder
    } else {
      NULL
    }

    referenceCaptions <- .listReportFiles(
      basePath = "../..",
      reportName = mapping$Report,
      pattern = "\\.caption$",
      folder = captionFolder
    )
    testCaptions <- .listReportFiles(
      basePath = "..",
      reportName = mapping$Report,
      pattern = "\\.caption$",
      folder = captionFolder
    )

    .expectKnownFiles(
      testFiles = testCaptions,
      referenceFiles = referenceCaptions,
      expectationFunction = expectKnownCaption
    )
  })
}

.runExpectedResultsTests <- function(mapping) {
  test_that("Expected Results Tables", {
    resultFolder <- if (!is.null(mapping$ResultsFolder)) {
      mapping$ResultsFolder
    } else {
      NULL
    }

    referenceResults <- .listReportFiles(
      basePath = "../..",
      reportName = mapping$Report,
      pattern = "\\.csv$",
      folder = resultFolder
    )
    testResults <- .listReportFiles(
      basePath = "..",
      reportName = mapping$Report,
      pattern = "\\.csv$",
      folder = resultFolder
    )

    .expectKnownFiles(
      testFiles = testResults,
      referenceFiles = referenceResults,
      expectationFunction = expectKnownCsv
    )
  })
}

.runExpectedQmdTest <- function(mapping) {
  test_that("Expected Qmd", {
    referenceQmd <- .listReportFiles(
      basePath = "../..",
      reportName = mapping$Report,
      pattern = "\\.qmd$",
      recursive = FALSE
    )
    testQmd <- .listReportFiles(
      basePath = "..",
      reportName = mapping$Report,
      pattern = "\\.qmd$",
      recursive = FALSE
    )

    .expectKnownFiles(
      testFiles = testQmd,
      referenceFiles = referenceQmd,
      expectationFunction = expectKnownReport
    )
  })
}

.runReportTests <- function(mapping) {
  cat(mapping$Report)

  test_that("Report has run", {
    expect_true(file.exists(file.path(
      "..",
      "Reports",
      mapping$Report,
      "Report.md"
    )))
  })

  if (!mapping$Reference) {
    return(invisible(NULL))
  }

  hasReferenceArtifacts <-
    length(.listReportFiles(
      basePath = "../..",
      reportName = mapping$Report,
      pattern = "png"
    )) >
      0 ||
    length(.listReportFiles(
      basePath = "../..",
      reportName = mapping$Report,
      pattern = "\\.caption$"
    )) >
      0 ||
    length(.listReportFiles(
      basePath = "../..",
      reportName = mapping$Report,
      pattern = "\\.csv$"
    )) >
      0 ||
    length(.listReportFiles(
      basePath = "../..",
      reportName = mapping$Report,
      pattern = "\\.qmd$",
      recursive = FALSE
    )) >
      0

  test_that("Reference artifacts exist", {
    expect_true(
      hasReferenceArtifacts,
      label = paste0(
        "Reference=true requires at least one comparable reference artifact (png/caption/csv/qmd) for ",
        mapping$Report
      )
    )
  })

  if (!isTRUE(hasReferenceArtifacts)) {
    return(invisible(NULL))
  }

  .runExpectedPlotsTest(mapping)
  .runExpectedCaptionsTest(mapping)
  .runExpectedResultsTests(mapping)
  .runExpectedQmdTest(mapping)

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
