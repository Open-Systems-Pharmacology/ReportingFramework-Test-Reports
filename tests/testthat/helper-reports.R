# Functions from file names starting with helper
# are loaded for every test
# The helper functions here wrap test failures as warnings
# to get testthat report even if some tests fail

#' @title expectEqual
#' @description
#' Root function for comparing content of files are equal
#' displaying `label` if not
#' @param x Content to compare
#' @param y Reference content to be compared with
#' @param label Displayed label
expectEqual <- function(x, y, label) {
  expect_true(all(x == y), label = label)
}

#' @title expectFiles
#' @description
#' Compare file names
#' @param testFiles Content to compare
#' @param refFiles Reference content to be compared with
expectFiles <- function(testFiles, refFiles) {
  return(expectEqual(
    x = testFiles,
    y = refFiles,
    label = setdiff(union(testFiles, refFiles), intersect(testFiles, refFiles))
  ))
}

#' @title expectKnownReport
#' @description
#' Compare content of reporting framework report
#' @param testReport Content to compare
#' @param refReport Reference content to be compared with
expectKnownReport <- function(testReport, refReport) {
  return(expectEqual(
    x = readLines(testReport),
    y = readLines(refReport),
    label = testReport
  ))
}

#' @title expectKnownImage
#' @description
#' Compare content of an image
#' @param testFile Content to compare
#' @param refFile Reference content to be compared with
expectKnownImage <- function(testFile, refFile) {
  if (grepl(pattern = "svg", x = testFile)) {
    return(expectEqual(
      x = rsvg::rsvg(testFile),
      y = rsvg::rsvg(refFile),
      label = testFile
    ))
  }
  return(expectEqual(
    x = png::readPNG(source = testFile),
    y = png::readPNG(source = refFile),
    label = testFile
  ))
}

#' @title expectKnownCaption
#' @description
#' Compare content of a caption file
#' @param testCaption Caption file to compare
#' @param refCaption Reference caption file to be compared with
expectKnownCaption <- function(testCaption, refCaption) {
  return(expectEqual(
    x = readLines(testCaption),
    y = readLines(refCaption),
    label = testCaption
  ))
}

#' @title expectKnownCsv
#' @description
#' Compare content of a csv file while respecting column types
#' @param testCsv Csv file to compare
#' @param refCsv Reference csv file to be compared with
#' @param tolerance Numeric comparison tolerance
expectKnownCsv <- function(
  testCsv,
  refCsv,
  tolerance = sqrt(.Machine$double.eps)
) {
  testData <- utils::read.csv(
    testCsv,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  refData <- utils::read.csv(
    refCsv,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  expect_equal(colnames(testData), colnames(refData), label = testCsv)
  expect_equal(nrow(testData), nrow(refData), label = testCsv)

  for (columnName in colnames(refData)) {
    testColumn <- testData[[columnName]]
    refColumn <- refData[[columnName]]
    label <- paste0(testCsv, " [", columnName, "]")

    if (is.numeric(testColumn) && is.numeric(refColumn)) {
      expect_equal(testColumn, refColumn, tolerance = tolerance, label = label)
      next
    }

    expect_identical(
      as.character(testColumn),
      as.character(refColumn),
      label = label
    )
  }
}
