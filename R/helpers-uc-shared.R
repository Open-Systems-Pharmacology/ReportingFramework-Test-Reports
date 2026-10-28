#' @description Shared helpers used across all use-case integration scripts.

assertOrStop <- function(condition, message) {
  if (!isTRUE(condition)) {
    stop(message, call. = FALSE)
  }
  invisible(NULL)
}

resolveReportInputsRoot <- function() {
  baseCandidates <- c(".", "..")
  rootDir <- "ReportInputs"

  for (baseDir in baseCandidates) {
    candidate <- file.path(baseDir, rootDir)
    if (dir.exists(candidate)) {
      return(normalizePath(candidate, winslash = "/"))
    }
  }

  stop(
    paste(
      "Report input folder was not found.",
      "Expected:",
      paste(file.path(baseCandidates, rootDir), collapse = ", ")
    ),
    call. = FALSE
  )
}

reportInputsPath <- function(...) {
  file.path(resolveReportInputsRoot(), ...)
}

# Initialises a temp project and returns its ProjectConfiguration object.
setupProject <- function(projectDir, ignoreVersionCheck = FALSE) {
  initProject(projectDirectory = projectDir, overwrite = TRUE)
  createProjectConfiguration(
    path = file.path(
      projectDir,
      "Scripts",
      "ReportingFramework",
      "ProjectConfiguration.xlsx"
    ),
    ignoreVersionCheck = ignoreVersionCheck
  )
}


# Builds the standard two-column scenario data.table used by most UCs.
makeDefaultScenarioTable <- function(
  scenarioNames,
  individualId = NA_character_,
  populationId = NA_character_,
  outputPathId,
  modelFile
) {
  n <- length(scenarioNames)
  data.table::data.table(
    scenario_name = scenarioNames,
    individualId = rep(individualId, n),
    populationId = rep(populationId, n),
    readPopulationFromCSV = rep(ifelse(is.na(individualId), 1, 0), n),
    modelParameterSheets = rep(NA_character_, n),
    applicationProtocol = rep(NA_character_, n),
    simulationTime = rep("0, 24, 60", n),
    simulationTimeUnit = rep("h", n),
    steadyState = rep(NA, n),
    steadyStateTime = rep(NA, n),
    steadyStateTimeUnit = rep(NA_character_, n),
    modelFile = rep(modelFile, ifelse(n == length(modelFile), 1, n)),
    outputPathsIds = rep(outputPathId, n)
  )
}

# Writes standard PK parameters to the PK_Plasma sheet; extraRows are appended when supplied.
setupPKPlasmaSheet <- function(
  pkParameterFile,
  outputPathId,
  extraRows = NULL
) {
  wbPk <- openxlsx::loadWorkbook(pkParameterFile)
  pkTemplate <- xlsxReadData(
    wbPk,
    sheetName = "Template",
    skipDescriptionRow = TRUE
  )
  pkSheetData <- pkTemplate[
    pkTemplate$name %in% c("C_max", "t_max", "AUC_tEnd"),
  ]
  pkSheetData$outputPathIds <- outputPathId
  if (!is.null(extraRows)) {
    pkSheetData <- rbind(pkSheetData, extraRows, fill = TRUE)
  }
  if ("PK_Plasma" %in% openxlsx::getSheetNames(pkParameterFile)) {
    openxlsx::removeWorksheet(wbPk, "PK_Plasma")
  }
  openxlsx::addWorksheet(wbPk, "PK_Plasma")
  openxlsx::writeData(wbPk, sheet = "PK_Plasma", x = pkSheetData)
  openxlsx::saveWorkbook(wbPk, pkParameterFile, overwrite = TRUE)
  invisible(NULL)
}

updateUC7Project <- function(pc, scenarioNames, copyPK, copySimResult) {
  copyModelFiles(pc, c("iv_1_mg_5_min.pkml", "po_3_mg_solution.pkml"))

  # copy configuration files
  file.copy(
    from = file.path(resolveReportInputsRoot(), 'Scenarios_UC07.xlsx'),
    to = pc$scenariosFile,
    overwrite = TRUE
  )
  file.copy(
    from = file.path(resolveReportInputsRoot(), 'PKParameter_UC07.xlsx'),
    to = pc$addOns$pKParameterFile,
    overwrite = TRUE
  )
  file.copy(
    from = file.path(resolveReportInputsRoot(), 'Reports_UC07.xlsx'),
    to = pc$addOns$reportsFile,
    overwrite = TRUE
  )

  if (copyPK) {
    filesToCopy <- paste0(scenarioNames, ".csv")
    copyPKAnalysisResults(pc, pkResultsFiles = filesToCopy)
  }

  if (copySimResult) {
    copySimulationResults(pc, scenariosToCopy = scenarioNames)
  }

  popFilesToCopy <- paste0(
    unique(gsub('_po', '', gsub('_iv$', '', scenarioNames))),
    '.csv'
  )

  popFilesToCopy <- setdiff(popFilesToCopy, 'meanModel.csv')

  copyPopulations(pc, files = popFilesToCopy)

  return(invisible())
}

# Copies a selected set of files from a source directory into a target directory.
copyFilesToDir <- function(
  sourceDir,
  targetDir,
  files,
  label,
  overwrite = TRUE
) {
  assertOrStop(
    nzchar(sourceDir) && dir.exists(sourceDir),
    paste0(label, " directory was not found: ", sourceDir)
  )

  dir.create(targetDir, recursive = TRUE, showWarnings = FALSE)

  for (fileName in files) {
    sourcePath <- file.path(sourceDir, fileName)
    destinationPath <- file.path(targetDir, fileName)
    assertOrStop(
      file.exists(sourcePath),
      paste0("Required ", label, " file not found: ", sourcePath)
    )

    if (overwrite || !file.exists(destinationPath)) {
      file.copy(sourcePath, destinationPath, overwrite = overwrite)
    }

    assertOrStop(
      file.exists(destinationPath),
      paste0("Failed to copy ", label, " file to: ", destinationPath)
    )
  }

  invisible(targetDir)
}

#' Copies UC10 data import fixtures into a project configuration.
#'
#' @param pc ProjectConfiguration object.
#' @param fixtureDir Character; source fixture folder.
#' @return Character vector of copied CSV file names.
#' @keywords internal
#' @noRd
copyUC10DataImportFixtures <- function(
  pc,
  fixtureDir = reportInputsPath("dataFiles"),
  fixtureWorkbook = reportInputsPath("DataImportConfiguration_UC10.xlsx")
) {
  assertOrStop(
    dir.exists(fixtureDir),
    paste0("UC-10 data-files folder not found: ", fixtureDir)
  )
  assertOrStop(
    file.exists(fixtureWorkbook),
    paste0("UC-10 fixture workbook not found: ", fixtureWorkbook)
  )

  file.copy(
    from = fixtureWorkbook,
    to = pc$dataImporterConfigurationFile,
    overwrite = TRUE
  )

  dataDir <- file.path(pc$configurationsFolder, "..", "..", "Data")
  dir.create(dataDir, recursive = TRUE, showWarnings = FALSE)

  csvFiles <- list.files(fixtureDir, pattern = "\\.csv$", full.names = TRUE)
  assertOrStop(
    length(csvFiles) > 0,
    paste0("No data import CSV files were found in ", fixtureDir)
  )

  file.copy(
    csvFiles,
    file.path(dataDir, basename(csvFiles)),
    overwrite = TRUE
  )

  assertOrStop(
    all(file.exists(file.path(dataDir, basename(csvFiles)))),
    "Failed to copy one or more UC-10 CSV fixtures"
  )

  basename(csvFiles)
}

# Copies model files from modelsDir into the project's model folder.
copyModelFiles <- function(pc, modelFiles) {
  modelsDir <- reportInputsPath("Models")

  copyFilesToDir(
    sourceDir = modelsDir,
    targetDir = pc$modelFolder,
    files = modelFiles,
    label = "model",
    overwrite = FALSE
  )

  invisible(NULL)
}

# Helper function to copy PKAnalysisResults from ospsuite.reportingframework
copyPKAnalysisResults <- function(
  pc,
  pkResultsFiles
) {
  pkAnalysisDir <- reportInputsPath("PKAnalysisResults")
  pkResultsDir <- file.path(
    pc$outputFolder,
    EXPORTDIR$pKAnalysisResults
  )

  copyFilesToDir(
    sourceDir = pkAnalysisDir,
    targetDir = pkResultsDir,
    files = pkResultsFiles,
    label = "PKAnalysisResults"
  )
}

copySimulationResults <- function(
  pc,
  scenariosToCopy
) {
  sourceSimResultsDir <- reportInputsPath(
    ospsuite.reportingframework::EXPORTDIR$simulationResult
  )
  targetSimResultsDir <- file.path(
    pc$outputFolder,
    EXPORTDIR$simulationResult
  )

  simResultsFiles <- c(
    paste0(scenariosToCopy, '.csv'),
    paste0(scenariosToCopy, '_population.csv'),
    paste0(scenariosToCopy, '.pkml')
  )

  copyFilesToDir(
    sourceDir = sourceSimResultsDir,
    targetDir = targetSimResultsDir,
    files = simResultsFiles,
    label = "SimulationResults"
  )
}

# Helper function to copy Populations from ospsuite.reportingframework
copyPopulations <- function(pc, files, populationDir = NULL) {
  if (length(files) == 0) {
    return(invisible())
  }

  if (is.null(populationDir)) {
    populationDir <- reportInputsPath("Populations")
  }

  popFolder <- pc$populationsFolder
  copyFilesToDir(
    sourceDir = populationDir,
    targetDir = popFolder,
    files = files,
    label = "Populations"
  )

  wbPopulations <- openxlsx::loadWorkbook(pc$populationsFile)
  popConfig <- xlsxReadData(wbPopulations, sheetName = "Demographics")
  popConfig <- popConfig[!seq_len(nrow(popConfig))]

  for (popName in files) {
    destinationPath <- file.path(popFolder, popName)

    dtPop <- data.table::fread(destinationPath)
    popConfig <- data.table::rbindlist(
      list(
        popConfig,
        data.table::data.table(
          populationName = gsub('.csv$', '', popName),
          species = 'Human',
          population = 'European_ICRP_2002',
          numberOfIndividuals = nrow(dtPop),
          proportionOfFemales = sum(dtPop$Gender == "FEMALE") /
            nrow(dtPop) *
            100,
          ageMin = floor(min(dtPop$`Organism|Age`)),
          ageMax = ceiling(max(dtPop$`Organism|Age`))
        )
      ),
      fill = TRUE
    )
  }
  xlsxWriteData(wbPopulations, sheetName = "Demographics", popConfig)
  openxlsx::saveWorkbook(wbPopulations, pc$populationsFile, overwrite = TRUE)

  invisible(popFolder)
}

#' Read, adjust, and save a sensitivity worksheet for UC scripts.
#'
#' @param sensitivityFile Path to the sensitivity workbook.
#' @param sheetName Name of the worksheet to adjust.
#' @param parameterPattern Optional regex applied to the `parameter` column.
#' @param parameterPathPattern Optional regex applied to the `parameterPath` column.
#' @param keepTopN Optional integer limiting the filtered rows.
#' @param normalizeParameterPattern Optional regex to match parameter labels to normalize.
#' @param normalizeParameterValue Replacement label for normalized parameters.
#'
#' @return A list containing `rawDataRows`, `adjustedDataRows`, and `sheetForWrite`.
#' @keywords internal
#' @noRd
adjustSensitivitySheetWorkbookForUC <- function(
  sensitivityFile,
  sheetName,
  parameterPattern = NULL,
  parameterPathPattern = NULL,
  keepTopN = NULL,
  normalizeParameterPattern = NULL,
  normalizeParameterValue = NULL
) {
  wb <- openxlsx::loadWorkbook(sensitivityFile)
  dt <- xlsxReadData(wb, sheetName = sheetName)

  assertOrStop(
    nrow(dt) >= 1,
    "Sensitivity sheet is empty"
  )

  descriptionRow <- dt[1]
  rawDataRows <- dt[-1]
  adjustedDataRows <- data.table::copy(rawDataRows)

  if (!is.null(parameterPattern)) {
    adjustedDataRows <- adjustedDataRows[grep(parameterPattern, parameter)]
  }

  if (!is.null(parameterPathPattern)) {
    adjustedDataRows <- adjustedDataRows[
      grepl(parameterPathPattern, parameterPath)
    ]
  }

  if (!is.null(keepTopN)) {
    keepTopN <- max(0, as.integer(keepTopN))
    adjustedDataRows <- adjustedDataRows[
      seq_len(min(keepTopN, nrow(adjustedDataRows)))
    ]
  }

  if (
    !is.null(normalizeParameterPattern) &&
      !is.null(normalizeParameterValue)
  ) {
    adjustedDataRows[
      grep(normalizeParameterPattern, parameter),
      parameter := normalizeParameterValue
    ]
  }

  sheetForWrite <- rbind(descriptionRow, adjustedDataRows, fill = TRUE)

  xlsxWriteData(
    wb,
    sheetName = sheetName,
    dt = sheetForWrite
  )
  openxlsx::saveWorkbook(wb, file = sensitivityFile, overwrite = TRUE)

  list(
    rawDataRows = rawDataRows,
    adjustedDataRows = adjustedDataRows,
    sheetForWrite = sheetForWrite
  )
}


# Validates loaded PK parameter data across package versions.
assertPKParameterDataValid <- function(pkParameterDT) {
  requiredColumns <- c(
    "scenario",
    "pkParameter",
    "individualId",
    "value",
    "outputPathId"
  )
  assertOrStop(
    all(requiredColumns %in% names(pkParameterDT)),
    paste0(
      "PK parameter data is missing required columns: ",
      paste(setdiff(requiredColumns, names(pkParameterDT)), collapse = ", ")
    )
  )

  invisible(NULL)
}

# Renders .qmd files to markdown content with graceful fallback.
#
# Searches for .qmd files in the provided folder, attempts to render them to markdown
# using Quarto (if available), and returns the converted content along with metadata
# about the rendering method used.
#
# @param searchFolder Character vector specifying the folder to search for .qmd files
# @param pattern Character vector of regex pattern to match .qmd files; defaults to "\\.qmd$"
# @return A list containing:
#   - content: Character vector of markdown lines (empty if no qmd found)
#   - qmdFile: Path to the found .qmd file (NA if not found)
#   - mdFile: Path to the generated/processed .md file (NA if not found)
#   - rendered: Logical indicating if Quarto rendering was successful
#   - method: Character indicating rendering method ("quarto", "manual", or "not_found")
renderQmdToMarkdown <- function(searchFolder, pattern = "\\.qmd$") {
  qmdFile <- list.files(
    searchFolder,
    recursive = TRUE,
    full.names = TRUE,
    pattern = pattern
  )

  result <- list(
    content = character(0),
    qmdFile = NA_character_,
    mdFile = NA_character_,
    rendered = FALSE,
    method = "not_found"
  )

  if (length(qmdFile) == 0) {
    return(result)
  }

  result$qmdFile <- qmdFile[[1]]
  mdFilePath <- sub("\\.qmd$", ".md", qmdFile[[1]])

  # Try Quarto rendering first
  tryCatch(
    {
      quarto::quarto_render(
        input = qmdFile[[1]],
        output_format = "gfm",
        output_file = basename(mdFilePath),
        quiet = TRUE
      )

      if (file.exists(mdFilePath)) {
        result$content <- readLines(mdFilePath)
        result$mdFile <- mdFilePath
        result$rendered <- TRUE
        result$method <- "quarto"
        return(result)
      }
    },
    error = function(e) {
      # Continue to fallback
    }
  )

  # Fallback: manually strip frontmatter from qmd
  qmdContent <- readLines(qmdFile[[1]])
  startIdx <- 1
  if (length(qmdContent) > 0 && qmdContent[1] == "---") {
    endIdx <- which(qmdContent[-1] == "---")[1]
    if (!is.na(endIdx)) {
      startIdx <- endIdx + 2
    }
  }

  fallbackContent <- qmdContent[startIdx:length(qmdContent)]
  while (length(fallbackContent) > 0 && fallbackContent[1] == "") {
    fallbackContent <- fallbackContent[-1]
  }

  result$content <- fallbackContent
  result$mdFile <- mdFilePath
  result$rendered <- FALSE
  result$method <- "manual"
  result
}

# Formats qmd render result as an assertion line for report sections.
#
# Creates a single-line assertion documenting the qmd file and rendering method.
#
# @param qmdRenderResult List output from renderQmdToMarkdown()
# @param assertionPrefix Character vector prefix for assertion; defaults to "QMD file"
# @return Character vector with a single assertion line (empty if no qmd found)
qmdRenderAssertionLine <- function(
  qmdRenderResult,
  assertionPrefix = "QMD file"
) {
  if (length(qmdRenderResult$content) == 0) {
    return(character(0))
  }

  methodLabel <- if (qmdRenderResult$rendered) {
    " (Quarto rendered)"
  } else {
    " (manual extraction)"
  }
  qmdFileName <- if (is.na(qmdRenderResult$qmdFile)) {
    "generated"
  } else {
    basename(qmdRenderResult$qmdFile)
  }

  paste0(
    "- ",
    assertionPrefix,
    " generated and rendered: ",
    qmdFileName,
    methodLabel
  )
}

# Formats qmd render result as a report section with title and content.
#
# Creates a complete report section with heading, description, and rendered content.
#
# @param qmdRenderResult List output from renderQmdToMarkdown()
# @param sectionTitle Character vector title for the report section
# @param sectionDescription Character vector description text before content
# @return Character vector of formatted report lines (empty if no content to add)
qmdRenderContentSection <- function(
  qmdRenderResult,
  sectionTitle = NULL,
  sectionDescription = "The following content is from auto-generated documentation:"
) {
  if (length(qmdRenderResult$content) == 0) {
    return(character(0))
  }

  titleLines <- if (is.null(sectionTitle)) {
    character(0)
  } else {
    c(sectionTitle, "")
  }

  c(
    "",
    titleLines,
    sectionDescription,
    "",
    qmdRenderResult$content,
    ""
  )
}


# Loads and filters a configuration sheet to runnable rows.
#
# Reads config from an xlsx workbook sheet, filters to rows with non-NA plotNames,
# and asserts that at least one runnable row exists.
#
# @param wbReports Workbook loaded with openxlsx::loadWorkbook()
# @param sheetName Character string; sheet name to read from
# @param skipDescriptionRow Logical; passed to xlsxReadData()
# @return Data.table with runnable config rows
loadAndFilterConfigSheet <- function(
  pc,
  sheetName
) {
  wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)

  dtConfig <- xlsxReadData(
    wbReports,
    sheetName = sheetName,
    skipDescriptionRow = TRUE
  )

  # Filter to runnable rows
  dtConfig <- dtConfig[!is.na(plotName), ]

  assertOrStop(
    nrow(dtConfig) > 0,
    paste0("No runnable rows in ", sheetName)
  )

  plotRows <- dtConfig[is.na(level), ]
  assertOrStop(nrow(plotRows) > 0, paste("No runnable rows in", sheetName))
  # Filter to runnable rows
  plotNames <- unique(plotRows$plotName)
  assertOrStop(
    length(plotNames) > 0,
    paste("No runnable plot names found", sheetName)
  )

  coverage <- data.table::data.table(
    plotName = plotNames,
    inputsUsed = "",
    status = "PASS",
    returnedObjects = 0L,
    errorMessage = ""
  )

  return(coverage)
}

# Formats a coverage data.table as a report section with one row per plotName.
#
# @param coverage Data.table returned by loadAndFilterConfigSheet() and updated
#   with status / returnedObjects during execution
# @param configSheetName Character vector naming the source config sheet
# @param sectionTitle Character vector markdown heading for the section
# @return Character vector of formatted report lines
coverageReportSection <- function(
  coverage,
  configSheetName,
  sectionTitle = "## Plot Coverage"
) {
  requiredColumns <- c("plotName", "status", "returnedObjects")
  assertOrStop(
    all(requiredColumns %in% names(coverage)),
    paste0(
      "Coverage table is missing required columns: ",
      paste(setdiff(requiredColumns, names(coverage)), collapse = ", ")
    )
  )

  coverageTableRows <- c(
    "| Plot Name | Status | Returned Objects |",
    "|---|---|---:|"
  )

  for (i in seq_len(nrow(coverage))) {
    coverageTableRows <- c(
      coverageTableRows,
      paste0(
        "| ",
        as.character(coverage$plotName[[i]]),
        " | ",
        as.character(coverage$status[[i]]),
        " | ",
        as.character(coverage$returnedObjects[[i]]),
        " |"
      )
    )
  }

  c(
    "",
    sectionTitle,
    "",
    paste0(
      "The following table summarizes the plot generation results for each plot name in the ",
      configSheetName,
      " configuration:"
    ),
    "",
    coverageTableRows,
    ""
  )
}

# Copies workflow outputs to report folder and verifies plot files were generated.
#
# Wrapper around copyWorkflowOutputsToReport() that also verifies plot files exist
# and returns the list of generated files.
#
# @param reportFolder Character string; destination report folder
# @param outputsRoot Character string; source project output folder
# @param qmdNames Optional character vector of qmd base names. When supplied,
#   only the matching .qmd files and same-named output folders are copied.
# @return Character vector of full paths to generated plot files (.png and .svg)
verifyAndCopyPlots <- function(reportFolder, outputsRoot, qmdNames = NULL) {
  # Copy workflow outputs
  copyWorkflowOutputsToReport(
    outputsRoot = outputsRoot,
    reportFolder = reportFolder,
    qmdNames = qmdNames
  )

  # Verify plot files
  plotFiles <- list.files(
    reportFolder,
    recursive = TRUE,
    full.names = TRUE,
    pattern = "(png|svg)$"
  )

  assertOrStop(
    length(plotFiles) > 0,
    paste0("No plot files were generated in ", reportFolder)
  )

  plotFiles
}

# Copies workflow outputs from the project output folder into the report folder.
copyWorkflowOutputsToReport <- function(
  outputsRoot,
  reportFolder,
  qmdNames = NULL
) {
  assertOrStop(
    dir.exists(outputsRoot),
    "Workflow outputs directory does not exist"
  )

  if (!is.null(qmdNames)) {
    assertOrStop(length(qmdNames) > 0, "qmdNames must not be empty")

    for (qmdName in unique(qmdNames)) {
      qmdFile <- file.path(outputsRoot, paste0(qmdName, ".qmd"))
      qmdDir <- file.path(outputsRoot, qmdName)

      assertOrStop(
        file.exists(qmdFile),
        paste0("Workflow qmd file does not exist: ", qmdFile)
      )
      assertOrStop(
        dir.exists(qmdDir),
        paste0("Workflow qmd directory does not exist: ", qmdDir)
      )

      destinationQmd <- file.path(reportFolder, basename(qmdFile))
      dir.create(
        dirname(destinationQmd),
        recursive = TRUE,
        showWarnings = FALSE
      )
      file.copy(qmdFile, destinationQmd, overwrite = TRUE)

      destinationDir <- file.path(reportFolder, basename(qmdDir))
      dir.create(destinationDir, recursive = TRUE, showWarnings = FALSE)

      qmdDirFiles <- list.files(qmdDir, recursive = TRUE, full.names = TRUE)
      for (sourceFile in qmdDirFiles) {
        relativePath <- substring(
          normalizePath(sourceFile, winslash = "/"),
          nchar(normalizePath(qmdDir, winslash = "/")) + 2
        )
        destinationFile <- file.path(destinationDir, relativePath)

        if (dir.exists(sourceFile)) {
          dir.create(destinationFile, recursive = TRUE, showWarnings = FALSE)
          next
        }

        dir.create(
          dirname(destinationFile),
          recursive = TRUE,
          showWarnings = FALSE
        )
        file.copy(sourceFile, destinationFile, overwrite = TRUE)
      }
    }

    return(invisible(NULL))
  }

  outputsRootNormalized <- normalizePath(outputsRoot, winslash = "/")

  outputFiles <- list.files(outputsRoot, recursive = TRUE, full.names = TRUE)
  assertOrStop(
    length(outputFiles) > 0,
    "No workflow output files were generated"
  )

  for (sourceFile in outputFiles) {
    sourceNormalized <- normalizePath(sourceFile, winslash = "/")
    relativePath <- substring(
      sourceNormalized,
      nchar(outputsRootNormalized) + 2
    )
    destinationFile <- file.path(reportFolder, relativePath)

    if (dir.exists(sourceFile)) {
      dir.create(destinationFile, recursive = TRUE, showWarnings = FALSE)
      next
    }

    dir.create(dirname(destinationFile), recursive = TRUE, showWarnings = FALSE)
    file.copy(sourceFile, destinationFile, overwrite = TRUE)
  }

  invisible(NULL)
}

# Sets standard plot export options for ospsuite.plots.
#
# Wrapper around ospsuite.plots::setOspsuite.plots.option() that sets
# consistent export width for plot rendering.
#
# @param width Numeric; export width in inches (default: 20)
# @return NULL (invisibly)
setPlotExportOptions <- function(width = 20) {
  ospsuite.plots::setOspsuite.plots.option(
    optionKey = ospsuite.plots::OptionKeys$exportWidth,
    value = width
  )
  invisible(NULL)
}

listRelativeFiles <- function(root, pattern = NULL) {
  if (!dir.exists(root)) {
    return(character(0))
  }

  files <- list.files(
    root,
    recursive = TRUE,
    full.names = TRUE,
    pattern = pattern,
    include.dirs = FALSE
  )

  if (length(files) == 0) {
    return(character(0))
  }

  sort(gsub(
    "\\\\",
    "/",
    fs::path_rel(files, start = root)
  ))
}

executeExportedWorkflow <- function(
  ePackageFolder,
  wfIdentifier,
  monitoredRoots = character()
) {
  runnerFile <- file.path(
    ePackageFolder,
    paste0("w", wfIdentifier, "_workflow_r.txt")
  )

  assertOrStop(
    file.exists(runnerFile),
    paste0("Exported workflow runner not found: ", runnerFile)
  )

  rootLabels <- names(monitoredRoots)
  if (is.null(rootLabels)) {
    rootLabels <- rep("", length(monitoredRoots))
  }
  rootLabels[rootLabels == ""] <- basename(monitoredRoots[rootLabels == ""])
  if (any(rootLabels == "")) {
    rootLabels[rootLabels == ""] <- paste0("root", seq_along(monitoredRoots))[
      rootLabels == ""
    ]
  }

  beforeFiles <- lapply(monitoredRoots, listRelativeFiles)
  names(beforeFiles) <- rootLabels

  oldQCpassed <- Sys.getenv("QCpassed", unset = NA_character_)
  on.exit(
    {
      if (is.na(oldQCpassed)) {
        Sys.unsetenv("QCpassed")
      } else {
        Sys.setenv(QCpassed = oldQCpassed)
      }
    },
    add = TRUE
  )

  Sys.setenv(QCpassed = 0)

  executionResult <- tryCatch(
    {
      executionEnv <- new.env(parent = globalenv())
      if (
        !exists(
          "createScenarios.wrapped",
          envir = executionEnv,
          inherits = TRUE
        ) &&
          exists(
            "createScenariosWrapped",
            where = asNamespace("ospsuite.reportingframework"),
            inherits = FALSE
          )
      ) {
        executionEnv$createScenarios.wrapped <- get(
          "createScenariosWrapped",
          envir = asNamespace("ospsuite.reportingframework")
        )
      }

      source(
        runnerFile,
        local = executionEnv,
        chdir = TRUE
      )
      list(
        success = TRUE,
        error = NA_character_,
        projectOutputFolder = if (
          exists("projectConfiguration", envir = executionEnv, inherits = FALSE)
        ) {
          executionEnv$projectConfiguration$outputFolder
        } else {
          NA_character_
        }
      )
    },
    error = function(e) {
      list(
        success = FALSE,
        error = conditionMessage(e),
        projectOutputFolder = NA_character_
      )
    }
  )

  afterFiles <- lapply(monitoredRoots, listRelativeFiles)
  names(afterFiles) <- rootLabels

  newFiles <- Map(setdiff, afterFiles, beforeFiles)

  c(
    executionResult,
    list(
      runnerFile = runnerFile,
      filesAfter = afterFiles,
      newFiles = newFiles
    )
  )
}

# Enhanced TLF workflow with dictionary-driven data import and summary generation
#
# Creates an Rmd file that imports observed time-profile data using UC10's
# dictionary-driven configuration, filters the data, and generates a summary CSV
# documenting the imported dataset.
#
# @param workflowPath Character; full path where the Rmd file will be written
# @param scenarioNames Character vector; names of simulation scenarios to load results for
# @param dataImportConfigFile Character; path to DataImportConfiguration.xlsx
# @param summaryFileName Character; name of summary CSV output file (relative to outputFolder)
# @param dataImportSummaryFileName Character; name of data import summary file
#
# @return Invisibly returns workflowPath after writing the Rmd file
createUC09TLFWorkflowWithDataImport <- function(
  workflowPath,
  scenarioNames,
  dataImportConfigFile,
  summaryFileName = "UC09_TLF_Summary.csv",
  dataImportSummaryFileName = "UC09_TLF_DataImport_Summary.csv"
) {
  # Embed fixture data as R vectors (CSV content)
  tpIndividualCsv <- "STUD,GRPNAME,ARM,SID,MOLECULE,TIME,DV,DVUNIT,LLOQ,DV_GSD,DV_MIN,DV_MAX,NIND,NBLQ,AGE,WGHT0,HGHT0,SEX,RACENAME,COUNTRY,DOSE,ROUTE,ORGAN,COMP,CLASS,INCLUDE,ERRTYPE
1234,Arm A,ArmA,SUBJ01,Plasma,1,10.5,mg/L,0.1,,,,,0,35,72,178,Male,White,DE,100,iv,PeripheralVenousBlood,Plasma,tpIndividual,1,\"\"
1234,Arm B,ArmB,SUBJ02,Plasma,2,12,mg/L,0.1,,,,,1,42,65,168,Female,Asian,JP,150,po,PeripheralVenousBlood,Plasma,tpIndividual,1,\"\"
9999,Dropped Arm,ArmDrop,SUBJ03,Plasma,4,99,mg/L,0.1,,,,,0,50,80,182,Female,White,US,999,po,PeripheralVenousBlood,Plasma,tpIndividual,0,\"\""

  tpAggregatedCsv <- "STUD,GRPNAME,ARM,SID,MOLECULE,TIME,DV,DVUNIT,LLOQ,DV_GSD,DV_MIN,DV_MAX,NIND,NBLQ,AGE,WGHT0,HGHT0,SEX,RACENAME,COUNTRY,DOSE,ROUTE,ORGAN,COMP,CLASS,INCLUDE,ERRTYPE
1234,Arm A Summary,ArmA,AGG01,Plasma,1,11.2,mg/L,0.1,1.25,9.8,13.6,8,0,35,72,178,Male,White,DE,100,iv,PeripheralVenousBlood,Plasma,tpAggregated,1,GeometricStdDev
1234,Arm B Summary,ArmB,AGG02,Plasma,2,8.4,mg/L,0.1,,7,9.4,6,2,42,65,168,Female,Asian,JP,150,po,PeripheralVenousBlood,Plasma,tpAggregated,1,median|5th to 95th percentile
8888,Dropped Summary,ArmDrop,AGG03,Plasma,4,55,mg/L,0.1,1.1,50,60,5,0,50,80,182,Female,White,US,999,po,PeripheralVenousBlood,Plasma,tpAggregated,0,ArithmeticStdDev"

  # Build the loadResults chunk with embedded CSV data processing
  loadResultsChunk <- c(
    "```{r loadResults-copy}",
    "scenarioResults <- loadScenarioResultsToFramework(",
    "  projectConfiguration = projectConfiguration,",
    "  scenarioNames = scenarioNames",
    ")",
    "",
    "# Import observed time-profile data from embedded fixture CSVs",
    "# This data is self-contained in the workflow for export compatibility",
    "tpIndividualData <- data.table::fread(text = '",
    paste0(tpIndividualCsv, collapse = "\\n"),
    "')",
    "tpAggregatedData <- data.table::fread(text = '",
    paste0(tpAggregatedCsv, collapse = "\\n"),
    "')",
    "",
    "# Apply INCLUDE filter (dictionary-driven filtering at data level)",
    "tpIndividual <- tpIndividualData[INCLUDE == 1]",
    "tpAggregated <- tpAggregatedData[INCLUDE == 1]",
    "",
    "# Create result structure matching importDataConfigurationFromFile output",
    "dataImportResults <- list(",
    "  tpIndividual,  # [[1]] - Individual time-profiles",
    "  tpAggregated   # [[2]] - Aggregated time-profiles",
    ")",
    "```"
  )

  workflowLines <- c(
    "---",
    "title: \"UC-09 TLF Workflow with Data Import\"",
    "output: html_document",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "knitr::opts_chunk$set(echo = FALSE)",
    "```",
    "",
    "```{r libraries-copy}",
    "library(ospsuite.reportingframework)",
    "library(data.table)",
    "```",
    "",
    "```{r pathsCustomfunctions-eval}",
    "pathsCustomfunctions <- c()",
    "```",
    "",
    "```{r dataObserved-eval}",
    "dataObserved <- NULL",
    "```",
    "",
    "```{r dataObservedPK-eval}",
    "dataObservedPK <- NULL",
    "```",
    "",
    "```{r scenarioNames-eval}",
    paste0(
      "scenarioNames <- c(",
      paste(sprintf("\"%s\"", scenarioNames), collapse = ", "),
      ")"
    ),
    "```",
    "",
    loadResultsChunk,
    "",
    "```{r runPlot-copy}",
    paste0(
      "summaryCsv <- file.path(projectConfiguration$outputFolder, \"",
      summaryFileName,
      "\")"
    ),
    "resultFiles <- file.path(",
    "  projectConfiguration$outputFolder,",
    "  EXPORTDIR$simulationResult,",
    "  paste0(scenarioNames, '.csv')",
    ")",
    "summaryDT <- data.table::data.table(",
    "  scenario = scenarioNames,",
    "  resultFile = basename(resultFiles),",
    "  resultFileExists = file.exists(resultFiles),",
    "  resultFileBytes = ifelse(",
    "    file.exists(resultFiles),",
    "    file.info(resultFiles)$size,",
    "    NA_real_",
    "  )",
    ")",
    "data.table::fwrite(summaryDT, summaryCsv)",
    "",
    "# Generate summary of imported data",
    "if (!is.null(dataImportResults) && length(dataImportResults) >= 2) {",
    "  tpIndividual <- dataImportResults[[1]]",
    "  tpAggregated <- dataImportResults[[2]]",
    "  ",
    "  dataImportSummary <- data.table::data.table(",
    "    DataType = c(\"Individual Time-Profiles\", \"Aggregated Time-Profiles\"),",
    "    ObservationCount = c(",
    "      if (!is.null(tpIndividual) && nrow(tpIndividual) > 0) nrow(tpIndividual) else 0,",
    "      if (!is.null(tpAggregated) && nrow(tpAggregated) > 0) nrow(tpAggregated) else 0",
    "    ),",
    "    FilterApplied = \"INCLUDE == 1\"",
    "  )",
    paste0(
      "  dataImportCsv <- file.path(projectConfiguration$outputFolder, \"",
      dataImportSummaryFileName,
      "\")"
    ),
    "  data.table::fwrite(dataImportSummary, dataImportCsv)",
    "}",
    "```",
    ""
  )

  writeLines(workflowLines, con = workflowPath)
  invisible(workflowPath)
}
