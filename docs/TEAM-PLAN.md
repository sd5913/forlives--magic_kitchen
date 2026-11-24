# Team plan

## Current delivery plan — 25 November 2026

Our next review is the 26 November class-week delivery candidate; the tutor confirms the actual meeting time. We bring the playable keyboard/mouse flow, setup instructions, test evidence and unresolved design questions. The [readiness check](assessment/READINESS-2026-11-25.md) separates course requirements from improvement suggestions. Earlier pharmacy and ownership proposals below are historical.

下一节点是 11 月 26 日课周的候选版本 review，实际会面时间由 tutor 确认。我们带可玩键鼠流程、运行方法、检查证据和待统一的设计问题。[交付核对](assessment/READINESS-2026-11-25.md)区分课程要求与改进建议。下方药房及旧分工提案作为历史记录保留。

| Part / 部分 | Next deliverable / 下一项交付 | Acceptance / 验收 |
| --- | --- | --- |
| Planning and roasting / 总策划与烤炉 | Resolve gesture 2/4, recipe-error rules, demo scope/return and scoring ambiguity; deliver final roasting layers / 统一编号、失误规则、演示范围与返回、扣分歧义，并交付烤炉分层素材 | One agreed rule table and runnable station behavior / 一份统一规则表，对应可运行行为 |
| Ordering and integration / 点单与技术整合 | Keep the approved counter and shared state stable; connect agreed module handoffs / 维护定稿点单和共享状态，按统一方案接入 | Full order-to-score flow retains order identity and progress / 全流程订单身份与进度不丢失 |
| Preparation and shared UI / 料理与公共 UI | Final layout/assets and button, ticket, correction, input-status examples / 最终排版素材及按钮、小票、修正和识别状态示例 | Match approved design; every enabled/disabled state has a condition / 与定稿一致，每项按钮状态都有条件 |
| Serving and testing / 交付与测试 | Separate observation/reaction/coin assets, sequential score presentation; player and launch evidence / 观察、表情、铜钱分层素材与逐项评分，组织试玩和启动验证 | Correct order/result binding, feedback and return; actual observations recorded / 订单结果绑定、反馈返回正确，记录真实观察 |

These are module responsibilities from the agreed four-part division, not a claim that their handoff is already complete. Each module owner records its actual contributor and evidence in the issue or weekly note. Runtime-use rights for reference-derived artwork must be resolved before calling the delivery ready for public distribution.

以上按四部分分工记录，不代表已经完成交接；各模块在任务或周记录中填写真实贡献者及成果链接。参考图衍生素材的运行使用许可需明确，再认定可公开分发。


## Historical design handoff — 19 November 2026

I confirmed the low-fidelity flow as completed and prepared the shared Figma UI Kit. The [UI handoff](design/UI-KIT.md) records component coverage, the approved visual reference and remaining Godot integration; [current project status](PROJECT-STATUS.md) distinguishes main from open implementation PRs. I coordinate shared UI integration and the viewport decision. Station-specific content owners still need to be agreed. The dated plan below is historical and does not override the current roast-duck direction.

我已确认低保真流程完成，并整理公共 Figma UI Kit。[组件交接](design/UI-KIT.md)记录设计范围和待接入工作，[项目状态](PROJECT-STATUS.md)区分主分支与未合并实现。公共 UI 接入和视口决策由我统筹，具体工作台内容负责人仍需组内确认。下方为历史计划，不覆盖当前烤鸭游戏方向。

## Proposed goal for 6 to 12 November 2026

Share any existing local project before starting parallel implementation. Connect one prescription from herb selection through grinding to delivery, then test grinding with one hand while managing another order with the mouse. See [design refinement](DESIGN-REFINEMENT.md) for scope and acceptance checks. Confirm owners and the tutor's feedback before treating this as the team's agreed commitment.

The original goal was a first working interaction for 5 November. Its delivery and review evidence remain unrecorded; this planning update does not mark that goal complete.

## Decisions to make

| Decision | Current state | Owner |
| --- | --- | --- |
| Intended user and purpose | Proposed: PC players who enjoy short time-management games and want to try hands-on preparation | Team/tutor to confirm |
| Main input, response and visible feedback | Proposed: continuous grinding with one hand while the mouse manages orders; visible material progress and order binding | Prototype owner to agree |
| Chosen platform/runtime | [Godot 4.7.2 Standard, GDScript, Compatibility](ENGINE-DECISION.md); Windows/macOS desktop first. Camera remains optional | JIN Minyi (technical decision) |
| Multimedia needed for the idea | Proposed: readable herb/tool states, grinding animation and sound, customer/order feedback; asset sources to record | Team to agree |
| Tutor and exact meeting slot | To confirm | Team to agree |
| Group member GitHub usernames | IceyHikari, MiaJiao5, deadlytomatovo, ZHANGYan-Sybil | Confirmed from supplied accounts |
| Repository Write access | 6 November permission API: all four Admin; actual push checks and Project access still require separate verification | Repository administrator / teammates |
| Team Project board | [Existing board #23](https://github.com/orgs/sd5913/projects/23), created by MiaJiao5 and linked to repository; IceyHikari can edit | Board administrators; teammates to verify access |

Do not put student numbers, emails or private meeting details in this public document.

## Scope and implementation backlog

| Task | Acceptance checks | State |
| --- | --- | --- |
| Agree audience, scope and first interaction | Record who uses it, what they do, expected response, feedback and an ordinary error; confirm with tutor | Todo |
| Confirm team access and planning board | All actual teammates can push a branch and edit the board; tutor can view; README links the team's board | In progress |
| Build the first interaction | A teammate can run the documented command/build and use the agreed interaction; attach real evidence | Backlog, depends on scope |
| Share existing work and review evidence | Link any local implementation and record the actual 5 November delivery/feedback, or record why no delivery occurred | Unverified; owner to agree |
| Test the two-hand interaction | Complete a bound grinding task while selecting a second order; pause/resume safely; show tracking status and a fallback | Proposed; owner to agree |
| Integrate a playable shift | Add customer patience, a recoverable interruption, an end state and retry after the one-order loop works | Proposed; depends on prototype |

Assign each implementation task to a real teammate before starting. The initial workflow work is being prepared at IceyHikari's request; this does not assign other team members to unagreed responsibilities. Read [shared status and handoff](PROJECT-STATUS.md) when continuing on another computer.

## Board setup

[Magic Kitchen team board #23](https://github.com/orgs/sd5913/projects/23) is the existing board created by MiaJiao5 from [Group Project 2026](https://github.com/orgs/sd5913/projects/1), owned by **sd5913**. It contains all five tutor review cards, the final deadline card and the starter planning card. Those existing cards are preserved. The repository is linked, and the setup issues have been added. A temporary duplicate was created while this board was inaccessible; setup was consolidated back into #23 at the team's request.

Use the template's weekly Iteration field and views. A useful status flow is Backlog → Todo → In progress → Review → Done. Check the copied automation settings rather than assuming closed issues or merged PRs meet the Definition of Done. A Project's collaborators and repository links do not automatically come from the template.

Three repository issues are linked to the board: [scope #1](https://github.com/sd5913/forlives--magic_kitchen/issues/1), [access #2](https://github.com/sd5913/forlives--magic_kitchen/issues/2) and [first interaction #3](https://github.com/sd5913/forlives--magic_kitchen/issues/3). The setup record placed scope/access in the first iteration and implementation in Backlog; current Project statuses need a fresh check. Repository permissions now report all four members as Admin, while actual push checks, Project editing and tutor visibility remain unverified. The board was private at setup; check its current base access in Settings (Read or No access). These settings are not inferred from repository membership.
