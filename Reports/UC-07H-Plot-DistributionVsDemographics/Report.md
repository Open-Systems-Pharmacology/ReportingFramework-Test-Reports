# UC-07H Plot generation: Distribution vs Demographics

## Summary

This use case validates distribution vs demographics plot generation via `runPlot` with the `plotDistributionVsDemographics` function. The use case executes against 8 multi-population scenarios (adolescents, children, school children, and toddlers in both IV and PO routes) and validates successful plot and QMD generation.

## Plot Configuration

The plot configuration is stored in a worksheet named `UC07H_DistVsDemo` in the project's Excel workbook (located at `ReportInputs/PlotConfiguration.xlsx`). The configuration defines:
- Plot name patterns (e.g., `pkparameter_*_distribution_demographics`)
- Active row status (filtering for executable plots)
- PK parameters to include in distribution-vs-demographics analysis

## Scenarios

The following 8 scenarios are used:
- `adolescents_iv` (oral intravenous)
- `adolescents_po` (oral per os)
- `children_iv`
- `children_po`
- `school_children_iv`
- `school_children_po`
- `toddler_iv`
- `toddler_po`

## Generated Outputs

- **QMD Files**: `UC07H_DistVsDemo.qmd` (auto-generated workflow documentation with embedded plot outputs)
- **Plot Files**: PNG/SVG exports of distribution-vs-demographics comparisons for each configured PK parameter
- **Report**: Markdown report with assertions and embedded QMD content
