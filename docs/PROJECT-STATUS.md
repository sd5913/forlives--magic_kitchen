# Shared project status and handoff

Updated 9 November 2026, Hong Kong time. I use this file as the short entry point when continuing from another computer or chat. My name is JIN Minyi (`IceyHikari`). Team decisions belong in the [team plan](TEAM-PLAN.md), tasks in the [existing board #23](https://github.com/orgs/sd5913/projects/23), and actual results in [weekly progress](WEEKLY-PROGRESS.md).

## Verified starting point

- Remote `main` was `21df1d27a45dea10563729370d66ae1c78540e2d` when I prepared this change. It already included the 6 November design refinement and reference comparison. I preserve that work.
- That snapshot contained proposals and planning, with no runnable game. Local work on teammates' computers has not been reconciled.
- On 6 November the repository permission API returned Admin for IceyHikari, MiaJiao5, ZHANGYan-Sybil and deadlytomatovo. This supersedes the old pending-repository-invitation description for current planning. It does not verify a successful push or any Project permission.
- Issues #1, #2 and #3 were open. #1 and #3 had no assignee; #2 was assigned to IceyHikari. Board status and tutor visibility remain unverified.
- The actual 5 November demonstration and tutor feedback remain unrecorded. I will ask attendees rather than infer that the meeting happened or was missed.

## Work in this change

I am keeping development checks and the new [interaction input boundary](INPUT-ARCHITECTURE.md) together in [PR #6](https://github.com/sd5913/forlives--magic_kitchen/pull/6). The reference router and demo run without hardware and test how overlapping input, tracking loss and focus loss are handled. The next engineering task is to wire one real ordinary input in [Godot 4.7.2 Standard](ENGINE-DECISION.md), after reconciling existing local work. Check the latest PR and CI before continuing on another computer. This is a technical increment; it does not count as a playable game or close issues #1–#3.

The proposed next product slice remains one prescription through selection, grinding, wrapping and delivery, followed by a second order to test simultaneous input. I selected Godot and GDScript as the runtime. Camera integration remains optional and still needs discussion and testing. The next class-week focus is 12 November: an integrated core experience, with scope and exact meeting time confirmed by the tutor.

## Continuing on either computer

1. Inspect `git status --short --branch`, local diffs and untracked files before changing branches. Preserve unfinished work in a purpose-named branch; review the file list before committing. Do not automatically stash, reset or overwrite it.
2. Fetch the remote and inspect open PRs. Compare `git log --oneline --left-right HEAD...origin/main` from the intended branch. A clean local `main` can use `git pull --ff-only`; if it diverged, inspect both sides before choosing a merge.
3. Read this file, the latest team plan and weekly progress. Check dates and commit IDs; a chat summary is historical context, not proof of the current remote state.
4. Use `feature/…`, `fix/…` or `docs/…`. Work on a particular file/task in one place at a time, or explicitly agree separate ownership. Do not force-push to solve a cross-computer conflict.
5. Run the repository check and relevant game checks. Push the branch and open/update its PR with exact checks and limitations. Keep shared changes reviewable before merging to `main`.
6. At handoff, record the branch/PR, commit, changed files, checks actually run, remaining work and next owner. An unpushed commit or local file is not available to the other computer.

Git syncs committed repository content. It does not transfer untracked/ignored files, installed tools, editor state or chat history. I will share needed local work deliberately and keep credentials out of the repository. Having the same account or a similarly named chat does not establish that both computers have the same files or context.

## Items I still need to reconcile

- Existing local game code and active branches on either computer or teammates' machines.
- The 5 November outcome and the next tutorial time.
- Camera approach and prototype ownership agreed with teammates. The engine/version is recorded in the engine decision.
- Board access and instructor visibility, checked separately from repository access.

I keep this handoff focused on project state; private chat transcripts and account credentials do not belong here.
