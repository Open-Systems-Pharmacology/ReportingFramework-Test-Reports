# UC-01 Full project initialisation round-trip

## Summary

This scenario validates init/create/snapshot/restore workflow for project configuration.

## Assertions

- Snapshot keys present: projectConfiguration, projectConfigurationAddons, pKParameterFile, reportsFile
- Restored workbook sheets include: addons
- Restored configuration sheet name: Sheet1
- RF version before restore: 1.0.1.9003
- RF version after restore: 1.0.1.9003
- Add-on names and relative paths are preserved.

## Add-on paths (relative)

- electronicPackageFolder: ../../Outputs/ePackage/AnalysisProgram
- pKParameterFile: PKParameter.xlsx
- reportsFile: Reports.xlsx
