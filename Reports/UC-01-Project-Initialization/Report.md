# UC-01 Full project initialisation round-trip

## Summary

This scenario validates project initialization together with the snapshot and restore workflow for project configuration.
It creates a ReportingFramework project from scratch, snapshots the configuration to JSON, and restores the workbook in a second directory for version-control and recovery use cases.

## Assertions

- Snapshot keys present: projectConfiguration, projectConfigurationAddons, pKParameterFile, reportsFile
- Restored workbook sheets include: addons
- Restored configuration sheet name: Sheet1
- RF version before restore: 1.0.1.9003
- RF version after restore: 1.0.1.9003
- Snapshot JSON path: Scripts/ReportingFramework/ProjectConfiguration.json
- Add-on names and relative paths are preserved.

## Snapshot version-control workflow

- Create an initialized project with ProjectConfiguration.xlsx and ProjectConfiguration.json.
- Capture the current configuration state with snapshotProjectConfigurationRF().
- Store the JSON snapshot in version control to review configuration changes over time.
- Restore the configuration into a fresh project directory with restoreProjectConfigurationRF().
- Use the restored workbook as a recovery checkpoint or a reproducible handoff artifact.

## Snapshot JSON structure

- projectConfiguration
- projectConfigurationAddons
- pKParameterFile
- reportsFile

## Add-on paths (relative)

- electronicPackageFolder: ../../ePackage/V1.0/AnalysisProgram
- pKParameterFile: PKParameter.xlsx
- reportsFile: Reports.xlsx
