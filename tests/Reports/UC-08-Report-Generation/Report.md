# UC-08 Report generation

## Summary

Validates markdown helper functions and `mergeRmds()` Qmd composition.

## Assertions

- mdHeading(), mdPaste(), mdPaste0(), mdBullet(), mdBullet0(), mdNewline() completed without error.
- Markdown output contains expected level-1 and level-2 headings.
- Markdown output contains expected bulleted list items.
- mergeRmds() created `merged_report.qmd` without error.
- Merged file title matches supplied title.
- Merged file includes source chapter reference.

## Notes

- renderWord() not exercised: requires pandoc/Word, unavailable in CI.
