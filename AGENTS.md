# Repository Guidelines

## Comments and Help

Follow the [commenting standard](docs/development/powershell.md#commenting-standard)
for all new and modified code.
Write each comment individually after reading its implementation and relevant
callers/tests; never script-generate or bulk-insert commentary. Explain contracts
and non-obvious reasons, not readable statements. Review embedded code and generated
sources without changing executable content during comment-only work.

Whenever you add or change behavior, review and update the affected script help,
function contracts, inline rationale, configuration examples, templates and
generator commentary in the same change. Check relevant callers and tests so
comments describe actual defaults, return values, side effects and failure behavior.
Remove or correct stale comments; do not leave contradictory explanations behind.
Document new non-obvious contracts and decisions, but do not add boilerplate to
self-explanatory code. Validate help placement, embedded syntax and generated
outputs using the existing checks described in the development guide.

## Pull Request Descriptions

When creating or updating a pull request, keep end-user information separate from implementation details:

- Use `## End-user changes` for observable behavior, configuration options, and user impact in plain language.
- For an ALM4Dataverse version update, title the PR `Update ALM4Dataverse from v<previous> to v<target>`.
- For a version update, begin `## End-user changes` with `GitHub release changes from v<previous> to v<target>:` and link the previous and target release notes. Keep this section to release-level user impact; do not put fork mechanics here.
- Use `## Fork comparison` immediately after the end-user section for the source-ref audit described below.
- Use `## Implementation details` for internal design, compatibility handling, and test implementation.
- Use `## Validation` for commands and results, including any failures or known limitations.
- Do not mix internal mechanics into the end-user section. Omit a section only when there is nothing relevant to report.

## Fork Difference Audit

For Dataverse-ALM changes, compare the fork HEAD with the exact ALM4Dataverse
source ref and inventory every differing file and hunk. In `## Fork comparison`,
list each changed file or a folder only when every file in that folder shares the
same rationale; include file counts for grouped folders. Give every directly
edited framework file its own purpose, user impact, test coverage, and upstream
PR or explicit proprietary justification. In particular, explain Code App
framework changes file-by-file rather than hiding them in a generic category.
Classify each difference as upstream-compatible, documented proprietary
config/hook/asset, framework-required, upstream candidate, or unexpected; prefer
configuration and hooks, record evidence and unresolved items, and include the
summary in the PR body. Submit non-proprietary fixes upstream. Dataverse-ALM PRs
target the Azure DevOps `upstream` remote, not the GitHub mirror. Do not claim
the audit passed while unresolved items remain.
