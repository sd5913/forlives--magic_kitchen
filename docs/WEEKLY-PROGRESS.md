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

### 16 November: PR #7 Linux CI setup correction

- Diagnosis: PR head `2a4c26e` failed during setup-python, because the Ubuntu 26.04 runner had no Python 3.9 build. The project checks had not started; the Windows and macOS jobs passed.
- Change: select Python 3.13 on the existing three-platform matrix, using the official actions/python-versions manifest to confirm an Ubuntu 26.04 x64 build. No tests were disabled and no gameplay files changed. Run outcomes remain inspectable on PR #7.

### 14 November: NEKO ordering implementation prepared for review

- Design input: user supplied GDD v1.0 for Peking duck rolls and confirmed NEKO / JIN Minyi owns ordering. The user rejected the first flat-vector visual draft and supplied a warm, faceted low-poly kitchen reference; that draft was replaced before any push.
- Implemented on `feature/order-station`: isolated order manager, data-driven ingredient requests, customer arrival and selection, guarded acceptance/capacity, waiting and expiry, English/Chinese UI, pause and restart confirmation. Added a station overlay to the existing order panel; other zones and shared project settings were left unchanged.
- Art: generated background, customer sheet, food-icon sheet and panel textures to follow the supplied reference. UI text, order state and buttons remain live Godot controls. Existing remote branches contained no matching art; Figma access was denied, so this is not a verified Figma reproduction.
- Verification on Windows / Godot 4.7.2 / Compatibility renderer: 38 manager checks and 31 rendered UI checks passed, along with six existing Python router tests. Fixed oversized texture borders and verified local art imports, alpha, small-window layout, capacity, expiry, mouse/keyboard input and open/close behaviour. Screenshots and reproduction commands are linked in the [module guide](technical/ORDER-STATION.md).
- Pending: review by the team's visual owner, real teammate trial and integration of oven/prep/delivery/scoring. No player or tutor feedback was invented. This is a usable ordering increment, not the completed cooking game.

### 15 November: bilingual alignment follow-up

- User feedback: English and Chinese appeared misaligned; use English by default for presentation and retain a Chinese toggle.
- Changed: explicit vertical centring and text rectangles, language-specific heading fonts, queue subtitle/time heights, centred ingredient captions and customer nameplates. Some short text boxes were smaller than the system font's minimum height and Godot expanded them; the layout check now catches that condition.
- Evidence: the rendered UI/layout run passes 385 assertions, including same-ticket bilingual screenshots, label bounds and button-geometry comparisons. The checks use simulated input; this is user-directed iteration, not an invented classmate trial. Final visual-owner review and fresh-machine/export checks remain pending.
- Reproduction: a fresh local clone of code commit `141e96c`, without cached imports, passed asset import, 38 state checks, 385 UI/layout assertions and the repository checker on this Windows machine. A second physical machine and exported build have not been tested.

### 16 November: macOS order station improvement

- A clean export of [PR #7](https://github.com/sd5913/forlives--magic_kitchen/pull/7) exposed font-loading errors and 18 UI layout failures on macOS. I changed the macOS font selection and enlarged the title, ingredient quantities and customer name boxes.
- Verification on this Mac with Godot 4.7.2 Standard: 38 order state checks and 385 rendered UI assertions passed. [Reproduction steps](technical/ORDER-STATION.md#macos-verification)
- For the tutor review, ask someone to open the order station, find an ingredient requirement, accept a ticket and locate its waiting indicator. Record where they hesitate, then choose one change based on what they did. The cooking stations are still the integration blocker. Human observations and tutor feedback are pending.

### 17 November: integrated playtest

- Connected the same ticket from acceptance to timed roasting, ingredient matching and delivery. The workbench owns the manager and clock. A wrong recipe can be cleared and retried, and expiry clears food in progress.
- Automated verification on macOS with Godot 4.7.2 Standard passed 38 order manager checks, 385 rendered order-station assertions and the integrated path from acceptance to delivery. The integration check also covers rejected recipes, pause, expiry and duplicate delivery.
- Before the tutor review, have another person try a complete order with no initial walkthrough. Watch whether they find the ticket requirements, know where to roast and can recover from a recipe mismatch. Record one observation and the change it motivates. Human observations and tutor feedback are pending.

### 18 November: full shift regression

- Automated regression on macOS with Godot 4.7.2 Standard covers acceptance, roasting, recipe correction, delivery, expiry and repeated delivery. Added checks for two-ticket switching, a busy oven, isolated ingredient selections, focus loss and restart confirmation/cancellation.
- Fixed the restart confirmation: both the shared clock and guest arrivals now pause while it is open. Cancellation restores controls and preserves food; confirmation clears food and old tickets, resets timers and keeps an existing pause.
- Verification: 38 order-manager checks, 27 shift checks, 385 rendered UI assertions, six Python interaction tests and the repository checker passed. A rendered shift run also saves ready/served screenshots and checks both files. These are automated observations, not human playtest feedback.
- Remaining evidence for the 19 November review: another person tries a complete order before receiving instructions; record observed hesitation, choose one improvement and record tutor feedback. Exported-build and fresh-machine checks remain pending.

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

### 22 November: food icons, numbered hands and hawthorn correction

- I clarified the annotations: the missing order icons are food illustrations, and the requested hand set shows numbers 1–5 plus a fist. Added six food components, six hand components and `MK/GestureHint` with replaceable food/gesture instances and editable labels.
- Confirmed mapping: 1 duck, 2 cucumber, 3 scallions, 4 hawthorn strips, 5 sweet bean sauce; fist rolls the wrap. The old generated reference’s green garnish and “Pickled Radish” are incorrect. Added a visible correction beside that reference without editing teammate pages.
- Reused the food components in the order-page recipe rows, including a red hawthorn example in Order 03. Archived twelve native transparent 256 × 256 PNGs, the component board, two source atlases and refreshed affected page previews.
- Inspected the rendered hand counts, ingredient colours, component swaps, readable layout and alpha channels. A preview-download export initially flattened transparency; native content-only exports preserve it. No camera or Godot implementation was changed, and no human trial is claimed.

本次纠正“订单图标”和“手势”的理解，完成实际食物插画、数字手势、透明素材与可替换提示卡。第 4 项统一为红色山楂条；设计原型和运行时实现继续分开记录。

### 22 November: food and hand visual revision

- I redrew the six food icons and six hand illustrations after feedback that their first rendering looked too realistic. The current set uses warm colour blocks, clear pixel contours, rounded silhouettes and simplified shading.
- Replaced the illustration fills inside the existing main components. Their IDs, hint-card properties, ingredient mapping and prototype connections stay in place, so existing instances update together.
- Refreshed the twelve transparent 256 × 256 PNGs, both source atlases, the component board and four affected order-page previews. Checked assembled layouts, hand counts, alpha channels and export records. This updates Figma assets only; no runtime or player trial was performed.

本次按反馈调整食物与手势画风，减少写实纹理，统一为像素游戏插画。红色山楂条、数字对应关系和组件结构保持一致，已有实例同步更新。

## Class week of 26 November 2026: delivery candidate

Goal: test a runnable build, deployment or installation setup on the chosen platform.

- Candidate: keyboard/mouse shared shift and approved order counter; PR #10–#12 integrated. Local project pack requires Godot 4.7.2. See [delivery check](assessment/READINESS-2026-11-25.md); fresh-machine reproduction and final asset rights are pending.
- Tutor feedback, remaining blockers and next goal: pending review

## Class week of 3 December 2026: final tutor delivery review

Goal: rehearse the experience, check setup/access/credits and identify final fixes.

- Owners / demonstration / final run evidence: pending
- Tutor feedback and final fixes with owners: pending review

## 6 December 2026: final submission

This is the final Canvas deadline, not a tutor meeting.

- Final repository and README access: not yet checked for submission
- Source-import route and local project pack exist; final release/platform reproduction and asset rights remain pending.
- Credits, weekly evidence and team contributions: keep updated
- Canvas group submission: receipt checked on 25 November; correct repository URL submitted at 07:57 as displayed by Canvas. Final grading is pending.

Record actual results after each review. Plans, template cards and automated checks must not be presented as completed user trials or tutor feedback.


## 23 November 2026 / 2026 年 11 月 23 日

We integrated the six-part flow supplied by the team: timed arrivals, four tickets, two independent oven slots, take-out and slicing, five-ingredient preparation, scored serving and a five-order summary. The latest flow changes the input mapping to 2 hawthorn / 4 cucumber. Trial values remain configurable pending planning confirmation.

我们按组内提供的六部分流程接通到达、四张订单、双炉位、取出片鸭、五种配料、交付评分和五单汇总。新稿映射为 2 山楂 / 4 黄瓜，试运行数值集中配置，等待策划确认。

Resolved archive/start-scene conflicts while preserving the order, cooking, serving and roasting-design contributions. Fixed a malformed old cooking scene. The [handoff](technical/INTEGRATION-HANDOFF.md) lists the rule, final-art and validation work still needed from each module.

整合保留点单、料理、交付及烘烤策划贡献，解决归档和启动入口冲突，并修复旧料理场景损坏。[对接清单](technical/INTEGRATION-HANDOFF.md)列出各部分仍需补齐的规则、美术和验证。

Actual macOS/Godot 4.7.2 checks: seven game suites passed; new flow 67 and UDP 9 checks; existing order manager 38, order UI 378 and legacy shift 27 checks, plus cooking regression. Seven integrated screens were rendered and inspected. Six Python input tests and repository checks passed. The camera environment initialized its model and processed a blank frame. A project pack exported and launched. No human playtest, live-camera gesture result, Windows gameplay or tutor feedback is claimed.

实际验证平台为 macOS、Godot 4.7.2：七组游戏检查通过；新流程 67 项、UDP 9 项；原管理器 38 项、点单界面 378 项、旧试玩 27 项及料理回归通过。七种整合画面已渲染检查，Python 六项输入测试和仓库检查通过。相机环境完成模型初始化和空白帧处理；资源包已导出启动。未据此声称真人试玩、摄像头手势效果、Windows 玩法或教师审查通过。

## 24 November 2026 / 2026 年 11 月 24 日

I connected our approved green-clothed customer counter to the shared shift, replacing the temporary integration layout for ordering. The original illustration, font, frames and icons are reused. Accepting, compact tickets, expanded recipes, all orders and pause now operate on the existing shared session. Roasting and preparation keep their current layouts.

我把定稿的绿衣顾客点单台接入统一营业，替换点单环节的临时整合排版。复用原插画、字体、边框与图标，接单、紧凑订单、展开展示、全部订单和暂停均连接已有共享状态；烤炉和料理保留当前布局。

I fixed two issues found during the integration run: opening a ticket must not steal window focus and pause the shift; preparation progress must count the selected recipe's requirements instead of always showing five ingredients. Overlays now block background keyboard and gesture actions.

我修复了整合试玩中发现的两处问题：查看订单不应因弹窗抢焦点而暂停营业；配料进度应按当前配方计算，不能固定显示五种。弹层打开时也会阻止底层键盘与手势操作。

On macOS / Godot 4.7.2, all eight game suites passed. Eight counter states were rendered, with 28 assertions including saved images. I also used the running window to accept an order, open its details and the order list, switch to roasting and return, then pause. These are assistant-operated checks, not another person's playtest. Windows gameplay, live-camera recognition and tutor review are still pending.

在 macOS / Godot 4.7.2 下，八组游戏检查通过。点单八种状态实际渲染，包含图片保存共 28 项断言通过；也在运行窗口实际点击接单、查看小票和列表、切到烤炉再返回并暂停。这些是助手操作检查，不是其他同学试玩；Windows 玩法、真人摄像头识别和教师审查仍待完成。

### Navigation follow-up / 跳转复查

I ran one order through acceptance, roasting, slicing, preparation, rolling, scoring and return in the actual macOS game window. Switching to the counter and back preserved the recipe progress. This run returned a score of 48 (ordering 45, burnt roast 0, preparation 100); it verifies the flow, not a high-score claim. Returning currently opens the counter, which differs from the new serving demo's preparation/test-entry return requirement and remains a planning decision.

我在 macOS 实际游戏窗口完成了一单接单、烤制、片鸭、配料、卷制、评分与返回。制作中切到点单再回来，配料进度保留。本次得分 48（点单 45、烤焦 0、料理 100），用于检查流程。当前返回点单台，与新交付 Demo 要求的料理台／测试入口存在差异，留待策划统一。

The run exposed a layout defect in the generic ticket overlay: the detail branch inferred an incompatible typed array and stopped before adding its content. I fixed the array type, added explicit content space and deferred centering, plus checks for visible recipe content, the close button and viewport bounds in both detail and list overlays.

本次发现通用小票详情分支的数组类型不匹配，导致内容生成中断。已修正类型、补内容空间并在布局后居中，同时检查详情和列表的内容、关闭按钮及窗口边界。

## 25 November 2026 / 2026 年 11 月 25 日

I checked the course brief and Week 8 guide against the repository. All four teammates have Admin permission; repository and board permissions remain separate. PR #12's checks passed and its ticket-detail fix is now on main. I made the README audience explicit, separated current progress from older snapshots, and prepared the [delivery checklist](assessment/READINESS-2026-11-25.md).

我对照课程要求和 Week 8 说明核对仓库，四位成员均有 Admin；看板权限另核。PR #12 检查通过，小票详情修复已合入主线。README 补明确受众，旧快照与现状分开，并整理[交付核对](assessment/READINESS-2026-11-25.md)。

I supplied my recollection of a classmate's cross-screen gesture feedback and the interaction revision, plus two tutor showings (low-fi and playable). The low-fi advice was to continue; the playable-review comments and original dates are not reliably recalled. The [feedback record](assessment/FEEDBACK-AND-CHANGES.md) labels the account and the later code evidence separately. This records prior events today; it does not assign them today's event date. At the time of that account the Canvas URL was reported pending; a later screenshot confirms submission at 07:57 on 25 November.

我补充了同学提出跨界面手势冲突、随后修改隔离，以及两次 tutor 展示（低保真、试玩）的回忆。低保真建议继续，试玩评价和原日期记不清。[反馈记录](assessment/FEEDBACK-AND-CHANGES.md)区分转述经历与后来的代码证据。今天补录不代表事件发生在今天。当时报告 Canvas 待交；后续截图确认已于 11 月 25 日 07:57 提交。

For the next review, I want to check whether players understand gesture meaning after a station switch, then confirm one agreed rule set. This is a proposed review question, not a fabricated past tutor comment. Live-camera retesting, original meeting notes, final module visuals, reference-art permissions and instructor board access remain open.

下一次 review 拟检查换站后手势含义是否可预判，再统一规则；这是待讨论问题，不是补写旧评价。真人相机复测、原会议记录、最终模块视觉、参考图许可与老师看板可见性仍需补齐。

### Submission receipt and clean-source delivery / 提交回执与干净源码交付

The supplied Canvas receipt confirms the correct repository URL submitted by JIN Minyi at 07:57 on 25 November as displayed. The score is still pending. I updated the current status and supporting pack; the earlier pending-submission account is superseded.

用户提供的 Canvas 回执确认 JIN Minyi 于 11 月 25 日 07:57（页面显示）提交正确仓库链接，尚未评分。已更新当前状态及材料包，此前待交记录以新回执为准。

I reproduced the README source-import path in a new public clone on the same Mac. Godot 4.7.2 imported the project and all eight game suites passed. I added and exercised `tools/package_review.py`: imports, exports, checks pack startup, preserves the font license, includes run instructions/logs and verifies the ZIP. This is development tooling and delivery verification, not a new game feature or a human test. Final visual modules, planning choices, asset rights and live-camera re-trial remain open.

我在同一台 Mac 的全新公开克隆副本复现 README 导入方法，Godot 4.7.2 导入及八组游戏检查通过。新增并实际执行 `tools/package_review.py`，完成导入、导出、资源包启动，保留字体许可、运行方法和日志，并检查 ZIP。这是交付工具和验证，不是新玩法或真人试玩；最终模块视觉、策划口径、素材许可及真人相机复测继续待办。
