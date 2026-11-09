# Herbs on the Clock: interaction refinement

6 November 2026. Proposed next design direction, prepared at IceyHikari's request. Team/tutor agreement, implementation and trials are pending. Read alongside the [original proposal](HERBAL-PHARMACY-PROPOSAL-EN.md), which this update preserves.

## Experience and audience

We want players to experience the work of a fantasy pharmacy apprentice: prepare herbs with care while customers compete for their attention. The proposed audience is PC players who enjoy short time-management games and want to try hands-on preparation. A three-minute shift is our initial scope target, not a tested duration.

Herb drawers, a small balance, a mortar and oil-paper packaging should take part in the actions. Herbs, symptoms and prescriptions are fictional. We do not claim to teach medicine or provide health advice.

## The interaction to test first

One hand controls grinding while the other manages an order with the mouse. This develops the original proposal's two-hand idea. Camera-controlled cooking already appears in related projects, so camera use alone does not establish a distinctive design. Our hypothesis is that maintaining a preparation rhythm while choosing which order to serve can produce a learnable coordination challenge.

Start with circular grinding only. Show the selected mortar, its order, material progress and tracking status. Lock the action to that mortar until the player stops or changes it explicitly; selecting another order must not redirect the active gesture.

Proposed mapping: a comfortable, calibrated motion range advances grinding; the material and grinding sound change with progress. Later, test whether excessive speed should produce a visible powder-spill warning. Do not punish camera noise or tracking loss as player error. A standard webcam does not measure physical pressure or weight: any speed/radius mapping is a game control, not a pressure sensor.

Players can stop, keep progress and resume. Offer handedness configuration and a mouse/keyboard alternative that uses the same preparation state. Allow reduced simultaneous-input demands; do not assume the two modes have equal difficulty. Test seated play and fatigue before asking players to sustain gestures.

## First playable slice

Build one prescription from herb selection through grinding, wrapping and delivery. Add a second order only when that loop works. With two orders, players can pause preparation to serve an urgent customer, or continue preparing while handling the other order with the mouse.

For the integrated shift, propose four fictional herbs, three prescriptions, one shared mortar, visible customer patience, a shift summary and retry. Treat these counts as adjustable scope. Confirm any existing team implementation before replacing it or starting duplicate work.

Test one recoverable interruption after the basic loop: prepared magical material becomes unstable unless wrapped. Give a warning before it occupies the mortar, let the player choose whether to finish an urgent order first, and provide a clear recovery action. No permanent lockout. Escaping herbs remain an alternative from the original proposal, not an additional mandatory system.

Defer slicing, a separate brewing system, multiple spells, upgrades and multiplayer until the slice works. The full feature list in the earlier proposal is a backlog, not a promise for the first delivery.

## Acceptance checks for the prototype

These checks define work to perform; none is recorded as passed yet.

| Check | Observable result |
| --- | --- |
| Run on another teammate's computer | Follow the documented prerequisites and launch steps without developer-only files |
| Finish a prescription | Select, prepare, wrap and deliver the correct herbs; see a result and restart |
| Coordinate the hands | Grind one selected item while selecting or preparing another order; both states remain understandable |
| Stop and resume | Preserve valid progress without unintended production or a reset |
| Lose tracking / deny the camera | Show the interruption, stop gesture-driven progress and allow recovery or alternative input |
| Repeat an input / make a wrong selection | Do not duplicate output; explain the mismatch and allow correction |
| Observe a new player | Record where they hesitate, whether the action-response mapping makes sense and one resulting decision |

## Implementation boundaries

The proposal originally listed Godot as tentative. See the [9 November engine decision](ENGINE-DECISION.md) for the selected stack; reconcile any existing local project before integration. If camera recognition runs in a separate process, test startup, communication, disconnects and packaging early.

Keep order state and processing rules independent of input method. Customer departure should release tool references safely. Pause timers when the game pauses or loses focus. Show important feedback with text/shapes as well as colour or sound.

Plan for local camera processing without recording or uploading frames by default; verify the actual implementation and dependencies before publishing that privacy claim. Document any model downloads, permissions and offline limitations. Do not commit credentials or participant recordings.

## Evidence and next milestones

The 5 November review outcome is not recorded. Ask attendees for the actual demonstration, feedback or blocker; do not reconstruct a meeting from the plan.

- **12 November:** demonstrate the integrated core, adjusting scope with the tutor if needed. Share existing code and prototype evidence first.
- **19 November:** bring observations from another person and a justified design change. Compare input modes if both prototypes exist; vary which mode people try first.
- **26 November:** reproduce a build on another computer, including input failures and fallback.
- **3 December:** final tutor review; check instructions, credits and access.
- **6 December, 23:59 HKT:** final Canvas repository deadline. Verify actual Canvas group settings and submission.

The [brief](https://github.com/sd5913/pfad/blob/2026/assignments/group-project.md) weights creative idea, code and execution at 25%, 50% and 25% of the project mark. A distinctive input needs a working experience and evidence of iteration. Reference projects do not provide a guarantee of marks.

## 中文摘要

我们保留原提案的古风奇幻药房与双手分工，先验证“一手研磨、一手管理另一张订单”。动作要改变材料状态，并影响安排工作的选择，不能只替代一个开始按钮。先做一单闭环，再增加第二张订单、一个可恢复事故和营业结算。

摄像头追踪失败时停止加工并显示原因；键鼠提供替代。普通摄像头不能测真实压力或重量。引擎版本见 11 月 9 日技术选型，先同步组员已有工程。本文是设计修订和验收计划，没有把未发生的试玩、课堂反馈或实现写成完成。
