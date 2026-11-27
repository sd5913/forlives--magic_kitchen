# Feedback and changes / 反馈与调整

Recorded on 25 November 2026 from the team's recollection supplied by JIN Minyi. The original session dates, tested versions and meeting-note location are still to be confirmed. This record separates that account from the assistant's later code inspection and automated checks. It contains no reconstructed quotations.

本记录于 2026 年 11 月 25 日根据我（JIN Minyi）补充的组内回忆整理。原试玩日期、当时版本与会议记录位置仍待确认。下文区分转述经历、之后的代码核对与自动检查，不补造逐字原话。

## Teammate trial / 同学试玩

A classmate found that gestures could trigger effects belonging to different screens. We revised the gesture interaction, isolated it between screens, and changed poses to make them more distinguishable. That is the reported feedback-to-design change; the exact previous and revised pose set should be linked from the original meeting record before claiming a specific mapping was validated.

同学试玩时发现手势会唤起不同界面的效果。我们随后修改手势交互、做界面之间的隔离，并使用更有辨识度的手势。这是已转述的反馈与调整；具体旧版／新版姿势应补上原会议记录，不能据此声称某套编号已经通过真人验证。

| Evidence stage / 环节 | What is supported / 已有依据 | Still missing / 尚缺 |
| --- | --- | --- |
| Observation / 问题 | Classmate reported cross-screen gesture effects / 同学发现跨界面手势触发 | Original date, tested version and record link / 日期、版本及记录链接 |
| Decision / 调整 | Revise interaction, isolate screens, improve pose distinguishability / 修改交互、隔离工作区、增强区分 | Exact agreed gesture set; 2/4 conflict remains in module handoffs / 定稿姿势，当前 2/4 冲突仍需统一 |
| Current code / 当前实现 | `shift_game.gd` invalidates input after navigation/selection/pause; `shift_session.gd` maps actions by active station and stage; `gesture_gate.gd` requires neutral release / 切站切单暂停重置输入，按当前站和阶段处理，需释放再触发 | Actual live-camera re-trial of the current integrated build / 当前整合版的真人相机复测 |
| Automated evidence / 自动验证 | Flow and UDP suites cover held-pose suppression and neutral release after context change / 流程与 UDP 检查覆盖持续手势和切换后的释放 | These are simulated inputs, not measured camera recognition or player comfort / 模拟输入不能证明识别率或舒适度 |

## Tutor reviews / Tutor 展示

JIN Minyi later supplied the teacher’s original comments and proposed responses. They are reproduced in the root [README](../../README.md#project-feedback--improvement-plan-teachers-original-comments). The review date and exact build/version shown still need confirmation. The proposed improvements are plans, not evidence that they have been implemented; this record does not imply approval of the latest scope or final submission.

之后，JIN Minyi 补充了老师的原始意见及拟采取的改进方向，详见根目录 [README](../../README.md#project-feedback--improvement-plan-teachers-original-comments)。审阅日期及当时展示的具体版本仍待确认。改进内容属于计划，并不代表已经实现；本记录也不表示老师已认可当前全部范围或最终提交。

## Question for the 26 November review / 11 月 26 日拟提问

Our design question is whether players can predict what a gesture will do after switching stations. Please try switching from roasting to preparation while keeping the same pose: does the active-station cue and release requirement make the next action understandable, or does it feel unresponsive? Observe unintended actions, hesitation and any need for explanation. Record counts/times only if measured.

拟请 tutor 检查：玩家换工作区后，能否预判同一手势接下来会做什么？可以保持手势从烤炉切到料理台，观察当前工作区提示与释放后再触发是否清楚，还是会觉得操作失灵。记录误触发、犹豫和需要解释之处；只有实测才写次数与耗时。

This is our proposed professional review angle, not a remembered tutor comment. Scope questions (one-order demo versus five-order shift, return destination, recipe-error policy and gesture 2/4) also need a single planning decision.

以上是我们这次拟讨论的设计问题，不是补写老师以前说过的话。一单演示／五单营业、返回位置、配方失误和手势 2/4 仍需总策划统一。

## Submission status / 提交状态

The later Canvas submission-details screenshot confirms that JIN Minyi submitted the correct group repository URL on 25 November at 07:57 (the time displayed by Canvas). The URL is https://github.com/sd5913/forlives--magic_kitchen. This supersedes the earlier same-day report that submission was pending. The displayed score is “-/40”, so no grade or final assessment result is established.

随后提供的 Canvas 提交详情截图确认：JIN Minyi 于 11 月 25 日 07:57（Canvas 显示时间）提交了正确的小组仓库 URL：https://github.com/sd5913/forlives--magic_kitchen。此前同日“待提交”的状态已被新回执更新。页面评分为“-/40”，尚不能据此认定已评分或通过最终审查。
