# Course delivery readiness — 25 November 2026

## Conclusion / 结论

We have a playable keyboard/mouse foundation and an implemented order-counter design. We cannot yet claim that every course requirement is evidenced or that the final visual delivery is complete. The immediate priorities are a reproducible delivery candidate, a documented trial by another person, actual tutor feedback and adaptations, final module integration, and resolved asset attribution.

我们已有可玩键鼠基础和已接入的点单定稿，尚不能认定课程要求全部有证据、最终视觉全部完成。当前优先补可复现的候选版本、他人试玩记录、真实 tutor 反馈与调整、模块最终接入和素材来源。

Sources checked: [group-project brief](https://github.com/sd5913/pfad/blob/2026/assignments/group-project.md), [Week 8 teamwork guide](https://github.com/sd5913/pfad/blob/2026/week08/teamwork.md), current main README, contribution/progress/credits files, PRs #10–#12, repository and collaborator permissions, and the public releases API. Canvas screenshots supplied by the team agree with the brief. A later supplied Canvas receipt confirms the correct URL and 25 November 07:57 displayed submission time; the tutor calendar was not inspected.

核对依据为课程项目要求、Week 8 协作说明、当前主线 README、协作／进度／致谢、PR #10–#12、仓库及成员权限、公开发布 API。用户提供的 Canvas 截图与项目要求一致；后续提供的 Canvas 回执已确认正确 URL 与 11 月 25 日 07:57 的显示提交时间；未查看 tutor 日历。

## Requirement check / 要求对照

| Requirement / 要求 | Evidence / 当前证据 | Status and remaining action / 状态与缺项 |
| --- | --- | --- |
| One public sd5913 repository / 同一组织公开仓库 | `sd5913/forlives--magic_kitchen`, public, default `main`; metadata checked 25 November / 11 月 25 日元数据核验 | Met / 满足 |
| Teammates have write access / 成员可写 | IceyHikari, MiaJiao5, deadlytomatovo, ZHANGYan-Sybil all report Admin / 四位均有 Admin | Permission met; actual push and board access are separate / 权限满足，实际推送及看板另核对 |
| Usable interactive project and source / 可用交互与源码 | Shared order → roast → prepare → score; order retention, mistakes, expiry, restart; PR #10–#12 / 主流程和状态处理 | Working foundation; final station visuals and design conflicts remain / 基础已实现，最终美术和规则冲突待处理 |
| Idea, audience and response / 创意、受众与反馈 | README describes short cooking/time-management play and station behavior / README 介绍短局料理经营与工作区反馈 | Audience made explicit; novelty and usefulness need player evidence, not a claim of uniqueness / 已明确受众，差异与价值需试玩支撑 |
| README setup, platform and limitations / 安装、平台及限制 | Godot 4.7.2 import/run, keyboard/mouse mapping, macOS evidence, camera/Windows limits / 运行方法及已验证范围 | Source route reproduced in a new clone on macOS on 25 November; a teammate/fresh-device run remains separate / 11 月 25 日已在全新克隆副本复现；他人／换机仍另测 |
| Appropriate multimedia / 与体验相符的多媒体 | Original counter illustration, shared textures, food/hand images, interface feedback / 插画、纹理、食物手势与界面反馈 | Visual evidence exists; final roasting/serving states still pending. Sound/video are not individually mandated by the brief / 已有视觉，最终烤炉交付状态待补；课程未逐项强制声音或视频 |
| Trial with another person / 他人实际体验 | Teammate reported cross-screen gesture conflicts; team revised/isolated gestures, reported on 25 November / 已转述同学发现跨屏手势冲突及后续修改隔离 | Reported trial and adaptation recorded in [feedback notes](FEEDBACK-AND-CHANGES.md); dates/version and current-build live-camera retest pending / 已记录转述试玩与改进，补日期版本及当前版相机复测 |
| Shared planning, ownership and meaningful contributions / 协作及贡献 | Team plans, contributor history, Figma/source handoffs, PRs and weekly notes / 计划、真实贡献、交接与 PR | Partial: update owners and acceptance evidence; design work counts when its contribution is traceable / 部分满足，补责任人与验收证据，不以代码量替代设计贡献 |
| Weekly review, feedback and adaptation / 每周 review 与调整 | Dated cards/notes exist; several early weeks still contain placeholders / 有日期记录，早期仍有占位 | Partial: two tutor showings reported; low-fi advice was to continue. Playable-review comments/date not recalled / 已转述两次展示，低保真建议继续；试玩评价和日期待核 |
| Board/progress reachable by instructor / 老师可访问进度 | README links existing Project #23 and public weekly notes / 已链接 #23 与公开周记录 | Public notes accessible; authenticated board/tutor visibility not verified this audit. Do not create another board / 周记录可见，看板老师权限待核；不另建看板 |
| Credits, AI disclosure and licensed assets / 来源、AI 与许可 | CREDITS plus Figma manifests and included Bree Serif OFL notice / 致谢、来源清单、字体许可 | Partial: reference-derived art creator/runtime permission still explicitly unresolved; resolve or replace affected art / 参考图作者及运行许可仍有待确认，需补齐或替换 |
| Secrets configured without exposure / 密钥与私密信息 | Keyboard/mouse game requires no API key; ignored local environments/config / 基础游戏无密钥依赖，忽略本地配置 | No new secret configuration needed for core play. A full history secret scan was not performed / 基础玩法无需新增配置；未执行全历史密钥审计 |
| Canvas repository URL / Canvas 仓库链接 | Correct URL identified below / 正确地址见下 | Submitted: Canvas screenshot shows JIN Minyi, 25 November 07:57, correct URL; grade pending / 回执确认已提交，显示 11 月 25 日 07:57，地址正确，待评分 |

## What to submit / 最终提交什么

Canvas requires the group's repository URL in the assignment's Website URL field:

Canvas 作业的 Website URL 栏提交小组仓库地址：

```text
https://github.com/sd5913/forlives--magic_kitchen
```

Deadline: **6 December 2026, 23:59 HKT**. Keep the same repository, source, README and evidence accessible. Follow the actual Canvas group submission settings and retain its receipt. This is separate from individual Assignment 3. The brief does not introduce an extra Canvas upload for weekly records, nor require a separate report, slide deck or video as an additional final submission. Tutor requests and actual Canvas settings may add instructions; check them directly.

截止为 **2026 年 12 月 6 日 23:59，香港时间**。继续使用同一仓库，保证源码、README 和证据可访问；按实际小组提交设置操作并保存回执。与个人 Assignment 3 分开。当前要求没有额外引入每周 Canvas 上传，也没有列出必须另交报告、幻灯片或视频；若 tutor 或实际 Canvas 页面有补充，以其明确要求为准。

A downloadable build is helpful when appropriate, not a prescribed engine/store requirement. The releases API returned no published release on 25 November. The local `.pck` needs Godot 4.7.2; it is not a standalone macOS or Windows executable, and a desktop-only path is not an instructor download link. The current source-import route is documented. Before publishing a release, settle the art-use rights and validate the exact package on the chosen platform.

可下载版本有助复现，但课程不指定引擎或应用商店。11 月 25 日 releases API 未返回已发布版本。本地 `.pck` 需要 Godot 4.7.2，不是独立 macOS／Windows 应用；本机桌面路径也不是老师的下载入口。现有源码导入方式已写明；公开发布前需明确美术许可并验证实际包。

## 26 November review / 11 月 26 日 review

The class-week focus is a delivery candidate: a runnable build, deployment or installation setup. Confirm the actual tutorial time with the tutor. Bring:

本课周重点是可运行版本、部署或安装方案，实际时间向 tutor 确认。带上：

1. The exact source/build version and a tested way to launch it on the chosen machine / 明确版本与已验证启动方法。
2. One complete order from acceptance to return, plus ticket switching, pause, one ordinary mistake and recovery / 一单完整流程，加切单、暂停、普通失误与修正。
3. Test evidence with platform and date: game checks, actual launch, and observations from another person / 带平台日期的检查、启动和他人体验记录。
4. The shared board, current four-part ownership and each contributor's linked deliverables / 看板、四部分分工与真实成果链接。
5. One main question: confirm demo scope, gesture 2/4, mistake/roll policy, return destination and final balance in one agreed rule table / 主要问题为统一演示范围、编号、卷制失误规则、返回位置和平衡参数。
6. A place to record actual tutor comments and the next change with an owner / 会后记真实反馈、下一步与负责人。

These are a practical review pack, not additional Canvas submission requirements. The next final tutor review is the **3 December class week**.

以上是 review 准备材料，不是新增 Canvas 提交要求。下次最终复核为 **12 月 3 日课周**。

## Scoring priorities / 对应评分的改进顺序

| Criterion / 评分 | Current evidence / 目前能展示 | Highest-value next action / 优先改进 |
| --- | --- | --- |
| Code 50% / 代码 | Shared clock/state, dual ovens, per-order food, input guards, correction, score, expiry/restart, regression checks / 已有复杂度处理 | Finish coherent module integration, freeze one rule set, test a clean launch and complete loop with a teammate; verify promised camera behavior or present it as optional / 完成统一规则和接入，让他人按说明实际跑完；相机效果未验证就明确可选 |
| Execution 25% / 执行 | Incremental history, design assets, PRs, bug fixes and logs / 有增量与真实产物 | Connect each person's work to accepted outcomes and actual review/player feedback → change → verification; clear old placeholders and current/historical confusion / 贡献连到成果，反馈连到改进与验证，清理现状混淆 |
| Creative idea 25% / 创意 | Beijing roast-duck setting, station scheduling, recoverable preparation mistakes; optional gestures / 题材、调度、可修正失误 | Show why these choices improve the intended player's experience; compare mouse/gesture only if actually tested. More screens or AI use do not establish novelty / 用真实体验说明设计价值，不靠页面数或 AI 标签证明新颖 |

The rubric does not grade raw commit/card counts or formal role titles. No justified numeric score or class ranking follows from the available evidence. A short, stable, well-tested experience with traceable team decisions is the stronger target than extra features before delivery.

评分不按提交／卡片数量或头衔；现有证据也不足以给出可信的具体分数或班级排名。当前应把既有体验做稳、做完整、说明真实协作与取舍。

## Contribution still outside main / 尚未接入主线的成果

The fetched `feature/cooking-station` branch contains newer cooking assets and scene work at `b260dcd`. That work is a real contributor delivery, but this audit did not run it and it is not automatically the shared shift's final preparation view. Compare it with the agreed cooking handoff and integrate the accepted parts before producing another visual replacement.

已获取的 `feature/cooking-station` 分支在 `b260dcd` 有更新的料理素材与场景。这是组员的真实成果，但本次未运行该分支，也不能直接认定已成为统一营业的最终料理界面。下一步应对照料理交接核对并接入已确认部分，不另造替代界面。

## Evidence still needed / 待补证据

- Other-person trial: use [the playtest record](PLAYTEST-RECORD.md); no invented quotes or device/date information / 他人试玩按记录表填写，不补造原话、设备或日期。
- Tutor feedback: actual meeting/date, comments, next goal and owner; earlier reviews can be recorded now with their actual event date and today's recording date / 反馈按真实会议记录，补录同时注明发生与记录日期。
- Permission: source author, original URL/license or permission evidence for reference-derived art / 素材作者、原链接、许可或授权依据。
- Fresh-machine/platform reproduction and board/tutor access / 换机或目标平台复现、老师看板可见性。
- Canvas receipt verified from the supplied screenshot; retain it privately. No resubmission is needed merely to reflect ordinary commits to the same repository / 已核对截图回执，请私下保留；同一仓库正常更新不因此要求重复提交。

The team confirmed a classmate trial, a gesture revision, and two tutor showings on 25 November; the Canvas URL is now confirmed submitted from the later receipt. See [feedback and changes](FEEDBACK-AND-CHANGES.md) for the reported facts and remaining detail.

11 月 25 日已确认同学试玩、手势改进和两次 tutor 展示；后续回执已确认 Canvas 提交。转述事实与待核细节见[反馈与调整](FEEDBACK-AND-CHANGES.md)。

## Follow-up verification / 后续补齐

On 25 November, I cloned public main into a new temporary directory without this worktree's Godot cache or camera environment. Godot 4.7.2 imported it successfully and all eight game suites passed. This is a clean-source test on the same Mac, not a second device, human session or Windows result. The packaging helper also actually exported a project pack, started it headlessly and checked the ZIP. Its logs are included in the local candidate; no new gameplay was introduced.

11 月 25 日，我将公开主线克隆到新临时目录，不使用当前工作区的 Godot 缓存或相机环境。Godot 4.7.2 导入成功，八组游戏检查通过。这是同一台 Mac 的干净源码验证，不是换机、真人或 Windows 结果。打包工具也已实际导出资源包、无窗口启动并检查 ZIP，候选包附有日志；没有新增玩法。
