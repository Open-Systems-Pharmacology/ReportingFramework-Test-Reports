setObservedTimeProfileColumnTypes <- function(dataObserved) {
  identifierCols <- c(
    "studyId",
    "subjectId",
    "individualId",
    "group",
    "outputPathId",
    "weight",
    "age",
    "height",
    "dataType",
    "dataClass"
  )
  timeprofileCols <- c("xValues", "xUnit", "yValues", "yUnit", "lloq")

  for (col in intersect(identifierCols, names(dataObserved))) {
    data.table::setattr(dataObserved[[col]], "columnType", "identifier")
  }
  for (col in intersect(timeprofileCols, names(dataObserved))) {
    data.table::setattr(dataObserved[[col]], "columnType", "timeprofile")
  }

  dataObserved
}

createObservedData <- function(
  outputPathMap,
  scenarioNames,
  simulationResultsDir,
  populationFile,
  nIndividuals = 12L,
  plasmaMolecularWeight = 325.78
) {
  times <- c(0, 0.25, 0.5, 1, 2, 6, 12, 24)
  timeMinutes <- times * 60

  dtPopulation <- data.table::fread(populationFile)
  requiredPopulationCols <- c(
    "IndividualId",
    "Organism|Weight",
    "Organism|Age",
    "Organism|Height"
  )
  missingPopulationCols <- setdiff(requiredPopulationCols, names(dtPopulation))
  assertOrStop(
    length(missingPopulationCols) == 0,
    paste(
      "Missing population columns in adults.csv:",
      paste(missingPopulationCols, collapse = ", ")
    )
  )

  dtPopulation <- data.table::data.table(
    IndividualId = as.integer(dtPopulation[["IndividualId"]]),
    weight = janitor::round_half_up(dtPopulation[["Organism|Weight"]], digits = 0),
    age = janitor::round_half_up(dtPopulation[["Organism|Age"]], digits = 0),
    height = janitor::round_half_up(dtPopulation[["Organism|Height"]], digits = 0)
  )

  firstScenarioSim <- data.table::fread(file.path(
    simulationResultsDir,
    paste0(scenarioNames[[1]], ".csv")
  ))
  availableIds <- intersect(
    unique(as.integer(firstScenarioSim$IndividualId)),
    unique(dtPopulation$IndividualId)
  )
  assertOrStop(
    length(availableIds) >= nIndividuals,
    "Not enough shared individuals between simulation results and adults.csv"
  )

  set.seed(1234)
  selectedIds <- sort(sample(
    availableIds,
    size = nIndividuals,
    replace = FALSE
  ))

  dtObserved <- data.table::rbindlist(lapply(
    scenarioNames,
    function(scenarioName) {
      simFile <- file.path(simulationResultsDir, paste0(scenarioName, ".csv"))
      dtSimulation <- data.table::fread(simFile)
      simulationOutputCols <- setdiff(
        names(dtSimulation),
        c("IndividualId", "Time [min]")
      )
      assertOrStop(
        all(unname(outputPathMap) %in% simulationOutputCols),
        paste0(
          "Simulation result is missing expected outputs: ",
          simFile
        )
      )

      dtSimulation$IndividualId <- as.integer(dtSimulation$IndividualId)
      dtSimulation <- dtSimulation[
        dtSimulation$IndividualId %in%
          selectedIds &
          dtSimulation[["Time [min]"]] %in% timeMinutes,
      ]
      assertOrStop(
        nrow(dtSimulation) > 0,
        paste0("No sampled simulation rows found in: ", simFile)
      )
      dtSimulation <- merge(
        dtSimulation,
        dtPopulation,
        by = "IndividualId",
        all.x = TRUE,
        sort = FALSE
      )

      data.table::rbindlist(lapply(
        seq_along(outputPathMap),
        function(outputIdx) {
          outputId <- names(outputPathMap)[[outputIdx]]
          outputColumn <- unname(outputPathMap[[outputIdx]])
          unitMatch <- regmatches(
            outputColumn,
            regexec(".*\\[([^]]+)\\]$", outputColumn)
          )[[1]]
          outputUnit <- if (length(unitMatch) > 1) unitMatch[[2]] else ""

          noiseFactor <- rlnorm(nrow(dtSimulation), meanlog = 0, sdlog = 0.15)
          yValues <- dtSimulation[[outputColumn]] * noiseFactor
          if (identical(outputId, "Plasma")) {
            yValues <- yValues * plasmaMolecularWeight
            outputUnit <- "µg/l"
          }

          data.table::data.table(
            studyId = "1234",
            subjectId = paste0(scenarioName, "_", dtSimulation$IndividualId),
            individualId = as.character(dtSimulation$IndividualId),
            group = scenarioName,
            outputPathId = outputId,
            weight = dtSimulation$weight,
            age = dtSimulation$age,
            height = dtSimulation$height,
            xValues = dtSimulation[["Time [min]"]] / 60,
            xUnit = "h",
            yValues = janitor::signif_half_up(yValues, digits = 3),
            yUnit = outputUnit,
            lloq = 0.1,
            dataType = "observed",
            dataClass = get("DATACLASS", inherits = TRUE)$tpIndividual
          )
        }
      ))
    }
  ))

  setObservedTimeProfileColumnTypes(dtObserved)
}

createObservedPKData <- function(
  outputPathMap,
  scenarioNames,
  pkAnalysisResultsDir,
  pkParameters = NULL,
  nIndividuals = 12L,
  noiseSdLog = 0.15,
  valueDigits = 3L,
  plasmaOutputId = "Plasma",
  plasmaMolecularWeight = NULL,
  populationIdMap = NULL
) {
  pkFiles <- file.path(pkAnalysisResultsDir, paste0(scenarioNames, ".csv"))
  assertOrStop(
    all(file.exists(pkFiles)),
    paste0(
      "Missing PK analysis result files: ",
      paste(basename(pkFiles)[!file.exists(pkFiles)], collapse = ", ")
    )
  )

  pkResultTables <- lapply(pkFiles, data.table::fread)
  names(pkResultTables) <- scenarioNames

  requiredColumns <- c(
    "IndividualId",
    "QuantityPath",
    "Parameter",
    "Value",
    "Unit"
  )
  missingColumns <- unique(unlist(lapply(pkResultTables, function(dtPk) {
    setdiff(requiredColumns, names(dtPk))
  })))
  assertOrStop(
    length(missingColumns) == 0,
    paste(
      "PK analysis results are missing required columns:",
      paste(missingColumns, collapse = ", ")
    )
  )

  sharedIds <- Reduce(
    intersect,
    lapply(pkResultTables, function(dtPk) unique(as.integer(dtPk$IndividualId)))
  )
  assertOrStop(
    length(sharedIds) >= nIndividuals,
    "Not enough shared individuals across PK analysis result files"
  )

  set.seed(1234)
  selectedIds <- sort(sample(sharedIds, size = nIndividuals, replace = FALSE))

  if (is.null(populationIdMap)) {
    populationIdMap <- stats::setNames(
      sub("_(iv|po)$", "", scenarioNames),
      scenarioNames
    )
  }

  dtObservedPk <- data.table::rbindlist(lapply(
    scenarioNames,
    function(scenarioName) {
      dtPk <- data.table::copy(pkResultTables[[scenarioName]])
      dtPk$IndividualId <- as.integer(dtPk$IndividualId)
      dtPk <- dtPk[
        dtPk$IndividualId %in%
          selectedIds &
          dtPk$QuantityPath %in% unname(outputPathMap),
      ]

      if (!is.null(pkParameters)) {
        dtPk <- dtPk[dtPk$Parameter %in% pkParameters, ]
      }

      assertOrStop(
        nrow(dtPk) > 0,
        paste0("No filtered PK rows found in: ", scenarioName)
      )

      outputIds <- names(outputPathMap)[match(
        dtPk$QuantityPath,
        unname(outputPathMap)
      )]
      valueNoise <- rlnorm(nrow(dtPk), meanlog = 0, sdlog = noiseSdLog)
      values <- dtPk$Value * valueNoise
      displayUnits <- as.character(dtPk$Unit)

      if (!is.null(plasmaMolecularWeight)) {
        plasmaConcMask <- outputIds == plasmaOutputId & displayUnits == "µmol/l"
        values[plasmaConcMask] <- values[plasmaConcMask] * plasmaMolecularWeight
        displayUnits[plasmaConcMask] <- "µg/l"

        plasmaAucMask <-
          outputIds == plasmaOutputId & displayUnits == "µmol*min/l"
        values[plasmaAucMask] <-
          values[plasmaAucMask] * plasmaMolecularWeight / 60
        displayUnits[plasmaAucMask] <- "µg*h/l"
      }

      data.table::data.table(
        scenario = scenarioName,
        pkParameter = as.character(dtPk$Parameter),
        individualId = as.character(dtPk$IndividualId),
        value = janitor::signif_half_up(values, digits = valueDigits),
        outputPathId = outputIds,
        displayNamePKParameter = as.character(dtPk$Parameter),
        displayUnitPKParameter = displayUnits,
        populationId = unname(populationIdMap[[scenarioName]]),
        dataType = "observed"
      )
    }
  ))

  dtObservedPk
}

aggregateObservedPKData <- function(
  dataObservedPK,
  groupColumn = "scenario",
  errorType = "GeometricStdDev"
) {
  assertOrStop(
    data.table::is.data.table(dataObservedPK),
    "Observed PK data must be a data.table"
  )

  requiredColumns <- c(
    groupColumn,
    "pkParameter",
    "outputPathId",
    "value",
    "displayNamePKParameter",
    "displayUnitPKParameter"
  )
  missingColumns <- setdiff(requiredColumns, names(dataObservedPK))
  assertOrStop(
    length(missingColumns) == 0,
    paste(
      "Observed PK data is missing required columns:",
      paste(missingColumns, collapse = ", ")
    )
  )

  dataObservedPK[,
    .(
      N = .N,
      values = exp(mean(log(value))),
      errorValues = exp(stats::sd(log(value))),
      errorType = errorType,
      dataClass = get("DATACLASS", inherits = TRUE)$pkAggregated,
      dataType = "observed"
    ),
    by = .(pkParameter, outputPathId, scenario)
  ] |>
    data.table::setnames(old = "scenario", new = "group")
}

aggregateObservedPKPointEstimateData <- function(
  dataObservedPK,
  groupColumn = "scenario",
  confLevel = 0.9,
  errorType = "geometric mean|90% CI lower|90% CI upper"
) {
  assertOrStop(
    data.table::is.data.table(dataObservedPK),
    "Observed PK data must be a data.table"
  )

  requiredColumns <- c(
    groupColumn,
    "pkParameter",
    "outputPathId",
    "value",
    "displayNamePKParameter",
    "displayUnitPKParameter"
  )
  missingColumns <- setdiff(requiredColumns, names(dataObservedPK))
  assertOrStop(
    length(missingColumns) == 0,
    paste(
      "Observed PK data is missing required columns:",
      paste(missingColumns, collapse = ", ")
    )
  )

  alpha <- 1 - confLevel

  dataObservedPK[,
    {
      logValues <- log(value[value > 0])
      nLog <- length(logValues)

      assertOrStop(
        nLog > 0,
        "Observed PK point-estimate aggregation requires positive values"
      )

      meanLog <- mean(logValues)
      geometricMean <- exp(meanLog)

      if (nLog > 1) {
        sdLog <- stats::sd(logValues)
        stderrLog <- sdLog / sqrt(nLog)
        tValue <- stats::qt(1 - alpha / 2, df = nLog - 1)
        ciLower <- exp(meanLog - tValue * stderrLog)
        ciUpper <- exp(meanLog + tValue * stderrLog)
      } else {
        ciLower <- geometricMean
        ciUpper <- geometricMean
      }

      .(
        N = nLog,
        values = geometricMean,
        minValue = ciLower,
        maxValue = ciUpper,
        errorType = errorType,
        dataClass = get("DATACLASS", inherits = TRUE)$pkAggregated,
        dataType = "observed"
      )
    },
    by = c("pkParameter", "outputPathId", groupColumn)
  ] |>
    data.table::setnames(old = groupColumn, new = "group")
}

aggregateObservedPKRatioData <- function(
  dataObservedPK,
  numeratorSuffix = "_po$",
  denominatorSuffix = "_iv$",
  errorType = "GeometricStdDev"
) {
  assertOrStop(
    data.table::is.data.table(dataObservedPK),
    "Observed PK data must be a data.table"
  )

  requiredColumns <- c(
    "scenario",
    "pkParameter",
    "individualId",
    "value",
    "outputPathId",
    "displayNamePKParameter",
    "displayUnitPKParameter"
  )
  missingColumns <- setdiff(requiredColumns, names(dataObservedPK))
  assertOrStop(
    length(missingColumns) == 0,
    paste(
      "Observed PK ratio data is missing required columns:",
      paste(missingColumns, collapse = ", ")
    )
  )

  dtObservedPK <- data.table::copy(dataObservedPK)
  dtObservedPK[, ratioGroup := sub("_(iv|po)$", "", scenario)]
  dtObservedPK[,
    arm := data.table::fifelse(
      grepl(numeratorSuffix, scenario),
      "numerator",
      data.table::fifelse(
        grepl(denominatorSuffix, scenario),
        "denominator",
        NA_character_
      )
    )
  ]

  numeratorDT <- dtObservedPK[arm == "numerator"]
  denominatorDT <- dtObservedPK[arm == "denominator"]

  assertOrStop(
    nrow(numeratorDT) > 0,
    "No observed numerator rows found for PK ratios"
  )
  assertOrStop(
    nrow(denominatorDT) > 0,
    "No observed denominator rows found for PK ratios"
  )

  mergedRatios <- merge(
    numeratorDT,
    denominatorDT,
    by = c("ratioGroup", "pkParameter", "individualId", "outputPathId"),
    suffixes = c("Numerator", "Denominator")
  )

  assertOrStop(
    nrow(mergedRatios) > 0,
    "No matching observed PO/IV pairs found for PK ratios"
  )

  mergedRatios <- mergedRatios[valueDenominator > 0]
  assertOrStop(
    nrow(mergedRatios) > 0,
    "Observed denominator values for PK ratios must be greater than zero"
  )

  mergedRatios[, ratioValue := valueNumerator / valueDenominator]

  mergedRatios[,
    .(
      N = .N,
      values = exp(mean(log(ratioValue))),
      errorValues = exp(stats::sd(log(ratioValue))),
      errorType = errorType,
      displayNamePKParameter = displayNamePKParameterNumerator[[1]],
      displayUnitPKParameter = "",
      dataClass = get("DATACLASS", inherits = TRUE)$pkAggregated,
      dataType = "observed"
    ),
    by = .(group = ratioGroup, pkParameter, outputPathId)
  ]
}

aggregateObservedPKPointEstimateRatioData <- function(
  dataObservedPK,
  numeratorSuffix = "_po$",
  denominatorSuffix = "_iv$",
  confLevel = 0.9,
  errorType = "geometric mean|90% CI lower|90% CI upper"
) {
  assertOrStop(
    data.table::is.data.table(dataObservedPK),
    "Observed PK data must be a data.table"
  )

  requiredColumns <- c(
    "scenario",
    "pkParameter",
    "individualId",
    "value",
    "outputPathId",
    "displayNamePKParameter",
    "displayUnitPKParameter"
  )
  missingColumns <- setdiff(requiredColumns, names(dataObservedPK))
  assertOrStop(
    length(missingColumns) == 0,
    paste(
      "Observed PK ratio data is missing required columns:",
      paste(missingColumns, collapse = ", ")
    )
  )

  dtObservedPK <- data.table::copy(dataObservedPK)
  dtObservedPK[, ratioGroup := sub("_(iv|po)$", "", scenario)]
  dtObservedPK[,
    arm := data.table::fifelse(
      grepl(numeratorSuffix, scenario),
      "numerator",
      data.table::fifelse(
        grepl(denominatorSuffix, scenario),
        "denominator",
        NA_character_
      )
    )
  ]

  numeratorDT <- dtObservedPK[arm == "numerator"]
  denominatorDT <- dtObservedPK[arm == "denominator"]

  assertOrStop(
    nrow(numeratorDT) > 0,
    "No observed numerator rows found for PK ratios"
  )
  assertOrStop(
    nrow(denominatorDT) > 0,
    "No observed denominator rows found for PK ratios"
  )

  mergedRatios <- merge(
    numeratorDT,
    denominatorDT,
    by = c("ratioGroup", "pkParameter", "individualId", "outputPathId"),
    suffixes = c("Numerator", "Denominator")
  )

  assertOrStop(
    nrow(mergedRatios) > 0,
    "No matching observed PO/IV pairs found for PK ratios"
  )

  mergedRatios <- mergedRatios[valueDenominator > 0]
  assertOrStop(
    nrow(mergedRatios) > 0,
    "Observed denominator values for PK ratios must be greater than zero"
  )

  mergedRatios[, ratioValue := valueNumerator / valueDenominator]
  alpha <- 1 - confLevel

  mergedRatios[,
    {
      logValues <- log(ratioValue[ratioValue > 0])
      nLog <- length(logValues)

      assertOrStop(
        nLog > 0,
        "Observed PK point-estimate ratio aggregation requires positive ratios"
      )

      meanLog <- mean(logValues)
      geometricMean <- exp(meanLog)

      if (nLog > 1) {
        sdLog <- stats::sd(logValues)
        stderrLog <- sdLog / sqrt(nLog)
        tValue <- stats::qt(1 - alpha / 2, df = nLog - 1)
        ciLower <- exp(meanLog - tValue * stderrLog)
        ciUpper <- exp(meanLog + tValue * stderrLog)
      } else {
        ciLower <- geometricMean
        ciUpper <- geometricMean
      }

      .(
        N = nLog,
        values = geometricMean,
        minValue = ciLower,
        maxValue = ciUpper,
        errorType = errorType,
        displayNamePKParameter = displayNamePKParameterNumerator[[1]],
        displayUnitPKParameter = "",
        dataClass = get("DATACLASS", inherits = TRUE)$pkAggregated,
        dataType = "observed"
      )
    },
    by = .(group = ratioGroup, pkParameter, outputPathId)
  ]
}
