# Weekly progress and tutor deliveries

Final Canvas deadline: **6 December 2026, 23:59 HKT**. The dates below are Thursday class weeks; the tutor confirms the exact meeting time. There is no extra Canvas upload for these weekly records.

## 29 October 2026: repository setup

- Verified: the repository is public and owned by sd5913; IceyHikari has Admin access.
- Existing product state: only the initial README was present when setup began. No runnable project or playtest evidence yet.
- Work prepared: collaboration guidance, proposed Definition of Done, scope/access backlog and this dated delivery record, using the official project brief and Week 8 teamwork guide.
- Board: use MiaJiao5's existing [#23](https://github.com/orgs/sd5913/projects/23), with its template iterations/views and existing delivery cards preserved. The repository is linked. Issues #1–#3 track scope, access and the first interaction.
- Access: IceyHikari, MiaJiao5 and deadlytomatovo have repository Admin access. ZHANGYan-Sybil has a pending repository invitation. IceyHikari can edit board #23; other teammates' actual board access and organization base-access setting still need verification. A temporary duplicate board was consolidated into the existing board at the user's request.
- Blockers: audience, platform, scope and tutor slot are not recorded yet; pending invitation/access checks remain open.
- Next: confirm access and scope, then implement the first small interaction. No tutor feedback has been received in this setup record.

## Class week of 5 November 2026: first working interaction

Goal: someone can try one input and see the intended response. Agree the next small goal with the tutor.

- Task owners: to agree
- Usable delivery / run link: pending
- Issues, PRs and tests: pending
- User or teammate observations: not yet recorded
- Tutor feedback: not recorded here; confirm with attendees rather than assuming no review took place
- Blocker or question: to prepare
- Next goal, owners and acceptance checks: to agree after review

## 6 November 2026: proposal and interaction review

- Completed documentation work: compared the current proposal with the course brief, screened the introductions of 36 supplied example repositories and inspected selected source excerpts from eight related projects. Added [design refinement](DESIGN-REFINEMENT.md) and [interaction references](INTERACTION-REFERENCES.md); updated README and the proposed team plan.
- Kept: the fantasy pharmacy setting and the original two-hand preparation idea. The original proposal remains unchanged.
- Changed: prioritise a small two-hand grinding prototype; explain the proposed relationship between gesture, material state and order scheduling instead of presenting camera use alone as the distinguishing feature. Keep a non-camera fallback and test tracking loss and comfort.
- Evidence boundary: no example projects were run, no new game code was produced and no user/tutor trial is claimed. The shared main branch contained documentation only at the start of this update; teammates may have work elsewhere.
- Open: share existing local work, confirm the actual 5 November review, agree prototype ownership and verify the current runtime and access. Do not close implementation tasks based on this document update.
- Assistance: Codex conducted the repository reading and drafted this refinement at IceyHikari's request. Team decisions and actual observations still need confirmation.

## Class week of 12 November 2026: integrated core experience

Goal: demonstrate the main game loop, app flow or installation interaction working together.

- Owners / usable delivery / evidence: pending
- Tutor feedback and blockers: not yet recorded
- Next goal with owners: pending review

## Class week of 19 November 2026: playtest and feedback

Goal: bring observations from another person trying the experience and choose an improvement.

- Owners / usable delivery / evidence: pending
- Actual playtest observations: not yet recorded
- Tutor feedback and next improvement with owner: pending review

### 19 November: low-fidelity flow and shared UI Kit

- I confirmed the low-fidelity flow as completed. I use the team's selected cooking-station image as the shared visual reference. The [design handoff](design/UI-KIT.md) links the flow, reference, controls and decoration boards in the same Figma file.
- I organised shared headers/navigation, action and icon buttons, main/mini order-ticket shells and checkboxes. The decoration pass adds resizable parchment and inset panels, wood frames, corners and edges, hanging rope/clips, dividers, material samples, numbered markers and small nameplates. Station-specific food, recipes and gesture instructions are excluded from the kit.
- Verification during the Figma work: inspected rendered specimens and corrected text remnants and wrapping; confirmed reusable instances and identical station-header geometry. A 484 × 213 panel resized to 720 × 280 retained four 24 × 24 corners. Other teammates' low-fidelity screens were not individually re-audited in this pass.
- Runtime boundary: this is a design delivery. Final-kit export, Godot theme/control integration, aspect-ratio reconciliation and in-game visual checks are pending. No new human playtest or tutor feedback is claimed.
- Remote implementation snapshot: `main` was `1c81f21`; [PR #7](https://github.com/sd5913/forlives--magic_kitchen/pull/7) (order station) and [PR #9](https://github.com/sd5913/forlives--magic_kitchen/pull/9) (shared playable shift, based on #7's branch) were open. This update does not merge their game code or claim their reported checks were rerun.
- Next: I coordinate the shared Godot UI handoff and viewport decision; station owners connect their content after ownership is agreed. Record asset provenance and export permissions, then check the integrated result with another player.

本次完成低保真进度同步、公共组件及装饰层交接；Figma 成果与 Godot 实现分开记录。后续由我统筹公共 UI 接入与视口尺寸，组员接入各自内容；真人试玩与 tutor 反馈保留为待记录。

### 19 November: design exports archived for review

- Archived four original-size low-fidelity PNGs from the Order, Roasting, Preparation and Scoring areas. I visually checked each export; source layouts were not edited or resized.
- Added two UI Kit board PNGs, seven individual component PNGs and five SVG icons. A [visual review page](design/README.md) embeds the deliverables; the [manifest](design/exports/manifest.json) records source nodes, dimensions, checksums and border margins.
- The selected low-fidelity screens retain their differing historical header layouts. Final common-header geometry belongs to the shared kit. This export pass does not assert that every old screen has been updated.
- PNG/SVG files do not replace editable Figma components or prototype connections. No Godot scenes changed and no human trial was performed for this archive.

本次把实际成果文件一并归档，不再只有文字与外链；四张低保真、两张组件展示、七张独立组件导出和五个 SVG 可直接在 GitHub 审查。原始尺寸与历史布局差异如实保留。

### 21 November: order-counter high fidelity and UI Kit gaps

- I completed the [order-counter high-fidelity design](design/ORDER-STATION.md) using the existing shared header, ticket shells, frames and controls. Selected orders expand on the left; other tickets remain compact. The design includes acceptance, three order details, all-order views and pause/resume.
- I addressed the component-page annotations with order, clock and three hand-shape icons, three recognition-strip states and a typography specimen. Teammate pages were not modified.
- Archived eleven screen/overlay PNGs, the UI Kit supplement, a separate generated counter illustration, five editable SVG icons and the prototype connection record. The earlier native Figma backup remains dated 19 November.
- Checked rendered layouts, Bree Serif consistency, button clearance and 44 configured prototype connections with valid destinations. No human trial or new tutor review was performed. Sample times are fixed; this does not implement camera input or update Godot scenes.
- Next: bring the agreed visual assets into the game, check the integrated order flow and collect an uncoached player trial.

本次归档了点单区高保真与组件补充的实际文件。原型可查看、展开和确认订单，公共顶部保持一致；Figma 设计、Godot 实现与真人试玩继续分别记录。

## Class week of 26 November 2026: delivery candidate

Goal: test a runnable build, deployment or installation setup on the chosen platform.

- Owners / build or deployment / reproduction checks: pending
- Tutor feedback, remaining blockers and next goal: pending review

## Class week of 3 December 2026: final tutor delivery review

Goal: rehearse the experience, check setup/access/credits and identify final fixes.

- Owners / demonstration / final run evidence: pending
- Tutor feedback and final fixes with owners: pending review

## 6 December 2026: final submission

This is the final Canvas deadline, not a tutor meeting.

- Final repository and README access: not yet checked for submission
- Runnable delivery and instructions: pending implementation
- Credits, weekly evidence and team contributions: keep updated
- Canvas group submission: not yet verified

Record actual results after each review. Plans, template cards and automated checks must not be presented as completed user trials or tutor feedback.
