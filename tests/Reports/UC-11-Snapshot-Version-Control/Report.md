# UC-11 Configuration Snapshot Version Control

## Summary

This scenario validates the configuration snapshot and version control workflow.
Project snapshots capture the complete state of project configuration (models, scenarios,
parameters, output paths) in JSON format, enabling configuration tracking, comparison,
and restoration across development iterations.

## Functionality Validation

### Available Snapshot Functions

#### Snapshot Creation
- `snapshotProjectConfigurationRF()`: Creates a complete project configuration snapshot
  - Input: ProjectConfiguration object, optional output directory
  - Output: JSON file containing all configuration state
  - Contents: Models, scenarios, PK parameters, output paths, add-ons

#### Snapshot Restoration
- `restoreProjectConfigurationRF()`: Restores project configuration from snapshot
  - Input: Snapshot JSON file path
  - Output: ProjectConfiguration object matching snapshot state
  - Use case: Reproducible workflows, configuration recovery

#### Configuration Comparison (via snapshot JSON)
- Snapshots are JSON-formatted, enabling direct file comparison
  - Git diff shows exact configuration changes
  - Manual JSON comparison tools reveal parameter modifications
  - Features: Parameter changes, scenario modifications, addon updates

#### Version Control Support
- Snapshots integrate with Git for structured version control
  - Timestamped JSON captures project state at each milestone
  - JSON format enables diff visualization
  - Storage: Git-compatible JSON for change tracking

## Project Configuration

- Project Directory: C:\Users\17fec1a5\AppData\Local\Temp\2\RtmpeCQdRh\uc11_snapshot_7ac63f1400
- Configuration Path: C:\Users\17fec1a5\AppData\Local\Temp\2\RtmpeCQdRh\uc11_snapshot_7ac63f1400/Scripts/ReportingFramework/ProjectConfiguration.xlsx
- Model File: Aciclovir.pkml
- Model Path: C:/Users/17fec1a5/AppData/Local/Temp/2/RtmpeCQdRh/uc11_snapshot_7ac63f1400/Models/Aciclovir.pkml
- Snapshot File: C:/Users/17fec1a5/AppData/Local/Temp/2/RtmpeCQdRh/uc11_snapshot_7ac63f1400/Scripts/ReportingFramework/ProjectConfiguration.json

## Validations Performed

✓ Project initialization successful
✓ Project configuration created
✓ Model file copied to project
✓ Snapshot file created from configuration
✓ snapshotProjectConfigurationRF() function available
✓ restoreProjectConfigurationRF() function available

## Snapshot Version Control Workflow

### Step 1: Initial Snapshot
```r
snapshotProjectConfigurationRF(projectConfiguration = pc)
```
Creates timestamped snapshot of initial project state
File location: project_snapshots/ directory

### Step 2: Configuration Modifications
User makes changes to ProjectConfiguration.xlsx:
  - Add new scenarios
  - Modify PK parameters
  - Update output paths
  - Configure plot layouts

### Step 3: Create Version Checkpoint
```r
snapshotProjectConfigurationRF(pc, outputDir = 'snapshots')
```
Captures configuration after modifications
Enables tracking of what changed between versions

### Step 4: Comparison and Tracking
```r
# Use git diff to compare snapshots:
git diff snapshots/ProjectConfiguration.json
# Shows JSON changes for configuration differences
```
Reports configuration changes (additions, deletions, modifications)
Git diff shows JSON changes for code review

### Step 5: Recovery
```r
pc_recovered <- restoreProjectConfigurationRF('snapshots/ProjectConfiguration.json')
```
Restores previous configuration state if needed
Re-creates all associated workbooks and settings

## Snapshot JSON Structure

```json
{
  'ProjectConfiguration': { ... },
  'Scenarios': [ ... ],
  'PKParameter': [ ... ],
  'OutputPaths': [ ... ],
  'projectConfigurationAddons': {
    'demographics': { sheets: [ ... ] },
    'plots': { sheets: [ ... ] },
    ... 
  },
  'timestamp': '2026-08-13T10:30:00Z',
  'version': '1.0'
}
```

## Use Cases

1. **Development Tracking**: Version control of configuration evolution
2. **Experiment Branches**: Different configuration branches for analysis variants
3. **Regulatory Audit Trail**: Document configuration history for compliance
4. **Collaboration**: Share exact configuration state with team members
5. **Error Recovery**: Restore known-good configurations after failed experiments
6. **Impact Analysis**: Understand how configuration changes affect outputs

## Git Integration

Snapshots are designed to work with Git version control:
- JSON format enables diff visualization
- Compact representation minimizes repository size
- Human-readable structure supports code review
- Commit history tracks configuration evolution

## Benefits

- **Reproducibility**: Exact configuration state captured at each milestone
- **Traceability**: Complete history of how project evolved
- **Safety**: Easy rollback to previous configurations
- **Transparency**: Clear documentation of parameter and setting changes

