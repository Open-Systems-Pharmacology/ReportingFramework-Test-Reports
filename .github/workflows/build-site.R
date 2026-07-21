#' @title build-site
#' @description
#' RScript to be used in github action
#' Temporary builds vignettes and index for pkgdown to build wanted website

#' @description
#' Creates the appropriate yaml configuration file for the pkgdown website
reportMapping <- jsonlite::fromJSON("tests/testthat/report-mapping.json")
hasReference <- reportMapping$Reference
websiteConfig <- c(
  "template:",
  "  bootstrap: 5",
  "",
  "home:",
  "  links:",
  "  - text: OSPSuite-R",
  "    href: https://www.open-systems-pharmacology.org/OSPSuite/",
  "  - text: OSP Suite Reporting Framework",
  "    href: https://www.open-systems-pharmacology.org/OSPSuite.ReportingFramework/",
  "",
  "navbar:",
  "  structure:",
  "    left:  [reports]",
  "    right: [search]",
  "  components:",
  "    reports:",
  "      text: Reports",
  "      menu:",
  paste0(
    "      - text: ",
    reportMapping$Report[hasReference],
    "\n",
    "        href: articles/", reportMapping$Report[hasReference], ".html"
  ),
  ""
)
writeLines(websiteConfig, con = "_pkgdown.yml")

#' @description
#' Prepare vignettes for articles section of the website
dir.create("vignettes")
for (reportFolder in reportMapping$Report) {
  file.copy(
    from = file.path("tests/Reports", reportFolder, "Report.md"),
    to = file.path("vignettes", paste0(reportFolder, ".Rmd")),
    overwrite = TRUE
  )
}

#' @description
#' Initialize website
#' Since the vignettes were created, article sections are prepared accordingly
pkgdown::init_site()

#' @description
#' Render reports as html articles for website
for (reportFolder in reportMapping$Report) {
  file.copy(
    from = list.files(file.path("tests/Reports", reportFolder), full.names = TRUE),
    to = "vignettes",
    overwrite = TRUE,
    recursive = TRUE
  )
  pkgdown::build_article(reportFolder)
  unlink("vignettes/images", recursive = TRUE)
}
# This line could build an index.html for article
# However, the navbar already covers it
# pkgdown::build_articles_index()

#' @description
#' Build home page
#' For home page, creates an index.md to provide only selectd information for website
readmeContent <- readLines("README.md")
toKeep <- grep(
  pattern = "## Using Reports and Scripts as template",
  readmeContent
)-1
# Insert in line 5 (after title, author and dates)
# Some text for the website
toInsert <- c(
  "",
  "## Welcome !",
  "",
  paste(
    "This website aims at providing a simple and easy way",
    "to look up available tested reports obtained from the OSP Suite Reporting Framework."
  ),
  "",
  "",
  paste(
    "More details on the test results and source R code are available in the",
    "[ReportingFramework-Test-Reports](https://github.com/Open-Systems-Pharmacology/ReportingFramework-Test-Reports) Github Repo."
  ),
  "",
  "## Results Overview",
  ""
)
readmeContent <- c(readmeContent[1:5], toInsert, readmeContent[6:toKeep])
writeLines(readmeContent, con = "index.md")
pkgdown::build_home()
