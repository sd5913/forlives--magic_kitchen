# Working together

Follow the [engineering standards](docs/technical/ENGINEERING-STANDARDS.md) for file layout, naming, scene boundaries and integration checks.

## Before coding

1. Confirm that your registered GitHub account can push a branch to this repository. Repository and Project permissions are separate.
2. Read the current goal in [the team plan](docs/TEAM-PLAN.md) and choose a task with the team. Give each task a named owner before starting implementation.
3. Use an issue to describe the intended outcome and observable acceptance checks. Keep the scope small enough to demonstrate.

## Changes and review

1. Name branches by the purpose of the change: `feature/short-task-name` for features, `fix/short-task-name` for fixes, or `docs/short-task-name` for documentation. Use these names whether or not AI tools assisted the work; document AI assistance in the relevant process notes or credits.
2. Make small, meaningful commits. Explain the behavior changed rather than increasing commit counts for their own sake.
3. When using a pull request, target `main` and include the issue link, what changed, how it was checked and known limitations. Use `Closes #<issue-number>` only when the work resolves that issue.
4. Run the relevant checks and record the result. Record teammate or player observations when a trial takes place.
5. The technical lead coordinates integration into `main`. Link the change and its verification in the task or weekly notes.

The initial documentation scaffold may be reviewed separately from product work; it does not count as a working game/app increment.

## Definition of Done (proposed for team agreement)

- The change is integrated with the current project and meets its issue's acceptance checks.
- The intended input produces the expected response, with understandable feedback.
- A relevant ordinary mistake has been tried and handled.
- Relevant checks pass; a teammate can run and try the increment.
- Setup instructions, credits and limitations remain accurate.
- Evidence and any follow-up work are linked in the issue/PR and weekly record.

For Godot changes, record the operating system and editor version used for the check.

## Weekly tutor review

Bring a usable increment, test/playtest evidence and one main blocker or question. After the meeting, record the actual tutor feedback and next goal with owners in [weekly progress](docs/WEEKLY-PROGRESS.md). Class-week dates are not calendar invitations; confirm the exact tutorial meeting time with the tutor.

## Assets, tools and secrets

Credit borrowed assets/code/data and document AI assistance. Use material the team has permission to share. Keep tokens, passwords, private data and recordings of other people out of Git. If a service is later required, document environment variable names and provide placeholders, never working credentials.
