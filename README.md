OSP Reporting Framework Test Reports
================
Open System Pharmacology
2026-11-13

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
| 20               | 0             | 0              | 0 %                    |

**Report execution status:** 0 of 20 reports passed (20 failed).

## Test Infrastructure

<details>

<summary>

Click to expand
</summary>

    ## R version 4.6.2 (2026-10-29 ucrt)
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
    ##  [1] digest_0.6.39    R6_2.6.1         fastmap_1.2.0    tidyselect_1.2.1
    ##  [5] xfun_0.62        magrittr_2.0.5   glue_1.8.1       tibble_3.3.1    
    ##  [9] knitr_1.52       pkgconfig_2.0.3  htmltools_0.5.9  rmarkdown_2.32  
    ## [13] generics_0.1.4   lifecycle_1.0.5  cli_3.6.6        vctrs_0.7.3     
    ## [17] compiler_4.6.2   tools_4.6.2      brio_1.1.5       pillar_1.11.1   
    ## [21] evaluate_1.0.5   yaml_2.3.12      otel_0.3.0       jsonlite_2.0.0  
    ## [25] rlang_1.3.0

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

| Reference | Test Report | Script | Run Time |
|:---|:---|:---|:---|
| [UC-01-Project-Initialization](https://github.com/Open-Systems-Pharmacology/UC-01-Project-Initialization) | [UC-01-Project-Initialization](./tests/Reports/UC-01-Project-Initialization/Report.md) | [report-uc-01-project-init.R](./R/report-uc-01-project-init.R) | NA |
| [UC-02-Scenario-Creation](https://github.com/Open-Systems-Pharmacology/UC-02-Scenario-Creation) | [UC-02-Scenario-Creation](./tests/Reports/UC-02-Scenario-Creation/Report.md) | [report-uc-02-scenario-creation.R](./R/report-uc-02-scenario-creation.R) | NA |
| [UC-03-Scenario-Results-<br>RoundTrip](https://github.com/Open-Systems-Pharmacology/UC-03-Scenario-Results-RoundTrip) | [UC-03-Scenario-Results-<br>RoundTrip](./tests/Reports/UC-03-Scenario-Results-RoundTrip/Report.md) | [report-uc-03-scenario-results-<br>roundtrip.R](./R/report-uc-03-scenario-results-roundtrip.R) | NA |
| [UC-04-PK-Parameter-Loading](https://github.com/Open-Systems-Pharmacology/UC-04-PK-Parameter-Loading) | [UC-04-PK-Parameter-Loading](./tests/Reports/UC-04-PK-Parameter-Loading/Report.md) | [report-uc-04-pk-parameter-<br>loading.R](./R/report-uc-04-pk-parameter-loading.R) | NA |
| [UC-05-Population-Export](https://github.com/Open-Systems-Pharmacology/UC-05-Population-Export) | [UC-05-Population-Export](./tests/Reports/UC-05-Population-Export/Report.md) | [report-uc-05-population-export.R](./R/report-uc-05-population-export.R) | NA |
| [UC-07A-Plot-TimeProfiles](./Reports/UC-07A-Plot-TimeProfiles) | [UC-07A-Plot-TimeProfiles](./tests/Reports/UC-07A-Plot-TimeProfiles/Report.md) | [report-uc-07a-plot-<br>timeprofiles.R](./R/report-uc-07a-plot-timeprofiles.R) | NA |
| [UC-07B-Plot-PKBoxwhisker](./Reports/UC-07B-Plot-PKBoxwhisker) | [UC-07B-Plot-PKBoxwhisker](./tests/Reports/UC-07B-Plot-PKBoxwhisker/Report.md) | [report-uc-07b-plot-pk-<br>boxwhisker.R](./R/report-uc-07b-plot-pk-boxwhisker.R) | NA |
| [UC-07C-Plot-PKForest-<br>AggregatedAbsoluteValues](./Reports/UC-07C-Plot-PKForest-AggregatedAbsoluteValues) | [UC-07C-Plot-PKForest-<br>AggregatedAbsoluteValues](./tests/Reports/UC-07C-Plot-PKForest-AggregatedAbsoluteValues/Report.md) | [report-uc-07c-plot-pk-forest-<br>aggregated-absolute-values.R](./R/report-uc-07c-plot-pk-forest-aggregated-absolute-values.R) | NA |
| [UC-07D-Plot-PKForest-<br>PointEstimateAbsolute](./Reports/UC-07D-Plot-PKForest-PointEstimateAbsolute) | [UC-07D-Plot-PKForest-<br>PointEstimateAbsolute](./tests/Reports/UC-07D-Plot-PKForest-PointEstimateAbsolute/Report.md) | [report-uc-07d-plot-pk-forest-<br>point-estimate-absolute.R](./R/report-uc-07d-plot-pk-forest-point-estimate-absolute.R) | NA |
| [UC-07E-Plot-PKForest-<br>AggregatedRatios](https://github.com/Open-Systems-Pharmacology/UC-07E-Plot-PKForest-AggregatedRatios) | [UC-07E-Plot-PKForest-<br>AggregatedRatios](./tests/Reports/UC-07E-Plot-PKForest-AggregatedRatios/Report.md) | [report-uc-07e-plot-pk-forest-<br>aggregated-ratios.R](./R/report-uc-07e-plot-pk-forest-aggregated-ratios.R) | NA |
| [UC-07F-Plot-PKForest-<br>PointEstimateRatios](https://github.com/Open-Systems-Pharmacology/UC-07F-Plot-PKForest-PointEstimateRatios) | [UC-07F-Plot-PKForest-<br>PointEstimateRatios](./tests/Reports/UC-07F-Plot-PKForest-PointEstimateRatios/Report.md) | [report-uc-07f-plot-pk-forest-<br>point-estimate-ratios.R](./R/report-uc-07f-plot-pk-forest-point-estimate-ratios.R) | NA |
| [UC-07G-Plot-Histograms](./Reports/UC-07G-Plot-Histograms) | [UC-07G-Plot-Histograms](./tests/Reports/UC-07G-Plot-Histograms/Report.md) | [report-uc-07g-plot-histograms.R](./R/report-uc-07g-plot-histograms.R) | NA |
| [UC-07H-Plot-<br>DistributionVsDemographics](./Reports/UC-07H-Plot-DistributionVsDemographics) | [UC-07H-Plot-<br>DistributionVsDemographics](./tests/Reports/UC-07H-Plot-DistributionVsDemographics/Report.md) | [report-uc-07h-plot-<br>distribution-vs-demographics.R](./R/report-uc-07h-plot-distribution-vs-demographics.R) | NA |
| [UC-07I-Plot-<br>CustomAnnotatedTimeProfiles](./Reports/UC-07I-Plot-CustomAnnotatedTimeProfiles) | [UC-07I-Plot-<br>CustomAnnotatedTimeProfiles](./tests/Reports/UC-07I-Plot-CustomAnnotatedTimeProfiles/Report.md) | [report-uc-07i-plot-custom-<br>annotated-timeprofiles.R](./R/report-uc-07i-plot-custom-annotated-timeprofiles.R) | NA |
| [UC-07-Generate-Compare-Results](https://github.com/Open-Systems-Pharmacology/UC-07-Generate-Compare-Results) | [UC-07-Generate-Compare-Results](./tests/Reports/UC-07-Generate-Compare-Results/Report.md) | [report-uc-07-generate-and-<br>compare-results.R](./R/report-uc-07-generate-and-compare-results.R) | NA |
| [UC-08A-Sensitivity-Analysis](./Reports/UC-08A-Sensitivity-Analysis) | [UC-08A-Sensitivity-Analysis](./tests/Reports/UC-08A-Sensitivity-Analysis/Report.md) | [report-uc-08a-sensitivity-<br>analysis.R](./R/report-uc-08a-sensitivity-analysis.R) | NA |
| [UC-08B-Sensitivity-Analysis](https://github.com/Open-Systems-Pharmacology/UC-08B-Sensitivity-Analysis) | [UC-08B-Sensitivity-Analysis](./tests/Reports/UC-08B-Sensitivity-Analysis/Report.md) | [report-uc-08b-sensitivity-<br>analysis.R](./R/report-uc-08b-sensitivity-analysis.R) | NA |
| [UC-09-EPackage-Export](./Reports/UC-09-EPackage-Export) | [UC-09-EPackage-Export](./tests/Reports/UC-09-EPackage-Export/Report.md) | [report-uc-09-epackage-export.R](./R/report-uc-09-epackage-export.R) | NA |
| [UC-12-Plot-TimeProfiles-<br>Tutorial](./Reports/UC-12-Plot-TimeProfiles-Tutorial) | [UC-12-Plot-TimeProfiles-<br>Tutorial](./tests/Reports/UC-12-Plot-TimeProfiles-Tutorial/Report.md) | [report-uc-12-plot-<br>timeprofiles-tutorial.R](./R/report-uc-12-plot-timeprofiles-tutorial.R) | NA |
| [UC-10-Data-Dictionary-<br>Operations](https://github.com/Open-Systems-Pharmacology/UC-10-Data-Dictionary-Operations) | [UC-10-Data-Dictionary-<br>Operations](./tests/Reports/UC-10-Data-Dictionary-Operations/Report.md) | [report-uc-10-data-dictionary.R](./R/report-uc-10-data-dictionary.R) | NA |

## Detailed Test Results

| 📓 Report | 🔎 Test | 🚦 Status | ✅ Success | ⚠ Warning &<br>❌ Failed |
|:----------|:--------|:----------|-----------:|-------------------------:|
