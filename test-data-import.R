library(data.table)

tpIndividualData <- data.table::fread(text = 'STUD,GRPNAME,ARM,SID,MOLECULE,TIME,DV,DVUNIT,LLOQ,DV_GSD,DV_MIN,DV_MAX,NIND,NBLQ,AGE,WGHT0,HGHT0,SEX,RACENAME,COUNTRY,DOSE,ROUTE,ORGAN,COMP,CLASS,INCLUDE,ERRTYPE
1234,Arm A,ArmA,SUBJ01,Plasma,1,10.5,mg/L,0.1,,,,,0,35,72,178,Male,White,DE,100,iv,PeripheralVenousBlood,Plasma,tpIndividual,1,""
1234,Arm B,ArmB,SUBJ02,Plasma,2,12,mg/L,0.1,,,,,1,42,65,168,Female,Asian,JP,150,po,PeripheralVenousBlood,Plasma,tpIndividual,1,""
9999,Dropped Arm,ArmDrop,SUBJ03,Plasma,4,99,mg/L,0.1,,,,,0,50,80,182,Female,White,US,999,po,PeripheralVenousBlood,Plasma,tpIndividual,0,""')

cat("Loaded rows:", nrow(tpIndividualData), "\n")

tpIndividual <- tpIndividualData[INCLUDE == 1]
cat("Filtered rows (INCLUDE==1):", nrow(tpIndividual), "\n")

tpAggregatedData <- data.table::fread(text = 'STUD,GRPNAME,ARM,SID,MOLECULE,TIME,DV,DVUNIT,LLOQ,DV_GSD,DV_MIN,DV_MAX,NIND,NBLQ,AGE,WGHT0,HGHT0,SEX,RACENAME,COUNTRY,DOSE,ROUTE,ORGAN,COMP,CLASS,INCLUDE,ERRTYPE
1234,Arm A Summary,ArmA,AGG01,Plasma,1,11.2,mg/L,0.1,1.25,9.8,13.6,8,0,35,72,178,Male,White,DE,100,iv,PeripheralVenousBlood,Plasma,tpAggregated,1,GeometricStdDev
1234,Arm B Summary,ArmB,AGG02,Plasma,2,8.4,mg/L,0.1,,7,9.4,6,2,42,65,168,Female,Asian,JP,150,po,PeripheralVenousBlood,Plasma,tpAggregated,1,median|5th to 95th percentile
8888,Dropped Summary,ArmDrop,AGG03,Plasma,4,55,mg/L,0.1,1.1,50,60,5,0,50,80,182,Female,White,US,999,po,PeripheralVenousBlood,Plasma,tpAggregated,0,ArithmeticStdDev')

cat("Loaded aggregated rows:", nrow(tpAggregatedData), "\n")

tpAggregated <- tpAggregatedData[INCLUDE == 1]
cat("Filtered aggregated rows (INCLUDE==1):", nrow(tpAggregated), "\n")

# Test creating the result structure
dataImportResults <- list(
  tpIndividual,  # [[1]] - Individual time-profiles
  tpAggregated   # [[2]] - Aggregated time-profiles
)

cat("Result structure created with", length(dataImportResults), "elements\n")
if (!is.null(dataImportResults) && length(dataImportResults) >= 2) {
  cat("Summary: Individual rows =", nrow(dataImportResults[[1]]), "\n")
  cat("Summary: Aggregated rows =", nrow(dataImportResults[[2]]), "\n")
} else {
  cat("ERROR: dataImportResults is NULL or has fewer than 2 elements\n")
}
