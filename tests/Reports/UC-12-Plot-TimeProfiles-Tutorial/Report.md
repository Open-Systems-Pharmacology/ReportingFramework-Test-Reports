# UC-12 Tutorial Time Profiles

## Summary

This scenario validates tutorial-based time profile plotting using tutorial configuration and observed-data assets from ospsuite.reportingframework extdata.

## Assertions

- Tutorial directory found: C:/Users/17fec1a5/AppData/Local/R/win-library/4.4/ospsuite.reportingframework/extdata/Tutorial
- Scenarios created: one_individual, virtual_twin_population, random_population_po, random_population_iv
- Observed rows loaded: 462
- TimeProfiles plot configurations executed: 10
- Executed plot names: one_individual, one_individual-gof, selected_individuals-1, selected_individuals-2, all_individuals, all_individuals-gof, random_population, reference, timeranges, timeranges-split
- Generated plot files: 38
- Timeprofile.qmd generated and rendered: TimeProfiles.qmd (Quarto rendered)

## Plot Coverage

| Plot Name | Inputs | Status | Returned Objects |
|---|---|---|---:|
| one_individual |  | PASS | 2 |
| one_individual-gof |  | PASS | 10 |
| selected_individuals-1 |  | PASS | 2 |
| selected_individuals-2 |  | PASS | 2 |
| all_individuals |  | PASS | 2 |
| all_individuals-gof |  | PASS | 10 |
| random_population |  | PASS | 2 |
| reference |  | PASS | 2 |
| timeranges |  | PASS | 4 |
| timeranges-split |  | PASS | 2 |

## Time Profile Report

The following content is from the auto-generated Timeprofile.qmd with all figures, captions, and headings as defined in the TimeProfiles configuration sheet:

# Report


# Concentration time profiles

## Setting Up the Project and Basic Simulations

<div id="fig-one_individual-TP-linear-total">

![](TimeProfiles/one_individual-TP-linear-total.png)


Figure 1: Concentration-time profiles for drugX plasma concentration
(A), drugX metabolized by CYP3A4 (B) and drugX metabolized by CYP3A4 in
liver (C) for simulation of an 1mg iv application for individual id 13
study 1234 on a linear y-scale. DrugX was administered as a 1mg Iv
application with an infusion time of 5 minutes.

</div>



<div id="fig-one_individual-TP-log-total">

![](TimeProfiles/one_individual-TP-log-total.png)


Figure 2: Concentration-time profiles for drugX plasma concentration
(A), drugX metabolized by CYP3A4 (B) and drugX metabolized by CYP3A4 in
liver (C) for simulation of an 1mg iv application for individual id 13
study 1234 on a logarithmic y-scale. DrugX was administered as a 1mg Iv
application with an infusion time of 5 minutes.

</div>



<div id="fig-one_individual-gof-PvO-linear-total">

![](TimeProfiles/one_individual-gof-PvO-linear-total.png)


Figure 3: Predicted vs Observed for drugX plasma concentration for
simulation of an 1mg iv application for individual id 13 study 1234 on a
linear x and y-scale. DrugX was administered as a 1mg Iv application
with an infusion time of 5 minutes.

</div>



<div id="fig-one_individual-gof-PvO-log-total">

![](TimeProfiles/one_individual-gof-PvO-log-total.png)


Figure 4: Predicted vs Observed for drugX plasma concentration for
simulation of an 1mg iv application for individual id 13 study 1234 on a
logarithmic x and y-scale. DrugX was administered as a 1mg Iv
application with an infusion time of 5 minutes.

</div>



<div id="fig-one_individual-gof-ResvT-linear-total">

![](TimeProfiles/one_individual-gof-ResvT-linear-total.png)


Figure 5: Residuals vs time values for drugX plasma concentration for
simulation of an 1mg iv application for individual id 13 study 1234.
DrugX was administered as a 1mg Iv application with an infusion time of
5 minutes.

</div>



<div id="fig-one_individual-gof-ResvT-log-total">

![](TimeProfiles/one_individual-gof-ResvT-log-total.png)


Figure 6: Residuals vs time values for drugX plasma concentration for
simulation of an 1mg iv application for individual id 13 study 1234.
DrugX was administered as a 1mg Iv application with an infusion time of
5 minutes.

</div>



<div id="fig-one_individual-gof-ResvO-linear-total">

![](TimeProfiles/one_individual-gof-ResvO-linear-total.png)


Figure 7: Residuals vs observed values for drugX plasma concentration
for simulation of an 1mg iv application for individual id 13 study 1234.
DrugX was administered as a 1mg Iv application with an infusion time of
5 minutes.

</div>



<div id="fig-one_individual-gof-ResvO-log-total">

![](TimeProfiles/one_individual-gof-ResvO-log-total.png)


Figure 8: Residuals vs observed values for drugX plasma concentration
for simulation of an 1mg iv application for individual id 13 study 1234.
DrugX was administered as a 1mg Iv application with an infusion time of
5 minutes.

</div>



<div id="fig-one_individual-gof-ResH-linear-total">

![](TimeProfiles/one_individual-gof-ResH-linear-total.png)


Figure 9: Residuals distribution for drugX plasma concentration for
simulation of an 1mg iv application for individual id 13 study 1234.
DrugX was administered as a 1mg Iv application with an infusion time of
5 minutes.

</div>



<div id="fig-one_individual-gof-ResH-log-total">

![](TimeProfiles/one_individual-gof-ResH-log-total.png)


Figure 10: Residuals distribution for drugX plasma concentration for
simulation of an 1mg iv application for individual id 13 study 1234.
DrugX was administered as a 1mg Iv application with an infusion time of
5 minutes.

</div>



<div id="fig-one_individual-gof-QQ-linear-total">

![](TimeProfiles/one_individual-gof-QQ-linear-total.png)


Figure 11: Residuals as quantile-quantile plot for drugX plasma
concentration for simulation of an 1mg iv application for individual id
13 study 1234. DrugX was administered as a 1mg Iv application with an
infusion time of 5 minutes.

</div>



<div id="fig-one_individual-gof-QQ-log-total">

![](TimeProfiles/one_individual-gof-QQ-log-total.png)


Figure 12: Residuals as quantile-quantile plot for drugX plasma
concentration for simulation of an 1mg iv application for individual id
13 study 1234. DrugX was administered as a 1mg Iv application with an
infusion time of 5 minutes.

</div>



## Adding Virtual Twin Populations

### filtered individual

<div id="fig-selected_individuals-1-TP-linear-total">

![](TimeProfiles/selected_individuals-1-TP-linear-total.png)


Figure 13: Concentration-time profiles for drugX metabolized by CYP3A4
and drugX plasma concentration for simulation of an 1mg iv application
for individuals of study 1234 for subject I123413 (A), I123430 (B) and
I123441 (C) on a linear y-scale. DrugX was administered as a 1mg Iv
application with an infusion time of 5 minutes.

</div>



<div id="fig-selected_individuals-1-TP-log-total">

![](TimeProfiles/selected_individuals-1-TP-log-total.png)


Figure 14: Concentration-time profiles for drugX metabolized by CYP3A4
and drugX plasma concentration for simulation of an 1mg iv application
for individuals of study 1234 for subject I123413 (A), I123430 (B) and
I123441 (C) on a logarithmic y-scale. DrugX was administered as a 1mg Iv
application with an infusion time of 5 minutes.

</div>



<div id="fig-selected_individuals-2-TP-linear-total">

![](TimeProfiles/selected_individuals-2-TP-linear-total.png)


Figure 15: Concentration-time profiles for drugX metabolized by CYP3A4
and drugX plasma concentration for simulation of an 1mg iv application
for individuals of study 1234 for subject I123450 (A), I123466 (B) and
I123478 (C) on a linear y-scale. DrugX was administered as a 1mg Iv
application with an infusion time of 5 minutes.

</div>



<div id="fig-selected_individuals-2-TP-log-total">

![](TimeProfiles/selected_individuals-2-TP-log-total.png)


Figure 16: Concentration-time profiles for drugX metabolized by CYP3A4
and drugX plasma concentration for simulation of an 1mg iv application
for individuals of study 1234 for subject I123450 (A), I123466 (B) and
I123478 (C) on a logarithmic y-scale. DrugX was administered as a 1mg Iv
application with an infusion time of 5 minutes.

</div>



### shortcut for individual filter

<div id="fig-all_individuals-TP-linear-total">

![](TimeProfiles/all_individuals-TP-linear-total.png)


Figure 17: Concentration-time profiles for drugX metabolized by CYP3A4
and drugX plasma concentration for simulation of an 1mg iv application
for individuals of study 1234 for subject I123413 (A), I123430 (B),
I123441 (C), I123450 (D), I123466 (E) and I123478 (F) on a linear
y-scale. DrugX was administered as a 1mg Iv application with an infusion
time of 5 minutes.

</div>



<div id="fig-all_individuals-TP-log-total">

![](TimeProfiles/all_individuals-TP-log-total.png)


Figure 18: Concentration-time profiles for drugX metabolized by CYP3A4
and drugX plasma concentration for simulation of an 1mg iv application
for individuals of study 1234 for subject I123413 (A), I123430 (B),
I123441 (C), I123450 (D), I123466 (E) and I123478 (F) on a logarithmic
y-scale. DrugX was administered as a 1mg Iv application with an infusion
time of 5 minutes.

</div>



<div id="fig-all_individuals-gof-PvO-linear-total">

![](TimeProfiles/all_individuals-gof-PvO-linear-total.png)


Figure 19: Predicted vs Observed for drugX plasma concentration for
simulation of an 1mg iv application for individuals of study 1234 on a
linear x and y-scale. DrugX was administered as a 1mg Iv application
with an infusion time of 5 minutes.

</div>



<div id="fig-all_individuals-gof-PvO-log-total">

![](TimeProfiles/all_individuals-gof-PvO-log-total.png)


Figure 20: Predicted vs Observed for drugX plasma concentration for
simulation of an 1mg iv application for individuals of study 1234 on a
logarithmic x and y-scale. DrugX was administered as a 1mg Iv
application with an infusion time of 5 minutes.

</div>



<div id="fig-all_individuals-gof-ResvT-linear-total">

![](TimeProfiles/all_individuals-gof-ResvT-linear-total.png)


Figure 21: Residuals vs time values for drugX plasma concentration for
simulation of an 1mg iv application for individuals of study 1234. DrugX
was administered as a 1mg Iv application with an infusion time of 5
minutes.

</div>



<div id="fig-all_individuals-gof-ResvT-log-total">

![](TimeProfiles/all_individuals-gof-ResvT-log-total.png)


Figure 22: Residuals vs time values for drugX plasma concentration for
simulation of an 1mg iv application for individuals of study 1234. DrugX
was administered as a 1mg Iv application with an infusion time of 5
minutes.

</div>



<div id="fig-all_individuals-gof-ResvO-linear-total">

![](TimeProfiles/all_individuals-gof-ResvO-linear-total.png)


Figure 23: Residuals vs observed values for drugX plasma concentration
for simulation of an 1mg iv application for individuals of study 1234.
DrugX was administered as a 1mg Iv application with an infusion time of
5 minutes.

</div>



<div id="fig-all_individuals-gof-ResvO-log-total">

![](TimeProfiles/all_individuals-gof-ResvO-log-total.png)


Figure 24: Residuals vs observed values for drugX plasma concentration
for simulation of an 1mg iv application for individuals of study 1234.
DrugX was administered as a 1mg Iv application with an infusion time of
5 minutes.

</div>



<div id="fig-all_individuals-gof-ResH-linear-total">

![](TimeProfiles/all_individuals-gof-ResH-linear-total.png)


Figure 25: Residuals distribution for drugX plasma concentration for
simulation of an 1mg iv application for individuals of study 1234. DrugX
was administered as a 1mg Iv application with an infusion time of 5
minutes.

</div>



<div id="fig-all_individuals-gof-ResH-log-total">

![](TimeProfiles/all_individuals-gof-ResH-log-total.png)


Figure 26: Residuals distribution for drugX plasma concentration for
simulation of an 1mg iv application for individuals of study 1234. DrugX
was administered as a 1mg Iv application with an infusion time of 5
minutes.

</div>



<div id="fig-all_individuals-gof-QQ-linear-total">

![](TimeProfiles/all_individuals-gof-QQ-linear-total.png)


Figure 27: Residuals as quantile-quantile plot for drugX plasma
concentration for simulation of an 1mg iv application for individuals of
study 1234. DrugX was administered as a 1mg Iv application with an
infusion time of 5 minutes.

</div>



<div id="fig-all_individuals-gof-QQ-log-total">

![](TimeProfiles/all_individuals-gof-QQ-log-total.png)


Figure 28: Residuals as quantile-quantile plot for drugX plasma
concentration for simulation of an 1mg iv application for individuals of
study 1234. DrugX was administered as a 1mg Iv application with an
infusion time of 5 minutes.

</div>



## Adding Random Populations and use of aggregated data

<div id="fig-random_population-TP-linear-total">

![](TimeProfiles/random_population-TP-linear-total.png)


Figure 29: Concentration-time profiles for drugX plasma concentration
(A, D), drugX metabolized by CYP3A4 (B, E) and drugX metabolized by
CYP3A4 in liver (C, F) for simulation of an 1mg iv application for an
adult population (A, B, C) and simulation of an 5mg oral application for
an adult population (D, E, F) on a linear y-scale.

</div>

Observed data is displayed as geometric mean and geometric standard
deviation



<div id="fig-random_population-TP-log-total">

![](TimeProfiles/random_population-TP-log-total.png)


Figure 30: Concentration-time profiles for drugX plasma concentration
(A, D), drugX metabolized by CYP3A4 (B, E) and drugX metabolized by
CYP3A4 in liver (C, F) for simulation of an 1mg iv application for an
adult population (A, B, C) and simulation of an 5mg oral application for
an adult population (D, E, F) on a logarithmic y-scale.

</div>

Observed data is displayed as geometric mean and geometric standard
deviation



## Adding Reference Populations

<div id="fig-reference-TP-linear-total">

![](TimeProfiles/reference-TP-linear-total.png)


Figure 31: Concentration-time profiles for drugX plasma concentration
(A), drugX metabolized by CYP3A4 (B) and drugX metabolized by CYP3A4 in
liver (C) for simulation of a 5mg oral administration vs 1mg iv
simulation on a linear y-scale.

</div>

Observed data is displayed as geometric mean and geometric standard
deviation



<div id="fig-reference-TP-log-total">

![](TimeProfiles/reference-TP-log-total.png)


Figure 32: Concentration-time profiles for drugX plasma concentration
(A), drugX metabolized by CYP3A4 (B) and drugX metabolized by CYP3A4 in
liver (C) for simulation of a 5mg oral administration vs 1mg iv
simulation on a logarithmic y-scale.

</div>

Observed data is displayed as geometric mean and geometric standard
deviation



## Adding Plots with different Time Ranges

<div id="fig-timeranges-TP-linear-h0_6">

![](TimeProfiles/timeranges-TP-linear-h0_6.png)


Figure 33: Concentration-time profiles for drugX plasma concentration
(A), drugX metabolized by CYP3A4 (B) and drugX metabolized by CYP3A4 in
liver (C) for simulation of an 1mg iv application for individual id 13
study 1234 on a linear y-scale. Zoom on first 6 hours. DrugX was
administered as a 1mg Iv application with an infusion time of 5 minutes.

</div>



<div id="fig-timeranges-TP-log-h0_6">

![](TimeProfiles/timeranges-TP-log-h0_6.png)


Figure 34: Concentration-time profiles for drugX plasma concentration
(A), drugX metabolized by CYP3A4 (B) and drugX metabolized by CYP3A4 in
liver (C) for simulation of an 1mg iv application for individual id 13
study 1234 on a logarithmic y-scale. Zoom on first 6 hours. DrugX was
administered as a 1mg Iv application with an infusion time of 5 minutes.

</div>



<div id="fig-timeranges-TP-linear-h6_24">

![](TimeProfiles/timeranges-TP-linear-h6_24.png)


Figure 35: Concentration-time profiles for drugX plasma concentration
(A), drugX metabolized by CYP3A4 (B) and drugX metabolized by CYP3A4 in
liver (C) for simulation of an 1mg iv application for individual id 13
study 1234 on a linear y-scale. Zoom on time range 6 to 24 hours. DrugX
was administered as a 1mg Iv application with an infusion time of 5
minutes.

</div>



<div id="fig-timeranges-TP-log-h6_24">

![](TimeProfiles/timeranges-TP-log-h6_24.png)


Figure 36: Concentration-time profiles for drugX plasma concentration
(A), drugX metabolized by CYP3A4 (B) and drugX metabolized by CYP3A4 in
liver (C) for simulation of an 1mg iv application for individual id 13
study 1234 on a logarithmic y-scale. Zoom on time range 6 to 24 hours.
DrugX was administered as a 1mg Iv application with an infusion time of
5 minutes.

</div>



<div id="fig-timeranges-split-TP-linear-allTimeRanges">

![](TimeProfiles/timeranges-split-TP-linear-allTimeRanges.png)


Figure 37: Concentration-time profiles for drugX plasma concentration
(A, B), drugX metabolized by CYP3A4 (C, D) and drugX metabolized by
CYP3A4 in liver (E, F) for simulation of an 1mg iv application for
individual id 13 study 1234 on a linear y-scale. Zoom on first 6 hours
(A, C, E) and Zoom on time range 6 to 24 hours (B, D, F). DrugX was
administered as a 1mg Iv application with an infusion time of 5 minutes.

</div>



<div id="fig-timeranges-split-TP-log-allTimeRanges">

![](TimeProfiles/timeranges-split-TP-log-allTimeRanges.png)


Figure 38: Concentration-time profiles for drugX plasma concentration
(A, B), drugX metabolized by CYP3A4 (C, D) and drugX metabolized by
CYP3A4 in liver (E, F) for simulation of an 1mg iv application for
individual id 13 study 1234 on a logarithmic y-scale. Zoom on first 6
hours (A, C, E) and Zoom on time range 6 to 24 hours (B, D, F). DrugX
was administered as a 1mg Iv application with an infusion time of 5
minutes.

</div>



