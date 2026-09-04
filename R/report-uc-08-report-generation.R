#' @title report-uc-08-report-generation
#' @description
#' Integration scenario for UC-08 report generation using markdown helpers and mergeRmds.

rm(list = ls())
library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

reportFolder <- file.path("tests", "Reports", "UC-08-Report-Generation")
projectDir <- tempfile(pattern = "uc08_report_")
on.exit(unlink(projectDir, recursive = TRUE, force = TRUE), add = TRUE)

unlink(reportFolder, recursive = TRUE, force = TRUE)
dir.create(reportFolder, recursive = TRUE, showWarnings = FALSE)

pc <- setupProject(projectDir)
outputDir <- pc$outputFolder

# ---- markdown helper assertions -----------------------------------------------

tempMdFile <- tempfile(fileext = ".md")
on.exit(unlink(tempMdFile, force = TRUE), add = TRUE)

sink(tempMdFile, type = "output")
tryCatch(
    {
        mdHeading("Section One", level = 1, newlines = 1)
        mdPaste("Paragraph text.")
        mdNewline()
        mdBullet("first item", level = 1)
        mdBullet("second item", level = 1)
        mdBullet0("nested item", level = 2)
        mdHeading("Section Two", level = 2, newlines = 1)
        mdPaste0("inline text")
    },
    error = function(e) {
        sink(NULL, type = "output")
        stop(
            paste0("Markdown helper functions failed: ", e$message),
            call. = FALSE
        )
    }
)
sink(NULL, type = "output")

mdLines <- readLines(tempMdFile)
assertOrStop(length(mdLines) > 0, "Markdown helpers produced no output")
assertOrStop(
    any(grepl("# Section One", mdLines, fixed = TRUE)),
    "mdHeading level-1 missing"
)
assertOrStop(
    any(grepl("## Section Two", mdLines, fixed = TRUE)),
    "mdHeading level-2 missing"
)
assertOrStop(
    any(grepl("- first item", mdLines, fixed = TRUE)),
    "mdBullet() list item missing"
)

# ---- mergeRmds assertions -----------------------------------------------------

# Minimal source chapter required by mergeRmds() to verify file existence.
chapterFile <- file.path(outputDir, "Chapter01.qmd")
writeLines(c("# Chapter 1", "", "Minimal content."), con = chapterFile)
assertOrStop(file.exists(chapterFile), "Failed to create source chapter file")

mergeCall <- tryCatch(
    mergeRmds(
        newName = "merged_report",
        title = "UC-08 Merged Report",
        sourceRmds = "Chapter01",
        projectConfiguration = pc
    ),
    error = function(e) e
)
assertOrStop(
    !inherits(mergeCall, "error"),
    paste0("mergeRmds() failed: ", mergeCall$message)
)

mergedFile <- file.path(outputDir, "merged_report.qmd")
assertOrStop(file.exists(mergedFile), "mergeRmds() did not create output file")

mergedLines <- readLines(mergedFile)
assertOrStop(
    any(grepl("UC-08 Merged Report", mergedLines, fixed = TRUE)),
    "Title missing from merged file"
)
assertOrStop(
    any(grepl("Chapter01", mergedLines, fixed = TRUE)),
    "Source chapter not referenced in merged file"
)

# ---- report -------------------------------------------------------------------

writeLines(
    c(
        "# UC-08 Report generation",
        "",
        "## Summary",
        "",
        "Validates markdown helper functions and `mergeRmds()` Qmd composition.",
        "",
        "## Assertions",
        "",
        "- mdHeading(), mdPaste(), mdPaste0(), mdBullet(), mdBullet0(), mdNewline() completed without error.",
        "- Markdown output contains expected level-1 and level-2 headings.",
        "- Markdown output contains expected bulleted list items.",
        paste0(
            "- mergeRmds() created `",
            basename(mergedFile),
            "` without error."
        ),
        "- Merged file title matches supplied title.",
        "- Merged file includes source chapter reference.",
        "",
        "## Notes",
        "",
        "- renderWord() not exercised: requires pandoc/Word, unavailable in CI."
    ),
    con = file.path(reportFolder, "Report.md")
)
