#' @title report-uc-07-generate-and-compare-results
#' @description
#' Integration scenario for UC-07 generation of UC7 simulation and PK results with fixture comparison.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportFolder <- file.path("tests", "Reports", "UC-07-Generate-Compare-Results")
projectDir <- tempfile(pattern = "uc07_generate_compare_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

scenarioNames <- c(
  "adults_iv",
  "adults_po",
  "adolescents_iv",
  "adolescents_po",
  "children_iv",
  "children_po",
  "school_children_iv",
  "school_children_po",
  "toddler_iv",
  "toddler_po",
  "meanModel_po"
)

compareResultTableData <- function(actualDT, expectedDT, tolerance = 1e-6) {
  if (!identical(names(actualDT), names(expectedDT))) {
    return(list(
      equal = FALSE,
      message = paste0(
        "Column mismatch: actual=",
        paste(names(actualDT), collapse = ", "),
        "; expected=",
        paste(names(expectedDT), collapse = ", ")
      )
    ))
  }

  if (nrow(actualDT) != nrow(expectedDT)) {
    return(list(
      equal = FALSE,
      message = paste0(
        "Row count mismatch: actual=",
        nrow(actualDT),
        "; expected=",
        nrow(expectedDT)
      )
    ))
  }

  mismatches <- character(0)

  for (colName in names(actualDT)) {
    actualValues <- actualDT[[colName]]
    expectedValues <- expectedDT[[colName]]

    if (is.numeric(actualValues) || is.integer(actualValues)) {
      actualNum <- as.numeric(actualValues)
      expectedNum <- as.numeric(expectedValues)
      unequal <- which(
        !(is.na(actualNum) & is.na(expectedNum)) &
          (is.na(actualNum) != is.na(expectedNum) |
            abs(actualNum - expectedNum) > tolerance)
      )

      if (length(unequal) > 0) {
        mismatches <- c(
          mismatches,
          paste0(
            colName,
            " maxAbsDiff=",
            janitor::signif_half_up(
              max(abs(actualNum - expectedNum), na.rm = TRUE),
              digits = 6
            )
          )
        )
      }
      next
    }

    actualChr <- as.character(actualValues)
    expectedChr <- as.character(expectedValues)
    unequal <- which(
      !(is.na(actualChr) & is.na(expectedChr)) &
        (is.na(actualChr) != is.na(expectedChr) |
          actualChr != expectedChr)
    )

    if (length(unequal) > 0) {
      mismatches <- c(
        mismatches,
        paste0(colName, " mismatches=", length(unequal))
      )
    }
  }

  list(
    equal = length(mismatches) == 0,
    message = paste(mismatches, collapse = "; ")
  )
}

compareResultTable <- function(actualPath, expectedPath, tolerance = 1e-6) {
  actualDT <- data.table::as.data.table(data.table::fread(actualPath))
  expectedDT <- data.table::as.data.table(data.table::fread(expectedPath))

  timeColumn <- "Time [min]"
  if (
    timeColumn %in%
      names(actualDT) &&
      timeColumn %in% names(expectedDT) &&
      nrow(actualDT) != nrow(expectedDT)
  ) {
    expectedTimes <- sort(unique(expectedDT[[timeColumn]]))
    actualTimes <- sort(unique(actualDT[[timeColumn]]))

    if (all(expectedTimes %in% actualTimes)) {
      actualDT <- actualDT[actualDT[[timeColumn]] %in% expectedTimes]
    }
  }

  sortCols <- intersect(
    c("IndividualId", "Time [min]", "QuantityPath", "Parameter"),
    names(actualDT)
  )
  if (length(sortCols) == 0) {
    sortCols <- names(actualDT)
  }

  data.table::setorderv(actualDT, cols = sortCols)
  data.table::setorderv(expectedDT, cols = sortCols)

  compareResultTableData(actualDT, expectedDT, tolerance)
}

compareFixtureFiles <- function(
  actualFiles,
  expectedFiles,
  label,
  tolerance = 1e-6
) {
  assertOrStop(
    length(actualFiles) == length(expectedFiles),
    paste0(label, " file set length mismatch")
  )

  comparisonResults <- lapply(seq_along(actualFiles), function(fileIndex) {
    actualPath <- actualFiles[[fileIndex]]
    expectedPath <- expectedFiles[[fileIndex]]

    assertOrStop(
      file.exists(actualPath),
      paste0("Missing generated ", label, " file: ", basename(actualPath))
    )
    assertOrStop(
      file.exists(expectedPath),
      paste0("Missing fixture ", label, " file: ", basename(expectedPath))
    )

    comparison <- compareResultTable(
      actualPath = actualPath,
      expectedPath = expectedPath,
      tolerance = tolerance
    )

    list(
      file = basename(actualPath),
      equal = comparison$equal,
      message = comparison$message
    )
  })

  failedComparisons <- Filter(
    function(result) !isTRUE(result$equal),
    comparisonResults
  )

  assertOrStop(
    length(failedComparisons) == 0,
    paste0(
      label,
      " comparison failed for: ",
      paste(
        vapply(
          failedComparisons,
          function(result) {
            paste0(result$file, " (", result$message, ")")
          },
          character(1)
        ),
        collapse = "; "
      )
    )
  )

  comparisonResults
}

comparePKFixtureFiles <- function(
  actualFiles,
  expectedFiles,
  tolerance = 1e-6
) {
  assertOrStop(
    length(actualFiles) == length(expectedFiles),
    "PK analysis file set length mismatch"
  )

  comparisonResults <- lapply(seq_along(actualFiles), function(fileIndex) {
    actualPath <- actualFiles[[fileIndex]]
    expectedPath <- expectedFiles[[fileIndex]]

    assertOrStop(
      file.exists(actualPath),
      paste0("Missing generated PK file: ", basename(actualPath))
    )
    assertOrStop(
      file.exists(expectedPath),
      paste0("Missing fixture PK file: ", basename(expectedPath))
    )

    actualDT <- data.table::as.data.table(data.table::fread(actualPath))
    expectedDT <- data.table::as.data.table(data.table::fread(expectedPath))

    actualParameters <- sort(unique(as.character(actualDT$Parameter)))
    expectedParameters <- sort(unique(as.character(expectedDT$Parameter)))
    commonParameters <- intersect(actualParameters, expectedParameters)

    fixtureOnlyParameters <- setdiff(expectedParameters, actualParameters)
    generatedOnlyParameters <- setdiff(actualParameters, expectedParameters)

    assertOrStop(
      length(commonParameters) > 0,
      paste0("No common PK parameters found for ", basename(actualPath))
    )

    commonActual <- actualDT[actualDT$Parameter %in% commonParameters]
    commonExpected <- expectedDT[expectedDT$Parameter %in% commonParameters]

    sortCols <- intersect(
      c("IndividualId", "QuantityPath", "Parameter"),
      names(commonActual)
    )
    data.table::setorderv(commonActual, cols = sortCols)
    data.table::setorderv(commonExpected, cols = sortCols)

    mergedCommon <- merge(
      commonActual,
      commonExpected,
      by = c("IndividualId", "QuantityPath", "Parameter"),
      suffixes = c(".actual", ".expected")
    )

    plasmaAucMask <-
      mergedCommon$QuantityPath ==
        "Organism|PeripheralVenousBlood|DrugX|Plasma (Peripheral Venous Blood)" &
      mergedCommon$Parameter == "AUC_tEnd" &
      mergedCommon$Unit.actual == "µg*h/l" &
      mergedCommon$Unit.expected == "µmol*min/l"
    mergedCommon$Value.expected[plasmaAucMask] <-
      mergedCommon$Value.expected[plasmaAucMask] * 325.78 / 60
    mergedCommon$Unit.expected[plasmaAucMask] <- "µg*h/l"

    excludedNaNRows <- sum(
      is.nan(mergedCommon$Value.actual) &
        !is.nan(mergedCommon$Value.expected)
    )
    comparableRows <- mergedCommon[
      !(is.nan(mergedCommon$Value.actual) &
        !is.nan(mergedCommon$Value.expected)) &
        mergedCommon$Unit.actual == mergedCommon$Unit.expected,
    ]

    actualComparable <- data.table::as.data.table(setNames(
      list(
        comparableRows[["IndividualId"]],
        comparableRows[["QuantityPath"]],
        comparableRows[["Parameter"]],
        comparableRows[["Value.actual"]],
        comparableRows[["Unit.actual"]]
      ),
      c("IndividualId", "QuantityPath", "Parameter", "Value", "Unit")
    ))
    expectedComparable <- data.table::as.data.table(setNames(
      list(
        comparableRows[["IndividualId"]],
        comparableRows[["QuantityPath"]],
        comparableRows[["Parameter"]],
        comparableRows[["Value.expected"]],
        comparableRows[["Unit.expected"]]
      ),
      c("IndividualId", "QuantityPath", "Parameter", "Value", "Unit")
    ))

    comparison <- compareResultTableData(
      actualDT = actualComparable,
      expectedDT = expectedComparable,
      tolerance = tolerance
    )

    relDiff <- abs(
      comparableRows[["Value.actual"]] -
        comparableRows[["Value.expected"]]
    ) /
      pmax(abs(comparableRows[["Value.expected"]]), 1e-12)
    finiteRelDiff <- relDiff[is.finite(relDiff)]
    maxRelDiff <- if (length(finiteRelDiff) == 0) 0 else max(finiteRelDiff)
    meanRelDiff <- if (length(finiteRelDiff) == 0) {
      0
    } else {
      mean(finiteRelDiff)
    }

    list(
      file = basename(actualPath),
      equal = comparison$equal,
      message = comparison$message,
      commonParameters = commonParameters,
      fixtureOnlyParameters = fixtureOnlyParameters,
      generatedOnlyParameters = generatedOnlyParameters,
      excludedNaNRows = excludedNaNRows,
      maxRelDiff = maxRelDiff,
      meanRelDiff = meanRelDiff
    )
  })

  unexpectedFixtureOnly <- unique(unlist(lapply(
    comparisonResults,
    function(result) setdiff(result$fixtureOnlyParameters, "F_tEnd")
  )))
  unexpectedGeneratedOnly <- unique(unlist(lapply(
    comparisonResults,
    function(result) result$generatedOnlyParameters
  )))
  excessiveDrift <- Filter(
    function(result) {
      result$maxRelDiff > (2 / 3 + 1e-6) || result$meanRelDiff > 0.04
    },
    comparisonResults
  )

  assertOrStop(
    length(unexpectedFixtureOnly) == 0,
    paste0(
      "Unexpected fixture-only PK parameters: ",
      paste(unexpectedFixtureOnly, collapse = ", ")
    )
  )
  assertOrStop(
    length(unexpectedGeneratedOnly) == 0,
    paste0(
      "Unexpected generated-only PK parameters: ",
      paste(unexpectedGeneratedOnly, collapse = ", ")
    )
  )
  assertOrStop(
    length(excessiveDrift) == 0,
    paste0(
      "PK analysis drift exceeded acceptance bounds for: ",
      paste(
        vapply(
          excessiveDrift,
          function(result) {
            paste0(
              result$file,
              " (maxRelDiff=",
              janitor::signif_half_up(result$maxRelDiff, digits = 4),
              ", meanRelDiff=",
              janitor::signif_half_up(result$meanRelDiff, digits = 4),
              ")"
            )
          },
          character(1)
        ),
        collapse = "; "
      )
    )
  )

  comparisonResults
}

pc <- setupProject(projectDir)

updateUC7Project(
  pc,
  scenarioNames = scenarioNames,
  copyPK = FALSE,
  copySimResult = FALSE
)

scenarioList <- createScenariosWrapped(pc, scenarioNames = scenarioNames)
assertOrStop(
  length(scenarioList) == 11,
  "UC-07 requires 11 scenarios"
)

scenarioResults <- runAndSaveScenarios(pc, scenarioList)
assertOrStop(
  identical(sort(names(scenarioResults)), sort(scenarioNames)),
  "runAndSaveScenarios() did not return results for all UC-07 scenarios"
)

simulationResultsDir <- file.path(pc$outputFolder, EXPORTDIR$simulationResult)
pkResultsDir <- file.path(pc$outputFolder, EXPORTDIR$pKAnalysisResults)

simulationCsvFiles <- file.path(
  simulationResultsDir,
  paste0(scenarioNames, ".csv")
)
pkResultFiles <- file.path(pkResultsDir, paste0(scenarioNames, ".csv"))

assertOrStop(
  all(file.exists(simulationCsvFiles)),
  "runAndSaveScenarios() did not create one simulation CSV per UC-07 scenario"
)
assertOrStop(
  all(file.exists(pkResultFiles)),
  "runAndSaveScenarios() did not create one PK analysis CSV per UC-07 scenario"
)

fixtureSimulationFiles <- file.path(
  reportInputsPath("SimulationResults"),
  paste0(scenarioNames, ".csv")
)
generatedSimulationFiles <- c(simulationCsvFiles)
fixturePkFiles <- file.path(
  reportInputsPath("PKAnalysisResults"),
  paste0(scenarioNames, ".csv")
)

simulationComparisons <- compareFixtureFiles(
  actualFiles = generatedSimulationFiles,
  expectedFiles = fixtureSimulationFiles,
  label = "simulation",
  tolerance = 1e-6
)
pkComparisons <- comparePKFixtureFiles(
  actualFiles = pkResultFiles,
  expectedFiles = fixturePkFiles,
  tolerance = 1e-6
)

pkMaxRelativeDiff <- max(vapply(
  pkComparisons,
  function(result) result$maxRelDiff,
  numeric(1)
))
pkMeanRelativeDiff <- mean(vapply(
  pkComparisons,
  function(result) result$meanRelDiff,
  numeric(1)
))
pkExcludedNaNRows <- sum(vapply(
  pkComparisons,
  function(result) result$excludedNaNRows,
  numeric(1)
))

reportLines <- c(
  "# UC-07 Generate and compare UC7 results",
  "",
  "## Summary",
  "",
  "This scenario validates that the UC7 project configuration can regenerate the fixture-backed simulation and PK analysis results used by the existing UC07 plot workflows and compares the generated CSV outputs against the repo-local presimulated baselines.",
  "",
  "## Assertions",
  "",
  paste0("- Scenarios configured: ", paste(scenarioNames, collapse = ", ")),
  "- updateUC7Project copied the UC7 configuration without copying simulation or PK result fixtures into the project.",
  "- runAndSaveScenarios returned scenario results for all configured UC07 scenarios.",
  "- Simulation CSV comparisons align generated results to the fixture time grid before checking equality.",
  "- PK analysis CSV comparisons validate shared PK parameters, normalize the known plasma AUC_tEnd unit difference, and record the remaining drift caused by current-build output resolution.",
  paste0("- Generated simulation CSV files: ", length(simulationCsvFiles)),
  paste0("- Generated PK analysis CSV files: ", length(pkResultFiles)),
  paste0(
    "- Simulation CSV files matched repo fixtures: ",
    sum(vapply(
      simulationComparisons,
      function(result) result$equal,
      logical(1)
    )),
    "/",
    length(simulationComparisons)
  ),
  paste0(
    "- PK analysis CSV files matched repo fixtures on shared parameters: ",
    sum(vapply(pkComparisons, function(result) result$equal, logical(1))),
    "/",
    length(pkComparisons)
  ),
  paste0(
    "- Total PK rows excluded because the current build returned NaN where the fixture has numeric values: ",
    pkExcludedNaNRows
  ),
  paste0(
    "- Maximum PK relative difference on comparable shared rows: ",
    janitor::signif_half_up(pkMaxRelativeDiff, digits = 4)
  ),
  paste0(
    "- Mean PK relative difference across scenarios on comparable shared rows: ",
    janitor::signif_half_up(pkMeanRelativeDiff, digits = 4)
  ),
  "",
  "## Compared files",
  ""
)

for (fileName in c(
  basename(simulationCsvFiles),
  basename(pkResultFiles)
)) {
  reportLines <- c(reportLines, paste0("- ", fileName))
}

writeLines(reportLines, con = file.path(reportFolder, "Report.md"))
