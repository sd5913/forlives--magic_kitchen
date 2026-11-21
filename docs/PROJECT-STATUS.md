# Shared project status and handoff

Updated 19 November 2026, Hong Kong time. I am JIN Minyi (`IceyHikari`). I keep current implementation, design delivery and remaining work separate so the team can continue from either computer.

## 22 November: food and gesture correction

The current food and hand exports have been redrawn in a simplified pixel game style. Existing component identities and prototype links are preserved.

当前食物和手势导出已重绘为简化像素游戏风格，保留原组件标识与原型连线。

The [food and gesture assets](design/FOOD-AND-GESTURES.md) now cover the actual annotation: six food illustrations, hands for numbers 1–5 and a fist, and a reusable hint card. Ingredient 4 is red hawthorn strips. The order prototype reuses the food icons, and the repository contains the individual transparent PNGs, source atlases and refreshed previews. Godot recipes and gesture recognition were not changed.

[食物与手势素材](design/FOOD-AND-GESTURES.md)已按原标注意图补齐六种食物插画、数字 1—5、握拳及通用提示卡。第 4 项为红色山楂条，点单原型已复用食物图标。独立透明 PNG、源图集和更新后的预览均已归档；没有修改 Godot 配方或手势识别。

## 21 November: design archive update

The [order-counter high-fidelity page](design/ORDER-STATION.md) and [UI Kit additions](design/UI-KIT.md) are now exported to the repository. This adds the counter illustration, screen/overlay previews, five SVG icons and a record of the Figma prototype links. The shared online file contains the editable components; the native backup remains the 19 November version.

点单区高保真和公共组件补充已导出到仓库，包含柜台插画、界面与弹窗预览、五个 SVG 图标及 Figma 连线记录。可编辑组件保留在共享在线文件中，原生备份仍为 11 月 19 日版本。

This design-only update leaves Godot scenes and implementation branches untouched. The branch snapshot below is dated 19 November; it was not re-audited during this export. Godot integration, a human playtest and new tutor feedback are still separate follow-ups.

本次只同步设计，没有修改 Godot 场景或实现分支。下方分支快照日期为 11 月 19 日，本轮导出未重新审查分支。接入 Godot、真人试玩和新的 tutor 反馈仍需分别完成。

## Current snapshot

| Area | Verified state |
| --- | --- |
| Repository | `sd5913/forlives--magic_kitchen`; default branch `main` |
| Main at the start of this update | `1c81f211eab50a3e8c2416a8d0a782d36d66774a`; shared workbench scaffold and documentation |
| [PR #7](https://github.com/sd5913/forlives--magic_kitchen/pull/7) | Open; `feature/order-station` → `main`, head `b0dfe9a`. Order-station implementation; GitHub currently reports a merge conflict |
| [PR #9](https://github.com/sd5913/forlives--magic_kitchen/pull/9) | Open; `feature/playable-shift` → `feature/order-station`, head `f8e6020`. Shared order-to-delivery prototype, not merged into main |
| Low-fidelity flow | Completed, confirmed by me for this update; other teammates' screens were not individually re-audited during the kit work |
| Shared visual reference and UI Kit | Prepared in Figma; [component inventory and handoff](design/UI-KIT.md), [committed design gallery and downloads](design/README.md) |
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
