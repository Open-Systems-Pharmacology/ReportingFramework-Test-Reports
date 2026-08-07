# UC-06 Utilities-data integration

## Summary

This scenario validates observed-data import and key utilities-data helpers with tutorial-backed configuration files.

## Assertions

- readObservedDataByDictionary returned 396 rows.
- fileIds filtering reduced row count.
- Invalid fileId triggers expected subset error.
- getColumnsForColumnType returned required identifier columns.
- convertIdentifierColumns replaced commas with underscores.
- getIndividualDataGroups returned valid groups for aggregation/twin workflows.

## Diagnostic values

- Distinct file identifiers: tp_iv, tp_po
- Eligible groups (minN=2): 1234_iv, 1234_po
