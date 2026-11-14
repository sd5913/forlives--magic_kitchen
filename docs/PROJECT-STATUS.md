# Shared project status and handoff

## 14 November: current GDD and order-station branch

- Current source of design: the supplied `Magic_Kitchen_GDD_v1.0.docx` defines Peking duck rolls, not the earlier herbal-shop concept. The local document hash and implementation assumptions are in the [order-station guide](technical/ORDER-STATION.md).
- NEKO / JIN Minyi confirmed ownership of the ordering module. Work is on `feature/order-station`, based on `973f8e3`; fetch the branch before continuing. Do not assume this change is already merged into main.
- Ordering now has guest arrival, ticket requirements/exclusions, guarded acceptance, three active orders plus one waiting guest, patience/expiry, pause, bilingual controls, restart confirmation, and an isolated state manager. The shared workbench can open/close the station without changing other zones.
- Visuals follow the supplied warm, faceted low-poly restaurant reference. Four generated image assets are included. Figma access was denied; no Figma assets or implementation were claimed as retrieved. See [asset provenance](technical/ORDER-ASSETS.md).
- Windows Godot checks passed: 38 state checks and 31 rendered UI checks; six existing Python router tests passed. These are agent-run checks, not a human playtest or tutor review. Screenshots are in `docs/images/`.
- Still pending: oven/prep/serve integration, final shared state host and clock ownership, scoring, actual gesture adapters, a teammate trial, Figma design-owner review, and export/fresh-machine validation. Other station navigation in the module shows an explanatory message, not a fake destination.

The 9 November handoff below records the earlier baseline and remains historical context.

15 November follow-up: the user confirmed English-first presentation with a Chinese toggle and identified bilingual misalignment. Label bounds, centring and heading-font selection were corrected. The expanded UI/layout run now passes 385 assertions, including same-ticket language comparisons; the 38 manager checks remain separate. This does not replace visual-owner approval or a teammate trial.

Updated 9 November 2026, Hong Kong time. I use this file as the short entry point when continuing from another computer or chat. My name is JIN Minyi (`IceyHikari`). Team decisions belong in the [team plan](TEAM-PLAN.md), tasks in the [existing board #23](https://github.com/orgs/sd5913/projects/23), and actual results in [weekly progress](WEEKLY-PROGRESS.md).

## Verified starting point

- Remote `main` was `21df1d27a45dea10563729370d66ae1c78540e2d` when I prepared this change. It already included the 6 November design refinement and reference comparison. I preserve that work.
- That snapshot contained proposals and planning, with no runnable game. Local work on teammates' computers has not been reconciled.
- On 6 November the repository permission API returned Admin for IceyHikari, MiaJiao5, ZHANGYan-Sybil and deadlytomatovo. This supersedes the old pending-repository-invitation description for current planning. It does not verify a successful push or any Project permission.
- Issues #1, #2 and #3 were open. #1 and #3 had no assignee; #2 was assigned to IceyHikari. Board status and tutor visibility remain unverified.
- The actual 5 November demonstration and tutor feedback remain unrecorded. I will ask attendees rather than infer that the meeting happened or was missed.

## Current implementation

The Godot 4.7.2 workbench baseline is available on `main`. See [PR #6](https://github.com/sd5913/forlives--magic_kitchen/pull/6). It contains four independent work areas and a keyboard/mouse input check. I will integrate the layout in the main scene while contributors work inside their assigned subscenes. See the [technical module](technical/README.md) for proposed assignments, launch steps and naming conventions.

The next product slice remains one prescription through selection, preparation and delivery. The current scene supports layout review and input verification. Camera input remains optional. Fetch `main` before continuing on another computer.

## Continuing on either computer

1. Inspect `git status --short --branch`, local diffs and untracked files before changing branches. Preserve unfinished work in a purpose-named branch; review the file list before committing. Do not automatically stash, reset or overwrite it.
2. Fetch the remote and inspect open PRs. Compare `git log --oneline --left-right HEAD...origin/main` from the intended branch. A clean local `main` can use `git pull --ff-only`; if it diverged, inspect both sides before choosing a merge.
3. Read this file, the latest team plan and weekly progress. Check dates and commit IDs; a chat summary is historical context, not proof of the current remote state.
4. Use `feature/…`, `fix/…` or `docs/…`. Work on a particular file/task in one place at a time, or explicitly agree separate ownership. Do not force-push to solve a cross-computer conflict.
5. Run the repository check and relevant game checks. Push the branch and open/update its PR with exact checks and limitations. Keep shared changes reviewable before merging to `main`.
6. At handoff, record the branch/PR, commit, changed files, checks actually run, remaining work and next owner. An unpushed commit or local file is not available to the other computer.

Git syncs committed repository content. It does not transfer untracked/ignored files, installed tools, editor state or chat history. I will share needed local work deliberately and keep credentials out of the repository. Having the same account or a similarly named chat does not establish that both computers have the same files or context.

## Items I still need to reconcile

- Active branches and any unpushed work before integrating additional changes.
- The 5 November outcome and the next tutorial time.
- Confirm the proposed scene assignments and agree the camera approach with teammates.
- Board access and instructor visibility, checked separately from repository access.

I keep this handoff focused on project state; private chat transcripts and account credentials do not belong here.
