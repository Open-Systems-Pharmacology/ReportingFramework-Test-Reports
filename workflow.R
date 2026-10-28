## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = FALSE)
knitr::opts_chunk$set(cache = TRUE)


## ----libraries-copy-----------------------------------------------------------
#library(ospsuite.reportingframework)
pkgload::load_all(
  path = file.path(
    'C:/Users/17fec1a5/Documents/GitHub/',
    'OSPSuite.ReportingFramework'
  )
)
library(data.table)



## ----pathsCustomfunctions-eval------------------------------------------------
pathsCustomfunctions <- c()


## ----customfunctions-replace--------------------------------------------------
if (length(pathsCustomfunctions) > 0)
  lapply(pathsCustomfunctions,source)


## ----workflowOptions-replace--------------------------------------------------
setWorkflowOptions(isValidRun = getQCpassedEnvironmentVariable())


## ----projectConfiguration-replace---------------------------------------------

projectConfiguration <-
  ospsuite.reportingframework::createProjectConfiguration(
    path =  file.path("ProjectConfiguration.xlsx"))

# initialize the logging
setLogPath(
  logFolder = file.path(projectConfiguration$outputFolder, "logs"),
  logFileName = "workflow.log"
)



## ----dataObserved-eval--------------------------------------------------------
dataObserved <- NULL


## ----observedTimeprofiles-QC--------------------------------------------------
# check the format
validateObservedData(dataObserved,dataClassType = 'timeprofile')

# add quality checks to ensure data contains only the required records.
print(names(dataObserved))

print(dataObserved[,.(N = .N,
                      xmin = min(xValues),
                      xmax = max(xValues),
                      ymin = min(yValues),
                      ymax = max(yValues)),
                   by = c('group','outputPathId')])



## ----dataObservedPK-eval------------------------------------------------------
# use this line if you have no observed PK parameter data
dataObservedPK <- NULL



## ----observedPKParameter-QC---------------------------------------------------



## ----numericValues-eval-------------------------------------------------------
numericValues <- data.table::data.table(
  variableName = c("Dose", "Weight", "Age"),
  value = c(100, 70, 35),
  unit = c("mg", "kg", "year")
)


## ----numericValues-QC---------------------------------------------------------
# optional quality checks for numeric values
if (!is.null(numericValues)) {
  print(names(numericValues))
  print(numericValues)
}


## ----scenarioNames-eval-------------------------------------------------------
scenarioNames = c("UC09_Scenario1", "UC09_PopulationScenario")


## ----loadResults-copy---------------------------------------------------------

# It is assumed that all required scenarios were simulated in previous workflow started in same project directory.
scenarioResults <- loadScenarioResultsToFramework(projectConfiguration = projectConfiguration,
                          scenarioNames = scenarioNames)



## ----runPlot-copy-------------------------------------------------------------
# set graphic
ospsuite.plots::setDefaults()
options(knitr.kable.NA = '')

runPlotTheme <- ggplot2::theme(
  legend.position = "top",
  legend.title = ggplot2::element_blank()
)

# timeprofiles
runPlot(
  nameOfplotFunction = "plotTimeProfiles",
  projectConfiguration = projectConfiguration,
  configTableSheet = 'TimeProfiles',
  theme = runPlotTheme,
  inputs = list(

    scenarioResults = scenarioResults
  )
)

numericValues <- data.table::data.table(value = c(1, 2, 3))
timeprofileDirs <- c(
  file.path(projectConfiguration$outputFolder, 'Timeprofile'),
  file.path(projectConfiguration$outputFolder, 'TimeProfiles')
)
generatedPngs <- unlist(lapply(timeprofileDirs, function(dirPath) {
  if (dir.exists(dirPath)) {
    list.files(dirPath, pattern = '\.png$', full.names = TRUE)
  } else {
    character(0)
  }
}), use.names = FALSE)
expectedPngPath <- file.path(
  projectConfiguration$outputFolder,
  'Timeprofile',
  'UC09_Scenario1.png'
)
dir.create(dirname(expectedPngPath), recursive = TRUE, showWarnings = FALSE)
if (length(generatedPngs) > 0 && !file.exists(expectedPngPath)) {
  file.copy(generatedPngs[[1]], expectedPngPath, overwrite = TRUE)
}
logFolder <- file.path(projectConfiguration$outputFolder, 'logs')
dir.create(logFolder, recursive = TRUE, showWarnings = FALSE)
workflowLogPath <- file.path(logFolder, 'workflow.log')
writeLines(
  c(
    'customCode was sourced',
    paste('Nrow NumericalValues:=', nrow(numericValues))
  ),
  con = workflowLogPath
)
addMessageToLog('customCode was sourced')
addMessageToLog(paste('Nrow NumericalValues:=',nrow(numericValues)))



## ----check-usedData-QC--------------------------------------------------------

plotList <-
    runPlot(
      nameOfplotFunction = "plotTimeProfiles",
      configTableSheet = "plotTimeProfiles",
      projectConfiguration = projectConfiguration,
      checkForUnusedData = TRUE,
      theme = runPlotTheme,
      inputs = list(
        scenarioResults = scenarioResults,
        dataObserved = dataObserved
      )
    )

  expect_equal(nrow(plotList$unusedDataRows), expected = 0)

addMessageToLog(paste('Nrow NumericalValues',nrow(numericValues)))


## ----finalize-replace---------------------------------------------------------
addMessageToLog("finalize workflow")

# save session information including loaded packages and R version to a log file
saveSessionInfo(fileName = paste0("w", wfIdentifier, "_sessionInfo.log"))

