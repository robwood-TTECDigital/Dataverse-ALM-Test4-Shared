# Repository Guidelines

## Pull Request Descriptions

When creating or updating a pull request, keep end-user information separate from implementation details:

- Use `## End-user changes` for observable behavior, configuration options, and user impact in plain language.
- For an ALM4Dataverse version update, use the title `Update ALM4Dataverse from v<previous> to v<target>`.
- Begin `## End-user changes` with `GitHub release changes from v<previous> to v<target>:` and link the previous and target release notes.
- Add `## Fork comparison` immediately after it. Inventory every changed file, or group only a folder whose files share one rationale; explain each directly edited framework file separately, especially Code App changes, and include its tests and upstream/proprietary justification.
- Use `## Implementation details` for internal design, compatibility handling, and test implementation.
- Use `## Validation` for commands and results, including any failures or known limitations.
- Do not mix internal mechanics into the end-user section. Omit a section only when there is nothing relevant to report.
