library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")

projectDir <- file.path(getwd(), "tests", "tmp-uc09-tlf-project")
unlink(projectDir, recursive = TRUE, force = TRUE)
dir.create(projectDir, recursive = TRUE, showWarnings = FALSE)

pc <- setupProject(projectDir)
copyModelFiles(pc, "Aciclovir.pkml")

workflowQmd <- file.path(
    getwd(),
    "Reports",
    "UC-12-Plot-TimeProfiles-Tutorial",
    "TimeProfiles.qmd"
)

exportTLFWorkflowToEPackage(
    projectConfiguration = pc,
    wfIdentifier = 2,
    workflowRmd = workflowQmd
)

ePackageFolder <- pc$addOns$electronicPackageFolder
workflowFiles <- list.files(
    ePackageFolder,
    pattern = "^w[0-9]+_workflow_r\\.txt$",
    full.names = TRUE
)

cat("PROJECTDIR=", normalizePath(projectDir, winslash = "/"), "\n", sep = "")
cat("EPACKAGE=", normalizePath(ePackageFolder, winslash = "/"), "\n", sep = "")
cat("FILES:\n")
cat(
    paste(
        normalizePath(
            list.files(ePackageFolder, recursive = TRUE, full.names = TRUE),
            winslash = "/"
        ),
        collapse = "\n"
    )
)

if (length(workflowFiles) > 0) {
    cat("\n---WORKFLOW---\n")
    cat(paste(readLines(workflowFiles[[1]]), collapse = "\n"))
}
