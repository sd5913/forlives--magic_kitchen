# Shared project status and handoff

Updated 19 November 2026, Hong Kong time. I am JIN Minyi (`IceyHikari`). I keep current implementation, design delivery and remaining work separate so the team can continue from either computer.

## Current snapshot

| Area | Verified state |
| --- | --- |
| Repository | `sd5913/forlives--magic_kitchen`; default branch `main` |
| Main at the start of this update | `1c81f211eab50a3e8c2416a8d0a782d36d66774a`; shared workbench scaffold and documentation |
| [PR #7](https://github.com/sd5913/forlives--magic_kitchen/pull/7) | Open; `feature/order-station` → `main`, head `b0dfe9a`. Order-station implementation; GitHub currently reports a merge conflict |
| [PR #9](https://github.com/sd5913/forlives--magic_kitchen/pull/9) | Open; `feature/playable-shift` → `feature/order-station`, head `f8e6020`. Shared order-to-delivery prototype, not merged into main |
| Low-fidelity flow | Completed, confirmed by me for this update; other teammates' screens were not individually re-audited during the kit work |
| Shared visual reference and UI Kit | Prepared in Figma; [component inventory and handoff](design/UI-KIT.md) |
| Final visual implementation | Asset export and Godot integration pending |
| Team planning | Continue using [board #23](https://github.com/orgs/sd5913/projects/23); board statuses were not reverified in this documentation update |
| Human playtest / tutor feedback | No new observations supplied or collected in this update |

The [README](../README.md) describes the current roast-duck direction. The herbal-pharmacy proposals remain historical documents. They are not the visual or content specification for the new UI Kit.

## Design delivery and next integration

I use the selected 1536 × 1024 cooking-station image as the visual source. The shared kit covers navigation, controls, empty order-ticket frames, reusable borders, decoration, materials and icons. Food, customers, recipes, station scenes and specific gesture steps stay outside the shared kit. See the [Figma source and component rules](design/UI-KIT.md).

The design canvas differs from both the main scaffold and the older ordering layout. I will coordinate the viewport/aspect-ratio decision and shared UI controls before station-specific scenes adopt the final kit. Updating the Figma file has not imported assets or changed Godot scenes.

## Implementation evidence and remaining work

PR #7 documents its state-manager and rendered order-UI checks. PR #9 reports automated macOS verification of the shared order flow, including roasting, ingredient matching, correction, expiry, pause and duplicate delivery. Those are branch-specific reported results; no Godot or gameplay checks were rerun for this design-progress update.

Before integration, reconcile #7's conflict with current main and preserve the dependent work in #9. Then connect the final UI assets without changing order identity, the host-owned clock or lifecycle rules. Keep source-image credits/export permission, rendered checks, a real player trial, final scoring, camera integration and packaged-build checks visible as separate work items where unfinished.

This update synchronises design documentation only. It does not merge either implementation PR or close [first-interaction #3](https://github.com/sd5913/forlives--magic_kitchen/issues/3) or [integration review #8](https://github.com/sd5913/forlives--magic_kitchen/issues/8).

## Continuing on either computer

1. Inspect local status, diffs and untracked files before switching branches. Preserve unfinished work; do not reset, overwrite or automatically stash it.
2. Fetch the remote and inspect main plus open PRs. A clean local main can use `git pull --ff-only`; inspect both sides of a divergence before merging.
3. Read this status, [weekly progress](WEEKLY-PROGRESS.md) and the [UI handoff](design/UI-KIT.md). Confirm dates and branch heads rather than relying on a chat summary.
4. Use `feature/…`, `fix/…` or `docs/…`. Coordinate shared scene/settings changes and avoid editing the same task on two computers at once.
5. Run checks appropriate to the change. For implementation, follow [engineering standards](technical/ENGINEERING-STANDARDS.md). Record branch, commit, exact checks and remaining work at handoff.
6. Follow the same Figma file and UI Kit links on both computers. Figma changes are shared there; Git only synchronises files actually committed to this repository.

Git does not transfer untracked/ignored files, installed tools, editor state or chat history. Repository permissions and Project permissions are separate; this update does not reverify teammates' access.
