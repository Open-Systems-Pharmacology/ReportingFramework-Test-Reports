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

Models, Observed and Simulated Data are respectively available in the
[Models](./Models) and [Data](./Data) folders.

Here is the summary of the reports, their scripts and their run time
currently available in this repository:

| Reference | Test Report | Script | Run Time |
|:---|:---|:---|:---|
| [Aciclovir-Mean](./Reports/Aciclovir-Mean) | [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean/Report.md) | [report-aciclovir-mean.R](./R/report-aciclovir-mean.R) | 0.5 min |
| [Aciclovir-Mean-SVG](./Reports/Aciclovir-Mean-SVG) | [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG/Report.md) | [report-aciclovir-mean-svg.R](./R/report-aciclovir-mean-svg.R) | 0.8 min |
| [Aciclovir-Population](./Reports/Aciclovir-Population) | [Aciclovir-Population](./tests/Reports/Aciclovir-Population/Report.md) | [report-aciclovir-population.R](./R/report-aciclovir-population.R) | 7.5 min |
| [Raltegravir-Absorption](./Reports/Raltegravir-Absorption) | [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption/Report.md) | [report-raltegravir-absorption.R](./R/report-raltegravir-absorption.R) | 0.9 min |
| [Raltegravir-Mass-Balance](./Reports/Raltegravir-Mass-Balance) | [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance/Report.md) | [report-raltegravir-mass-<br>balance.R](./R/report-raltegravir-mass-balance.R) | 1.5 min |
| [Test-NO7](./Reports/Test-NO7) | [Test-NO7](./tests/Reports/Test-NO7/Report.md) | [report-NO7.R](./R/report-NO7.R) | 0.3 min |
| [Test-NO8](./Reports/Test-NO8) | [Test-NO8](./tests/Reports/Test-NO8/Report.md) | [report-NO8.R](./R/report-NO8.R) | 0.8 min |
| [Test-NO9](./Reports/Test-NO9) | [Test-NO9](./tests/Reports/Test-NO9/Report.md) | [report-NO9.R](./R/report-NO9.R) | 1 min |
| [Test-NO10](./Reports/Test-NO10) | [Test-NO10](./tests/Reports/Test-NO10/Report.md) | [report-NO10.R](./R/report-NO10.R) | 6.4 min |
| [Test-NO11](./Reports/Test-NO11) | [Test-NO11](./tests/Reports/Test-NO11/Report.md) | [report-NO11.R](./R/report-NO11.R) | 0.4 min |
| [Test-NO12](./Reports/Test-NO12) | [Test-NO12](./tests/Reports/Test-NO12/Report.md) | [report-NO12.R](./R/report-NO12.R) | 0.8 min |
| [UC-01-Project-Initialization](./Reports/UC-01-Project-Initialization) | [UC-01-Project-Initialization](./tests/Reports/UC-01-Project-Initialization/Report.md) | [report-uc-01-project-init.R](./R/report-uc-01-project-init.R) | NA |
| [UC-02-Scenario-Creation](./Reports/UC-02-Scenario-Creation) | [UC-02-Scenario-Creation](./tests/Reports/UC-02-Scenario-Creation/Report.md) | [report-uc-02-scenario-creation.R](./R/report-uc-02-scenario-creation.R) | NA |
| [UC-03-Scenario-Results-RoundTrip](./Reports/UC-03-Scenario-Results-RoundTrip) | [UC-03-Scenario-Results-RoundTrip](./tests/Reports/UC-03-Scenario-Results-RoundTrip/Report.md) | [report-uc-03-scenario-results-roundtrip.R](./R/report-uc-03-scenario-results-roundtrip.R) | NA |
| [UC-04-PK-Parameter-Loading](./Reports/UC-04-PK-Parameter-Loading) | [UC-04-PK-Parameter-Loading](./tests/Reports/UC-04-PK-Parameter-Loading/Report.md) | [report-uc-04-pk-parameter-loading.R](./R/report-uc-04-pk-parameter-loading.R) | NA |
| [UC-05-Population-Export](./Reports/UC-05-Population-Export) | [UC-05-Population-Export](./tests/Reports/UC-05-Population-Export/Report.md) | [report-uc-05-population-export.R](./R/report-uc-05-population-export.R) | NA |
| [UC-06-Utilities-Data-Integration](./Reports/UC-06-Utilities-Data-Integration) | [UC-06-Utilities-Data-Integration](./tests/Reports/UC-06-Utilities-Data-Integration/Report.md) | [report-uc-06-utilities-data-integration.R](./R/report-uc-06-utilities-data-integration.R) | NA |
| [UC-07A-Plot-TimeProfiles](./Reports/UC-07A-Plot-TimeProfiles) | [UC-07A-Plot-TimeProfiles](./tests/Reports/UC-07A-Plot-TimeProfiles/Report.md) | [report-uc-07a-plot-timeprofiles.R](./R/report-uc-07a-plot-timeprofiles.R) | NA |
| [UC-07B-Plot-PKBoxwhisker](./Reports/UC-07B-Plot-PKBoxwhisker) | [UC-07B-Plot-PKBoxwhisker](./tests/Reports/UC-07B-Plot-PKBoxwhisker/Report.md) | [report-uc-07b-plot-pk-boxwhisker.R](./R/report-uc-07b-plot-pk-boxwhisker.R) | NA |
| [UC-07C-Plot-PKForest](./Reports/UC-07C-Plot-PKForest) | [UC-07C-Plot-PKForest](./tests/Reports/UC-07C-Plot-PKForest/Report.md) | [report-uc-07c-plot-pk-forest.R](./R/report-uc-07c-plot-pk-forest.R) | NA |
| [UC-07D-Plot-Demographics](./Reports/UC-07D-Plot-Demographics) | [UC-07D-Plot-Demographics](./tests/Reports/UC-07D-Plot-Demographics/Report.md) | [report-uc-07d-plot-demographics.R](./R/report-uc-07d-plot-demographics.R) | NA |
| [UC-08-Report-Generation](./Reports/UC-08-Report-Generation) | [UC-08-Report-Generation](./tests/Reports/UC-08-Report-Generation/Report.md) | [report-uc-08-report-generation.R](./R/report-uc-08-report-generation.R) | NA |
| [UC-09-EPackage-Export](./Reports/UC-09-EPackage-Export) | [UC-09-EPackage-Export](./tests/Reports/UC-09-EPackage-Export/Report.md) | [report-uc-09-epackage-export.R](./R/report-uc-09-epackage-export.R) | NA |
| [UC-10-Sensitivity-Analysis](./Reports/UC-10-Sensitivity-Analysis) | [UC-10-Sensitivity-Analysis](./tests/Reports/UC-10-Sensitivity-Analysis/Report.md) | [report-uc-10-sensitivity-analysis.R](./R/report-uc-10-sensitivity-analysis.R) | NA |
| [UC-11-Snapshot-Version-Control](./Reports/UC-11-Snapshot-Version-Control) | [UC-11-Snapshot-Version-Control](./tests/Reports/UC-11-Snapshot-Version-Control/Report.md) | [report-uc-11-snapshot-version-control.R](./R/report-uc-11-snapshot-version-control.R) | NA |

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
| [UC-07C-Plot-PKForest](./tests/Reports/UC-07C-Plot-PKForest) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07C-Plot-PKForest](./tests/Reports/UC-07C-Plot-PKForest) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07D-Plot-Demographics](./tests/Reports/UC-07D-Plot-Demographics) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-07D-Plot-Demographics](./tests/Reports/UC-07D-Plot-Demographics) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-08-Report-Generation](./tests/Reports/UC-08-Report-Generation) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [UC-08-Report-Generation](./tests/Reports/UC-08-Report-Generation) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
