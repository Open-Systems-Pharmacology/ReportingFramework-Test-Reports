OSP Reporting Framework Test Reports
================
Open System Pharmacology
2026-08-31

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- 
Run testthat and get list of test results 
Note that "test_local" runs the scripts in ./R and then performs the tests
testResults includes a list per test script, which contains the following results
file, context, test, nb, failed, skipped, error, warning, user, system, real, passed, result
&#10;Turning the list to data.frame and extracting the relevant data will give a great overview of the test results
-->

| 📚 Total Reports | 🕵 Total Tests | ⚠ Failed Tests | 📊 Global Success Rate |
|------------------|---------------|----------------|------------------------|
| 11               | 642           | 495            | 22.9 %                 |

**Report execution status:** 0 of 11 reports passed (11 failed).

## Test Infrastructure

<details>

<summary>

Click to expand
</summary>

    ## R version 4.6.1 (2026-06-24 ucrt)
    ## Platform: x86_64-w64-mingw32/x64
    ## Running under: Windows Server 2022 x64 (build 26100)
    ## 
    ## Matrix products: default
    ##   LAPACK version 3.12.1
    ## 
    ## locale:
    ## [1] LC_COLLATE=English_United States.utf8 
    ## [2] LC_CTYPE=English_United States.utf8   
    ## [3] LC_MONETARY=English_United States.utf8
    ## [4] LC_NUMERIC=C                          
    ## [5] LC_TIME=English_United States.utf8    
    ## 
    ## time zone: UTC
    ## tzcode source: internal
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] testthat_3.3.2 dplyr_1.2.1   
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] vctrs_0.7.3      cli_3.6.6        knitr_1.51       rlang_1.3.0     
    ##  [5] xfun_0.60        stringi_1.8.9    otel_0.2.0       generics_0.1.4  
    ##  [9] jsonlite_2.0.0   glue_1.8.1       htmltools_0.5.9  brio_1.1.5      
    ## [13] rmarkdown_2.31   evaluate_1.0.5   tibble_3.3.1     fastmap_1.2.0   
    ## [17] yaml_2.3.12      lifecycle_1.0.5  stringr_1.6.0    compiler_4.6.1  
    ## [21] pkgconfig_2.0.3  digest_0.6.39    R6_2.6.1         tidyselect_1.2.1
    ## [25] pillar_1.11.1    magrittr_2.0.5   withr_3.0.3      tools_4.6.1

</details>

## Using Reports and Scripts as template

Users can find the reports and their description in the
[/Reports](./Reports) folder as well as the corresponding R code in the
[/R](./R) folder.

Repo-local inputs used by the report workflows are available in
[ReportInputs](./ReportInputs), including the
[Models](./ReportInputs/Models),
[PKAnalysisResults](./ReportInputs/PKAnalysisResults), and
[Populations](./ReportInputs/Populations) subfolders.

Here is the summary of the reports, their scripts and their run time
currently available in this repository:

| Use Case | Test Report | Script | Run Time |
|:---|:---|:---|:---|
| [UC-01-Project-Initialization](./Reports/UC-01-Project-Initialization) | [UC-01-Project-Initialization](./tests/Reports/UC-01-Project-Initialization/Report.md) | [report-uc-01-project-init.R](./R/report-uc-01-project-init.R) | NA |
| [UC-02-Scenario-Creation](./Reports/UC-02-Scenario-Creation) | [UC-02-Scenario-Creation](./tests/Reports/UC-02-Scenario-Creation/Report.md) | [report-uc-02-scenario-creation.R](./R/report-uc-02-scenario-creation.R) | NA |
| [UC-03-Scenario-Results-RoundTrip](./Reports/UC-03-Scenario-Results-RoundTrip) | [UC-03-Scenario-Results-RoundTrip](./tests/Reports/UC-03-Scenario-Results-RoundTrip/Report.md) | [report-uc-03-scenario-results-roundtrip.R](./R/report-uc-03-scenario-results-roundtrip.R) | NA |
| [UC-04-PK-Parameter-Loading](./Reports/UC-04-PK-Parameter-Loading) | [UC-04-PK-Parameter-Loading](./tests/Reports/UC-04-PK-Parameter-Loading/Report.md) | [report-uc-04-pk-parameter-loading.R](./R/report-uc-04-pk-parameter-loading.R) | NA |
| [UC-05-Population-Export](./Reports/UC-05-Population-Export) | [UC-05-Population-Export](./tests/Reports/UC-05-Population-Export/Report.md) | [report-uc-05-population-export.R](./R/report-uc-05-population-export.R) | NA |
| [UC-06-Utilities-Data-Integration](./Reports/UC-06-Utilities-Data-Integration) | [UC-06-Utilities-Data-Integration](./tests/Reports/UC-06-Utilities-Data-Integration/Report.md) | [report-uc-06-utilities-data-integration.R](./R/report-uc-06-utilities-data-integration.R) | NA |
| [UC-07A-Plot-TimeProfiles](./Reports/UC-07A-Plot-TimeProfiles) | [UC-07A-Plot-TimeProfiles](./tests/Reports/UC-07A-Plot-TimeProfiles/Report.md) | [report-uc-07a-plot-timeprofiles.R](./R/report-uc-07a-plot-timeprofiles.R) | NA |
| [UC-07B-Plot-PKBoxwhisker](./Reports/UC-07B-Plot-PKBoxwhisker) | [UC-07B-Plot-PKBoxwhisker](./tests/Reports/UC-07B-Plot-PKBoxwhisker/Report.md) | [report-uc-07b-plot-pk-boxwhisker.R](./R/report-uc-07b-plot-pk-boxwhisker.R) | NA |
| [UC-07C-Plot-PKForest-AggregatedAbsoluteValues](./Reports/UC-07C-Plot-PKForest-AggregatedAbsoluteValues) | [UC-07C-Plot-PKForest-AggregatedAbsoluteValues](./tests/Reports/UC-07C-Plot-PKForest-AggregatedAbsoluteValues/Report.md) | [report-uc-07c-plot-pk-forest-aggregated-absolute-values.R](./R/report-uc-07c-plot-pk-forest-aggregated-absolute-values.R) | NA |
| [UC-07D-Plot-PKForest-PointEstimateAbsolute](./Reports/UC-07D-Plot-PKForest-PointEstimateAbsolute) | [UC-07D-Plot-PKForest-PointEstimateAbsolute](./tests/Reports/UC-07D-Plot-PKForest-PointEstimateAbsolute/Report.md) | [report-uc-07d-plot-pk-forest-point-estimate-absolute.R](./R/report-uc-07d-plot-pk-forest-point-estimate-absolute.R) | NA |
| [UC-07E-Plot-PKForest-AggregatedRatios](./Reports/UC-07E-Plot-PKForest-AggregatedRatios) | [UC-07E-Plot-PKForest-AggregatedRatios](./tests/Reports/UC-07E-Plot-PKForest-AggregatedRatios/Report.md) | [report-uc-07e-plot-pk-forest-aggregated-ratios.R](./R/report-uc-07e-plot-pk-forest-aggregated-ratios.R) | NA |
| [UC-07F-Plot-PKForest-PointEstimateRatios](./Reports/UC-07F-Plot-PKForest-PointEstimateRatios) | [UC-07F-Plot-PKForest-PointEstimateRatios](./tests/Reports/UC-07F-Plot-PKForest-PointEstimateRatios/Report.md) | [report-uc-07f-plot-pk-forest-point-estimate-ratios.R](./R/report-uc-07f-plot-pk-forest-point-estimate-ratios.R) | NA |
| [UC-07G-Plot-Histograms](./Reports/UC-07G-Plot-Histograms) | [UC-07G-Plot-Histograms](./tests/Reports/UC-07G-Plot-Histograms/Report.md) | [report-uc-07g-plot-histograms.R](./R/report-uc-07g-plot-histograms.R) | NA |
| [UC-07H-Plot-DistributionVsDemographics](./Reports/UC-07H-Plot-DistributionVsDemographics) | [UC-07H-Plot-DistributionVsDemographics](./tests/Reports/UC-07H-Plot-DistributionVsDemographics/Report.md) | [report-uc-07h-plot-distribution-vs-demographics.R](./R/report-uc-07h-plot-distribution-vs-demographics.R) | NA |
| [UC-07I-Plot-CustomAnnotatedTimeProfiles](./Reports/UC-07I-Plot-CustomAnnotatedTimeProfiles) | [UC-07I-Plot-CustomAnnotatedTimeProfiles](./tests/Reports/UC-07I-Plot-CustomAnnotatedTimeProfiles/Report.md) | [report-uc-07i-plot-custom-annotated-timeprofiles.R](./R/report-uc-07i-plot-custom-annotated-timeprofiles.R) | NA |
| [UC-07-Generate-Compare-Results](./Reports/UC-07-Generate-Compare-Results) | [UC-07-Generate-Compare-Results](./tests/Reports/UC-07-Generate-Compare-Results/Report.md) | [report-uc-07-generate-and-compare-results.R](./R/report-uc-07-generate-and-compare-results.R) | NA |
| [UC-08-Report-Generation](./Reports/UC-08-Report-Generation) | [UC-08-Report-Generation](./tests/Reports/UC-08-Report-Generation/Report.md) | [report-uc-08-report-generation.R](./R/report-uc-08-report-generation.R) | NA |
| [UC-09-EPackage-Export](./Reports/UC-09-EPackage-Export) | [UC-09-EPackage-Export](./tests/Reports/UC-09-EPackage-Export/Report.md) | [report-uc-09-epackage-export.R](./R/report-uc-09-epackage-export.R) | NA |
| [UC-10-Sensitivity-Analysis](./Reports/UC-10-Sensitivity-Analysis) | [UC-10-Sensitivity-Analysis](./tests/Reports/UC-10-Sensitivity-Analysis/Report.md) | [report-uc-10-sensitivity-analysis.R](./R/report-uc-10-sensitivity-analysis.R) | NA |
| [UC-11-Snapshot-Version-Control](./Reports/UC-11-Snapshot-Version-Control) | [UC-11-Snapshot-Version-Control](./tests/Reports/UC-11-Snapshot-Version-Control/Report.md) | [report-uc-11-snapshot-version-control.R](./R/report-uc-11-snapshot-version-control.R) | NA |
| [UC-12-Plot-TimeProfiles-Tutorial](./Reports/UC-12-Plot-TimeProfiles-Tutorial) | [UC-12-Plot-TimeProfiles-Tutorial](./tests/Reports/UC-12-Plot-TimeProfiles-Tutorial/Report.md) | [report-uc-12-plot-timeprofiles-tutorial.R](./R/report-uc-12-plot-timeprofiles-tutorial.R) | NA |
| [UC-13-Data-Dictionary-Operations](./Reports/UC-13-Data-Dictionary-Operations) | [UC-13-Data-Dictionary-Operations](./tests/Reports/UC-13-Data-Dictionary-Operations/Report.md) | [report-uc-13-data-dictionary.R](./R/report-uc-13-data-dictionary.R) | NA |
| [UC-14-Word-Report-Rendering](./Reports/UC-14-Word-Report-Rendering) | [UC-14-Word-Report-Rendering](./tests/Reports/UC-14-Word-Report-Rendering/Report.md) | [report-uc-14-word-rendering.R](./R/report-uc-14-word-rendering.R) | NA |
| [UC-15-Legacy-Project-Upgrade](./Reports/UC-15-Legacy-Project-Upgrade) | [UC-15-Legacy-Project-Upgrade](./tests/Reports/UC-15-Legacy-Project-Upgrade/Report.md) | [report-uc-15-project-upgrade.R](./R/report-uc-15-project-upgrade.R) | NA |
| [UC-16-Calculation-Methods-Scenarios](./Reports/UC-16-Calculation-Methods-Scenarios) | [UC-16-Calculation-Methods-Scenarios](./tests/Reports/UC-16-Calculation-Methods-Scenarios/Report.md) | [report-uc-16-calc-methods-scenarios.R](./R/report-uc-16-calc-methods-scenarios.R) | NA |
| [UC-17-Per-Scenario-PK-Loading](./Reports/UC-17-Per-Scenario-PK-Loading) | [UC-17-Per-Scenario-PK-Loading](./tests/Reports/UC-17-Per-Scenario-PK-Loading/Report.md) | [report-uc-17-per-scenario-pk.R](./R/report-uc-17-per-scenario-pk.R) | NA |
| [UC-18-Excel-IO-Edge-Cases](./Reports/UC-18-Excel-IO-Edge-Cases) | [UC-18-Excel-IO-Edge-Cases](./tests/Reports/UC-18-Excel-IO-Edge-Cases/Report.md) | [report-uc-18-excel-io-edges.R](./R/report-uc-18-excel-io-edges.R) | NA |

## Detailed Test Results

| 📓 Report | 🔎 Test | 🚦 Status | ✅ Success | ⚠ Warning &<br>❌ Failed |
|:---|:---|:---|---:|---:|
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Expected Plots | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 6 |
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Expected<br>Sensitivity<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 6 | 0 |
| [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG) | Expected<br>Sensitivity<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected Plots | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 24 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected<br>Sensitivity<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 19 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 8 | 0 |
| [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption) | Expected Plots | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 2 |
| [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption) | Expected<br>Absorption<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance) | Expected Plots | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 10 |
| [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance) | Expected Mass<br>Balance Results | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 2 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected Plots | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 8 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected Plots | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 33 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 12 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected Plots | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 20 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 6 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected Plots | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 368 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 12 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected Plots | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 8 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected Plots | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 14 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected Mass<br>Balance Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected<br>Absorption<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-01-Project-Initialization](./tests/Reports/UC-01-Project-Initialization) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-01-Project-Initialization](./tests/Reports/UC-01-Project-Initialization) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-02-Scenario-Creation](./tests/Reports/UC-02-Scenario-Creation) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-02-Scenario-Creation](./tests/Reports/UC-02-Scenario-Creation) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-03-Scenario-Results-RoundTrip](./tests/Reports/UC-03-Scenario-Results-RoundTrip) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-03-Scenario-Results-RoundTrip](./tests/Reports/UC-03-Scenario-Results-RoundTrip) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-04-PK-Parameter-Loading](./tests/Reports/UC-04-PK-Parameter-Loading) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-04-PK-Parameter-Loading](./tests/Reports/UC-04-PK-Parameter-Loading) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-05-Population-Export](./tests/Reports/UC-05-Population-Export) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-05-Population-Export](./tests/Reports/UC-05-Population-Export) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-06-Utilities-Data-Integration](./tests/Reports/UC-06-Utilities-Data-Integration) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-06-Utilities-Data-Integration](./tests/Reports/UC-06-Utilities-Data-Integration) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07A-Plot-TimeProfiles](./tests/Reports/UC-07A-Plot-TimeProfiles) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07A-Plot-TimeProfiles](./tests/Reports/UC-07A-Plot-TimeProfiles) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07B-Plot-PKBoxwhisker](./tests/Reports/UC-07B-Plot-PKBoxwhisker) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07B-Plot-PKBoxwhisker](./tests/Reports/UC-07B-Plot-PKBoxwhisker) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07C-Plot-PKForest-AggregatedAbsoluteValues](./tests/Reports/UC-07C-Plot-PKForest-AggregatedAbsoluteValues) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07C-Plot-PKForest-AggregatedAbsoluteValues](./tests/Reports/UC-07C-Plot-PKForest-AggregatedAbsoluteValues) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07G-Plot-Histograms](./tests/Reports/UC-07G-Plot-Histograms) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07G-Plot-Histograms](./tests/Reports/UC-07G-Plot-Histograms) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-08-Report-Generation](./tests/Reports/UC-08-Report-Generation) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-08-Report-Generation](./tests/Reports/UC-08-Report-Generation) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
