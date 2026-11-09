OSP Reporting Framework Test Reports
================
Open System Pharmacology
2026-11-09

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
| 11               | 0             | 0              | 0 %                    |

**Report execution status:** 0 of 11 reports passed (11 failed).

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

Models, Observed and Simulated Data are respectively available in the
[Models](./Models) and [Data](./Data) folders.

Here is the summary of the reports, their scripts and their run time
currently available in this repository:

| Reference | Test Report | Script | Run Time |
|:---|:---|:---|:---|
| [Aciclovir-Mean](./Reports/Aciclovir-Mean) | [Aciclovir-Mean](./tests/Reports/Aciclovir-Mean/Report.md) | [report-aciclovir-mean.R](./R/report-aciclovir-mean.R) | 0.6 min |
| [Aciclovir-Mean-SVG](./Reports/Aciclovir-Mean-SVG) | [Aciclovir-Mean-SVG](./tests/Reports/Aciclovir-Mean-SVG/Report.md) | [report-aciclovir-mean-svg.R](./R/report-aciclovir-mean-svg.R) | 0.7 min |
| [Aciclovir-Population](./Reports/Aciclovir-Population) | [Aciclovir-Population](./tests/Reports/Aciclovir-Population/Report.md) | [report-aciclovir-population.R](./R/report-aciclovir-population.R) | NA |
| [Raltegravir-Absorption](./Reports/Raltegravir-Absorption) | [Raltegravir-Absorption](./tests/Reports/Raltegravir-Absorption/Report.md) | [report-raltegravir-absorption.R](./R/report-raltegravir-absorption.R) | NA |
| [Raltegravir-Mass-Balance](./Reports/Raltegravir-Mass-Balance) | [Raltegravir-Mass-Balance](./tests/Reports/Raltegravir-Mass-Balance/Report.md) | [report-raltegravir-mass-<br>balance.R](./R/report-raltegravir-mass-balance.R) | 1.4 min |
| [Test-NO7](./Reports/Test-NO7) | [Test-NO7](./tests/Reports/Test-NO7/Report.md) | [report-NO7.R](./R/report-NO7.R) | 0.3 min |
| [Test-NO8](./Reports/Test-NO8) | [Test-NO8](./tests/Reports/Test-NO8/Report.md) | [report-NO8.R](./R/report-NO8.R) | 0.8 min |
| [Test-NO9](./Reports/Test-NO9) | [Test-NO9](./tests/Reports/Test-NO9/Report.md) | [report-NO9.R](./R/report-NO9.R) | 1 min |
| [Test-NO10](./Reports/Test-NO10) | [Test-NO10](./tests/Reports/Test-NO10/Report.md) | [report-NO10.R](./R/report-NO10.R) | 4 min |
| [Test-NO11](./Reports/Test-NO11) | [Test-NO11](./tests/Reports/Test-NO11/Report.md) | [report-NO11.R](./R/report-NO11.R) | 0.3 min |
| [Test-NO12](./Reports/Test-NO12) | [Test-NO12](./tests/Reports/Test-NO12/Report.md) | [report-NO12.R](./R/report-NO12.R) | 0.8 min |

## Detailed Test Results

| 📓 Report | 🔎 Test | 🚦 Status | ✅ Success | ⚠ Warning &<br>❌ Failed |
|:----------|:--------|:----------|-----------:|-------------------------:|
