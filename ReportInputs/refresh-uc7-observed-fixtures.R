rm(list = ls())

library(ospsuite.reportingframework)
source("R/helpers-uc-shared.R")
source("R/helpers-uc-observedData.R")

plasmaMolecularWeight <- 325.78

timeProfileObserved <- createObservedData(
  outputPathMap = c(
    Plasma = "Organism|PeripheralVenousBlood|DrugX|Plasma (Peripheral Venous Blood) [µmol/l]",
    CYP3A4total = "Organism|DrugX-CYP3A4-Optimized Metabolite|Total fraction of dose-DrugX",
    CYP3A4Liver = "Organism|Liver|Periportal|Intracellular|DrugX-CYP3A4-Optimized Metabolite|Fraction of dose-DrugX"
  ),
  scenarioNames = c("adults_iv", "adults_po"),
  simulationResultsDir = reportInputsPath("SimulationResults"),
  populationFile = reportInputsPath("Populations", "adults.csv"),
  plasmaMolecularWeight = plasmaMolecularWeight
)

data.table::fwrite(
  timeProfileObserved,
  file = reportInputsPath("UC7_observed_TP.csv")
)

pkObserved <- createObservedPKData(
  outputPathMap = c(
    Plasma = "Organism|PeripheralVenousBlood|DrugX|Plasma (Peripheral Venous Blood)"
  ),
  scenarioNames = c(
    "adolescents_iv",
    "adolescents_po",
    "children_iv",
    "children_po",
    "school_children_iv",
    "school_children_po",
    "toddler_iv",
    "toddler_po"
  ),
  pkAnalysisResultsDir = reportInputsPath("PKAnalysisResults"),
  pkParameters = c("AUC_tEnd", "t_max"),
  plasmaMolecularWeight = plasmaMolecularWeight
)

data.table::fwrite(
  pkObserved,
  file = reportInputsPath("UC7_observed_PK.csv")
)

cat(
  paste(
    "Refreshed UC7 observed fixtures:",
    "- ReportInputs/UC7_observed_TP.csv rows:",
    nrow(timeProfileObserved),
    "- ReportInputs/UC7_observed_PK.csv rows:",
    nrow(pkObserved),
    sep = "\n"
  ),
  "\n"
)
