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

# Fills missing displayName / displayUnit in the Outputs sheet with sensible defaults.
configureOutputsSheet <- function(pc) {
  wbReports <- openxlsx::loadWorkbook(pc$addOns$reportsFile)
  outputsSheet <- xlsxReadData(
    wbReports,
    sheetName = "Outputs",
    skipDescriptionRow = FALSE
  )
  missingDisplayNames <- is.na(outputsSheet$displayName) |
    trimws(as.character(outputsSheet$displayName)) == ""
  outputsSheet$displayName[missingDisplayNames] <-
    paste(as.character(outputsSheet$outputPathId[missingDisplayNames]), "disp")
  missingDisplayUnits <- is.na(outputsSheet$displayUnit) |
    trimws(as.character(outputsSheet$displayUnit)) == ""
  outputsSheet$displayUnit[missingDisplayUnits] <- "µg/l"
  xlsxWriteData(wbReports, sheetName = "Outputs", outputsSheet)
  openxlsx::saveWorkbook(wbReports, pc$addOns$reportsFile, overwrite = TRUE)
  invisible(NULL)
}

# Normalizes the copied UC07 PK_Plasma sheet to the molar units used by the
# checked-in PKAnalysisResults fixtures, avoiding model-based MW conversion.
configureUC7PKPlasmaSheet <- function(pc) {
  wbPk <- openxlsx::loadWorkbook(pc$addOns$pKParameterFile)
  pkSheet <- xlsxReadData(
    wbPk,
    sheetName = "PK_Plasma",
    skipDescriptionRow = FALSE
  )

  pkSheet$displayUnit[pkSheet$name == "C_max"] <- "µmol/l"
  pkSheet$displayUnit[pkSheet$name == "t_max"] <- "h"
  pkSheet$displayUnit[pkSheet$name == "AUC_tEnd"] <- "µmol*min/l"

  xlsxWriteData(wbPk, sheetName = "PK_Plasma", pkSheet)
  openxlsx::saveWorkbook(wbPk, pc$addOns$pKParameterFile, overwrite = TRUE)
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

  configureUC7PKPlasmaSheet(pc)

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
        "| ", as.character(coverage$plotName[[i]]),
        " | ", as.character(coverage$status[[i]]),
        " | ", as.character(coverage$returnedObjects[[i]]),
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
