# Load a single worksheet through the package xlsx reader --------
#
# Reads a worksheet only when it exists. Missing worksheets are returned as NULL
# so callers can decide whether absence is valid or should fail validation.
loadSheetData <- function(workbookPath, sheetName, skipDescriptionRow = FALSE) {
  if (!(sheetName %in% openxlsx::getSheetNames(workbookPath))) {
    return(NULL)
  }

  workbook <- openxlsx::loadWorkbook(workbookPath)
  suppressWarnings(
    ospsuite.reportingframework::xlsxReadData(
      workbook,
      sheetName = sheetName,
      skipDescriptionRow = skipDescriptionRow
    )
  )
}


# Load a worksheet from an already opened workbook --------
#
# The refresh loop keeps both workbooks open and saves only once at the end.
# This helper mirrors loadSheetData() for workbook objects instead of file paths.
loadSheetDataFromWorkbook <- function(
  workbook,
  sheetName,
  skipDescriptionRow = FALSE
) {
  if (!(sheetName %in% names(workbook))) {
    return(NULL)
  }

  suppressWarnings(
    ospsuite.reportingframework::xlsxReadData(
      workbook,
      sheetName = sheetName,
      skipDescriptionRow = skipDescriptionRow
    )
  )
}


# Align preserved data to the refreshed template columns --------
#
# The refreshed package workbook can introduce new columns. This helper keeps the
# preserved repo-local data in template order and fills any new template columns
# with NA so xlsxWriteData can write a shape compatible with the updated file.
alignToTemplateColumns <- function(sourceData, templateData) {
  if (is.null(sourceData)) {
    return(templateData[0])
  }

  aligned <- data.table::copy(sourceData)
  missingColumns <- setdiff(names(templateData), names(aligned))
  for (columnName in missingColumns) {
    aligned[[columnName]] <- NA
  }

  aligned[, names(templateData), with = FALSE]
}


# Write data below an existing description row --------
#
# Reports and PKParameter sheets keep row 1 as headers and row 2 as descriptions.
# This helper clears the existing data area below those rows and writes only the
# data payload starting at row 3, leaving the template header and description in
# place.
writeDataBelowDescriptionRow <- function(workbook, sheetName, dataToWrite) {
  existingRaw <- openxlsx::readWorkbook(
    workbook,
    sheet = sheetName,
    colNames = FALSE
  )

  maxCols <- max(ncol(existingRaw), ncol(dataToWrite))
  maxRows <- max(nrow(existingRaw), nrow(dataToWrite) + 2)

  if (maxRows >= 3 && maxCols > 0) {
    openxlsx::deleteData(
      workbook,
      sheet = sheetName,
      cols = seq_len(maxCols),
      rows = 3:maxRows,
      gridExpand = TRUE
    )
  }

  if (nrow(dataToWrite) > 0 && ncol(dataToWrite) > 0) {
    openxlsx::writeData(
      workbook,
      sheet = sheetName,
      x = dataToWrite,
      startRow = 3,
      colNames = FALSE,
      keepNA = FALSE
    )
  }

  invisible(sheetName)
}


# Overwrite a target worksheet with preserved repo-local data --------
#
# The target workbook is expected to already contain the refreshed template sheet.
# This function reads the template shape from that workbook, aligns preserved data
# to it, and writes the aligned table back to the same sheet.
overlaySheetData <- function(workbookPath, sheetName, sourceData) {
  templateData <- loadSheetData(workbookPath, sheetName = sheetName)
  assertOrStop(
    !is.null(templateData),
    paste0("Target sheet was not found in refreshed workbook: ", sheetName)
  )

  workbook <- openxlsx::loadWorkbook(workbookPath)
  alignedData <- alignToTemplateColumns(sourceData, templateData)
  ospsuite.reportingframework::xlsxWriteData(
    workbook,
    sheetName = sheetName,
    dt = alignedData
  )
  openxlsx::saveWorkbook(workbook, workbookPath, overwrite = TRUE)
}


# Recreate a custom worksheet that does not exist in the base template --------
#
# PK_Plasma is repo-specific and is not present in the generated package workbook.
# It is recreated from scratch using the preserved repo-local data.
writeCustomPKSheet <- function(workbookPath, sheetName, sourceData) {
  workbook <- openxlsx::loadWorkbook(workbookPath)
  if (sheetName %in% openxlsx::getSheetNames(workbookPath)) {
    openxlsx::removeWorksheet(workbook, sheetName)
  }
  openxlsx::addWorksheet(workbook, sheetName)
  openxlsx::writeData(workbook, sheet = sheetName, x = sourceData)
  openxlsx::saveWorkbook(workbook, workbookPath, overwrite = TRUE)
}


# Clone a package template worksheet under a UC07-specific sheet name --------
#
# Several UC07 sheets are specialized copies of framework-owned base sheets. The
# clone keeps the updated workbook formatting and structure before local data is
# written back over the cloned sheet.
cloneTemplateSheet <- function(
  workbookPath,
  templateSheetName,
  targetSheetName
) {
  workbook <- openxlsx::loadWorkbook(workbookPath)
  currentSheets <- openxlsx::getSheetNames(workbookPath)

  assertOrStop(
    templateSheetName %in% currentSheets,
    paste0(
      "Template sheet ",
      templateSheetName,
      " was not found in refreshed workbook"
    )
  )

  if (targetSheetName %in% currentSheets) {
    openxlsx::removeWorksheet(workbook, targetSheetName)
  }

  openxlsx::cloneWorksheet(
    workbook,
    sheetName = targetSheetName,
    clonedSheet = templateSheetName
  )
  openxlsx::saveWorkbook(workbook, workbookPath, overwrite = TRUE)
}


# Assert that required worksheets are present after refresh --------
#
# This is a narrow structural validation step before the refreshed binaries are
# copied back into ReportInputs.
verifyWorkbookSheetNames <- function(workbookPath, expectedSheets) {
  actualSheets <- openxlsx::getSheetNames(workbookPath)
  missingSheets <- setdiff(expectedSheets, actualSheets)

  assertOrStop(
    length(missingSheets) == 0,
    paste0(
      "Workbook ",
      basename(workbookPath),
      " is missing expected sheets: ",
      paste(missingSheets, collapse = ", ")
    )
  )

  invisible(actualSheets)
}


# Build the ReportInputs target workbook paths --------

# Create staged copies of freshly generated package workbooks --------
#
# The refresh is performed in a staging directory so ReportInputs is not modified
# until every workbook has been rebuilt and validated successfully.
stageGeneratedUC7Workbooks <- function(targetFiles, stageDir) {
  projectDir <- tempfile(pattern = "uc07_xlsx_refresh_")
  on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

  pc <- setupProject(projectDir, ignoreVersionCheck = TRUE)

  generatedFiles <- c(
    Scenarios = pc$scenariosFile,
    Reports = pc$addOns$reportsFile,
    PKParameter = pc$addOns$pKParameterFile
  )

  for (fileKey in names(generatedFiles)) {
    sourcePath <- generatedFiles[[fileKey]]
    targetPath <- file.path(stageDir, basename(targetFiles[[fileKey]]))
    assertOrStop(
      file.exists(sourcePath),
      paste0("Generated workbook not found: ", sourcePath)
    )
    file.copy(sourcePath, targetPath, overwrite = TRUE)
    generatedFiles[[fileKey]] <- targetPath
  }

  generatedFiles
}


# Copy one worksheet's data from the checked-in target workbook --------
#
# Same-name sheets are written in place. Mapped target sheets are cloned from the
# generated template sheet before their preserved repo-local data is written.
copyTargetSheetData <- function(
  generatedWorkbook,
  targetWorkbook,
  sourceSheetName,
  destinationSheetName = sourceSheetName,
  templateSheetName = destinationSheetName,
  skipDescriptionRow = FALSE,
  cloneTemplate = FALSE
) {
  sourceData <- loadSheetDataFromWorkbook(
    targetWorkbook,
    sheetName = sourceSheetName,
    skipDescriptionRow = skipDescriptionRow
  )
  assertOrStop(
    !is.null(sourceData),
    paste0(
      "Source sheet was not found in target workbook: ",
      sourceSheetName
    )
  )

  if (cloneTemplate) {
    if (destinationSheetName %in% names(generatedWorkbook)) {
      openxlsx::removeWorksheet(generatedWorkbook, destinationSheetName)
    }
    openxlsx::cloneWorksheet(
      generatedWorkbook,
      sheetName = destinationSheetName,
      clonedSheet = templateSheetName
    )
  }

  templateData <- loadSheetDataFromWorkbook(
    generatedWorkbook,
    sheetName = destinationSheetName,
    skipDescriptionRow = skipDescriptionRow
  )
  assertOrStop(
    !is.null(templateData),
    paste0(
      "Destination sheet was not found in generated workbook: ",
      destinationSheetName
    )
  )

  alignedData <- alignToTemplateColumns(sourceData, templateData)

  if (skipDescriptionRow) {
    writeDataBelowDescriptionRow(
      workbook = generatedWorkbook,
      sheetName = destinationSheetName,
      dataToWrite = alignedData
    )
  } else {
    ospsuite.reportingframework::xlsxWriteData(
      generatedWorkbook,
      sheetName = destinationSheetName,
      dt = alignedData
    )
  }

  invisible(destinationSheetName)
}


# Return workbook-specific settings from the runner --------
#
# The runner owns workbook configuration so this helper only resolves and
# validates the requested settings for the current workbook.
getWorkbookSettings <- function(settings, workbookName) {
  workbookSettings <- settings[[workbookName]]

  assertOrStop(
    !is.null(workbookSettings),
    paste0("Missing settings for workbook: ", workbookName)
  )

  workbookSettings
}


# Ignore internal workbook sheets when warning about missing targets --------
#
# Generated framework workbooks can contain hidden support sheets such as
# _Validity that are not part of the checked-in UC07 workbook fixtures.
shouldWarnOnMissingSheet <- function(sheetName) {
  !startsWith(sheetName, "_")
}

# Refresh all staged UC07 workbooks through one common loop --------
#
# For each workbook, load the staged generated file and the checked-in target
# file, walk the generated sheets, copy same-name sheet data when available, and
# expand mapped custom sheets where required. Reports template plot sheets are
# removed after their UC07-specific clones have been populated.
refreshUC7Workbook <- function(
  generatedFiles,
  targetFiles,
  settings
) {
  for (workbookName in names(targetFiles)) {
    generatedFile <- generatedFiles[[workbookName]]
    targetFile <- targetFiles[[workbookName]]
    generatedWorkbook <- openxlsx::loadWorkbook(generatedFile)
    targetWorkbook <- openxlsx::loadWorkbook(targetFile)

    generatedSheetNames <- names(generatedWorkbook)
    targetSheetNames <- names(targetWorkbook)
    workbookSettings <- getWorkbookSettings(settings, workbookName)
    skipDescriptionRow <- isTRUE(workbookSettings$hasDescriptionRow)
    workbookSheetMap <- workbookSettings$customReportSheetMap
    if (is.null(workbookSheetMap)) {
      workbookSheetMap <- character(0)
    }
    deleteMappedTemplateSheets <- isTRUE(
      workbookSettings$shouldDeleteMappedTemplateSheets
    )

    sheetsToDelete <- character(0)

    # never overwrite the hidden Validity sheet used
    for (generatedSheetName in setdiff(generatedSheetNames, "_Validity")) {
      sameSheetExists <- generatedSheetName %in% targetSheetNames
      mappedTargetSheets <- names(workbookSheetMap)[
        workbookSheetMap == generatedSheetName
      ]

      if (sameSheetExists) {
        copyTargetSheetData(
          generatedWorkbook = generatedWorkbook,
          targetWorkbook = targetWorkbook,
          sourceSheetName = generatedSheetName,
          destinationSheetName = generatedSheetName,
          skipDescriptionRow = skipDescriptionRow
        )
      }

      if (length(mappedTargetSheets) > 0) {
        mappedTargetsFound <- intersect(
          mappedTargetSheets,
          targetSheetNames
        )

        if (length(mappedTargetsFound) == 0) {
          warning(
            paste0(
              "No mapped target sheet found for generated sheet ",
              generatedSheetName,
              " in ",
              basename(targetFile)
            ),
            call. = FALSE
          )
        }

        for (targetSheetName in mappedTargetsFound) {
          copyTargetSheetData(
            generatedWorkbook = generatedWorkbook,
            targetWorkbook = targetWorkbook,
            sourceSheetName = targetSheetName,
            destinationSheetName = targetSheetName,
            templateSheetName = generatedSheetName,
            skipDescriptionRow = skipDescriptionRow,
            cloneTemplate = TRUE
          )
        }

        if (deleteMappedTemplateSheets) {
          sheetsToDelete <- c(sheetsToDelete, generatedSheetName)
        }
      }

      if (
        !sameSheetExists &&
          length(mappedTargetSheets) == 0 &&
          shouldWarnOnMissingSheet(generatedSheetName)
      ) {
        warning(
          paste0(
            "Sheet ",
            generatedSheetName,
            " was not found in ",
            basename(targetFile)
          ),
          call. = FALSE
        )
      }
    }

    if (length(sheetsToDelete) > 0) {
      for (sheetName in unique(sheetsToDelete)) {
        if (sheetName %in% names(generatedWorkbook)) {
          openxlsx::removeWorksheet(generatedWorkbook, sheetName)
        }
      }
    }

    openxlsx::saveWorkbook(
      generatedWorkbook,
      generatedFile,
      overwrite = TRUE
    )
  }

  invisible(generatedFiles)
}


# Copy staged workbooks back into ReportInputs --------
publishUC7Workbooks <- function(generatedFiles, targetFiles) {
  for (fileKey in names(targetFiles)) {
    file.copy(
      generatedFiles[[fileKey]],
      targetFiles[[fileKey]],
      overwrite = TRUE
    )
  }

  invisible(targetFiles)
}


# Print a concise runner summary --------
printUC7WorkbookRefreshSummary <- function(targetFiles) {
  cat("Refreshed UC07 workbook fixtures from generated package templates:\n")
  cat(paste0("- ", basename(unname(targetFiles))), sep = "\n")
  cat("\n")
}
