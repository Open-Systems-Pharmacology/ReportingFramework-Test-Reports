OSP Reporting Framework Test Reports
================
Open System Pharmacology
2026-07-21

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
| 12               | 644           | 2              | 99.7 %                 |

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
    ## [1] ReportingFramework-Test-Reports_0.0.0.9000
    ## [2] ospsuite.reportingengine_2.4.7            
    ## [3] ospsuite_12.4.4.9001                      
    ## [4] tlf_1.6.2.9001                            
    ## [5] testthat_3.3.2                            
    ## [6] dplyr_1.2.1                               
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] gtable_0.3.6          xfun_0.60             ggplot2_4.0.3        
    ##  [4] remotes_2.5.0         processx_3.9.0        callr_3.8.0          
    ##  [7] tzdb_0.5.0            vctrs_0.7.3           tools_4.6.1          
    ## [10] generics_0.1.4        curl_7.1.0            parallel_4.6.1       
    ## [13] tibble_3.3.1          pkgconfig_2.0.3       data.table_1.18.4    
    ## [16] RColorBrewer_1.1-3    S7_0.2.2              desc_1.4.3           
    ## [19] lifecycle_1.0.5       compiler_4.6.1        farver_2.1.2         
    ## [22] stringr_1.6.0         textshaping_1.0.5     brio_1.1.5           
    ## [25] litedown_0.10         htmltools_0.5.9       yaml_2.3.12          
    ## [28] pillar_1.11.1         crayon_1.5.3          tidyr_1.3.2          
    ## [31] rSharp_1.2.2.9001     commonmark_2.0.0      tidyselect_1.2.1     
    ## [34] digest_0.6.39         stringi_1.8.7         diffobj_0.3.8        
    ## [37] purrr_1.2.2           showtextdb_3.0        rsvg_2.7.0           
    ## [40] labeling_0.4.3        cowplot_1.2.0         rprojroot_2.1.1      
    ## [43] fastmap_1.2.0         grid_4.6.1            cli_3.6.6            
    ## [46] logger_0.4.2          magrittr_2.0.5        pkgbuild_1.4.8       
    ## [49] readr_2.2.0           withr_3.0.3           waldo_0.6.2          
    ## [52] ospsuite.utils_1.11.1 scales_1.4.0          showtext_0.9-8       
    ## [55] bit64_4.8.2           rmarkdown_2.31        sysfonts_0.8.9       
    ## [58] bit_4.6.0             otel_0.2.0            ggtext_0.1.2         
    ## [61] png_0.1-9             ragg_1.5.2            hms_1.1.4            
    ## [64] evaluate_1.0.5        knitr_1.51            viridisLite_0.4.3    
    ## [67] markdown_2.0          rlang_1.3.0           gridtext_0.1.6       
    ## [70] Rcpp_1.1.2            glue_1.8.1            xml2_1.6.0           
    ## [73] pkgload_1.5.3         svglite_2.2.2         vroom_1.7.1          
    ## [76] jsonlite_2.0.0        R6_2.6.1              systemfonts_1.3.2

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
| [Aciclovir-Mean](./Reports/Aciclovir-Mean) | [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean/Report.md) | [report-aciclovir-mean.R](./R/report-aciclovir-mean.R) | 0.6 min |
| [Aciclovir-Mean-SVG](./Reports/Aciclovir-Mean-SVG) | [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG/Report.md) | [report-aciclovir-mean-svg.R](./R/report-aciclovir-mean-svg.R) | 0.7 min |
| [Aciclovir-Population](./Reports/Aciclovir-Population) | [Aciclovir-Population](./tests/Reports/Aciclovir-Population/Report.md) | [report-aciclovir-population.R](./R/report-aciclovir-population.R) | 8.1 min |
| [Raltegravir-Absorption](./Reports/Raltegravir-Absorption) | [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption/Report.md) | [report-raltegravir-absorption.R](./R/report-raltegravir-absorption.R) | 1 min |
| [Raltegravir-Mass-Balance](./Reports/Raltegravir-Mass-Balance) | [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance/Report.md) | [report-raltegravir-mass-<br>balance.R](./R/report-raltegravir-mass-balance.R) | 1.8 min |
| [Test-NO7](./Reports/Test-NO7) | [Test-NO7](./tests/Reports/Test-NO7/Report.md) | [report-NO7.R](./R/report-NO7.R) | 0.3 min |
| [Test-NO8](./Reports/Test-NO8) | [Test-NO8](./tests/Reports/Test-NO8/Report.md) | [report-NO8.R](./R/report-NO8.R) | 0.7 min |
| [Test-NO9](./Reports/Test-NO9) | [Test-NO9](./tests/Reports/Test-NO9/Report.md) | [report-NO9.R](./R/report-NO9.R) | 1.1 min |
| [Test-NO10](./Reports/Test-NO10) | [Test-NO10](./tests/Reports/Test-NO10/Report.md) | [report-NO10.R](./R/report-NO10.R) | 6.5 min |
| [Test-NO11](./Reports/Test-NO11) | [Test-NO11](./tests/Reports/Test-NO11/Report.md) | [report-NO11.R](./R/report-NO11.R) | 0.3 min |
| [Test-NO12](./Reports/Test-NO12) | [Test-NO12](./tests/Reports/Test-NO12/Report.md) | [report-NO12.R](./R/report-NO12.R) | 0.7 min |

## Detailed Test Results

| 📓 Report | 🔎 Test | 🚦 Status | ✅ Success | ⚠ Warning &<br>❌ Failed |
|:---|:---|:---|---:|---:|
| [Qualification Plan Editor](./tests/Reports/Qualification%20Plan%20Editor) | Report has run<br>after update | ![](https://img.shields.io/badge/%E2%9A%A0-Failed%20tests-red) | 0 | 1 |
| [Qualification Plan Editor](./tests/Reports/Qualification%20Plan%20Editor) | Qualification<br>Plan Editor<br>generated same<br>report after<br>update | ![](https://img.shields.io/badge/%E2%9A%A0-Warned%20tests-red) | 0 | 1 |
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 6 | 0 |
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
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 24 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected<br>Sensitivity<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 19 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Aciclovir-Population](./tests/Reports/Aciclovir-Population) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 8 | 0 |
| [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption) | Expected<br>Absorption<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 10 | 0 |
| [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance) | Expected Mass<br>Balance Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 8 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Test-NO7](./tests/Reports/Test-NO7) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 33 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO8](./tests/Reports/Test-NO8) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 12 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 20 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO9](./tests/Reports/Test-NO9) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 6 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 368 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 4 | 0 |
| [Test-NO10](./tests/Reports/Test-NO10) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 12 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 8 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Test-NO11](./tests/Reports/Test-NO11) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected Files | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Content of<br>Report | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected Plots | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 14 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected<br>Simulation<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected<br>PK Analysis<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected<br>Goodness of Fit | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 2 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected PK<br>Parameter<br>Tables | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected Mass<br>Balance Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
| [Test-NO12](./tests/Reports/Test-NO12) | Expected<br>Absorption<br>Results | ![](https://img.shields.io/badge/%E2%9C%93-Passed%20tests-success) | 1 | 0 |
