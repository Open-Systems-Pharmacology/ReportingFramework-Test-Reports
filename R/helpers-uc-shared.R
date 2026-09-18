#' @description Shared helpers used across all use-case integration scripts.

assertOrStop <- function(condition, message) {
  if (!isTRUE(condition)) {
    stop(message, call. = FALSE)
  }
  invisible(NULL)
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

# Copies modelFile from modelsDir into the project's model folder.
copyModelFile <- function(pc, modelFile, modelsDir = "Models") {
  sourceModelPath <- file.path(modelsDir, modelFile)
  targetModelPath <- fs::path_abs(modelFile, start = pc$modelFolder)
  assertOrStop(
    file.exists(sourceModelPath),
    paste0("Source model file not found: ", sourceModelPath)
  )
  if (!file.exists(targetModelPath)) {
    ignore <- file.copy(sourceModelPath, targetModelPath, overwrite = TRUE)
  }
  assertOrStop(
    file.exists(targetModelPath),
    paste0("Model file not found: ", targetModelPath)
  )
  invisible(NULL)
}

# Builds the standard two-column scenario data.table used by most UCs.
makeDefaultScenarioTable <- function(
  scenarioNames,
  individualId,
  outputPathId,
  modelFile
) {
  n <- length(scenarioNames)
  data.table::data.table(
    scenario_name = scenarioNames,
    individualId = rep(individualId, n),
    populationId = rep(NA_character_, n),
    readPopulationFromCSV = rep(NA, n),
    modelParameterSheets = rep(NA_character_, n),
    applicationProtocol = rep(NA_character_, n),
    simulationTime = rep("0, 24, 60", n),
    simulationTimeUnit = rep("h", n),
    steadyState = rep(NA, n),
    steadyStateTime = rep(NA, n),
    steadyStateTimeUnit = rep(NA_character_, n),
    modelFile = rep(modelFile, n),
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
  sectionTitle = "Generated Content Report",
  sectionDescription = "The following content is from auto-generated documentation:"
) {
  if (length(qmdRenderResult$content) == 0) {
    return(character(0))
  }

  c(
    "## ",
    sectionTitle,
    "",
    sectionDescription,
    "",
    qmdRenderResult$content,
    ""
  )
}
