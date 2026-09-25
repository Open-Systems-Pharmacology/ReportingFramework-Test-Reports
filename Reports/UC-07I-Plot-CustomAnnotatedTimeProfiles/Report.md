# UC-07I Plot generation: Custom Annotated Time Profiles

## Summary

This use case demonstrates how to create and utilize custom plot functions within the ReportingFramework. The custom plot function (`plotCustomAnnotatedTimeProfiles`) extends the framework's built-in `plotTimeProfiles` with additional styling, annotations, and customization.

## Custom Plot Function Features

The `plotCustomAnnotatedTimeProfiles` function demonstrates:
- Calling existing framework plot functions as a base
- Extending plots with additional ggplot2 layers and theme customizations
- Adding reference lines and visual enhancements
- Customizing export attributes (captions, footnotes)
- Implementing configuration validation functions

## Key Components

**Custom Function**: `helpers-uc-07i-custom-plot.R`
- Main function: `plotCustomAnnotatedTimeProfiles()`
- Validation function: `validateCustomAnnotatedTimeProfilesConfig()`
- Adds reference lines (y=0) to time profile plots
- Enhances panel grid styling
- Customizes legend positioning

**Integration Script**: `report-uc-07i-plot-custom-annotated-timeprofiles.R`
- Demonstrates coverage-based testing pattern
- Loads 8 multi-population scenarios
- Tests all active plot configurations
- Generates customized time profile outputs

## Scenarios

The following 8 scenarios are used:
- `adolescents_iv`, `adolescents_po`
- `children_iv`, `children_po`
- `school_children_iv`, `school_children_po`
- `toddler_iv`, `toddler_po`

## Generated Outputs

- **QMD File**: `UC07I_CustomAnnotatedTimeProfiles.qmd` (auto-generated workflow documentation)
- **Plot Files**: PNG/SVG exports of customized time profile plots
- **Report**: Markdown report with assertions and embedded QMD content

## Use Cases for Custom Functions

This pattern can be extended to:
- Add custom annotations or highlights to existing plots
- Combine multiple plot types into composite visualizations
- Apply consistent styling or branding
- Generate domain-specific visualizations
- Add interactive elements or advanced ggplot2 extensions
