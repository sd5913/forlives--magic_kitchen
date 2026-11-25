# Credits / 致谢

## Tools and AI assistance / 工具与 AI 辅助

We’re building the game with [Godot](https://godotengine.org/) and GDScript. The input simulation and repository checks use Python’s standard library.

我们使用 [Godot](https://godotengine.org/) 和 GDScript 制作游戏，输入模拟与仓库检查使用 Python 标准库。

OpenAI Codex helped us draft and translate documentation, compare interaction references, write repository checks and work on the Python input router, simulation and tests. It also helped build the initial Godot workbench and input feedback. Documentation has also been edited with [Stop Slop](https://github.com/hardikpandya/stop-slop).

Codex also helped build the standalone cooking-station prototype, including placeholder food drawings and interaction logic, using the team's exported UI frames.

The cooking-station redesign uses the reference image embedded in the committed Figma backup (`images/049ea5164cd047abb08c95ffe9a2a5bf5b86517f`) alongside the exported shared UI frames. Codex helped assemble the scene and its interactive overlays. The team confirmed on 25 November that the selected shared reference was co-created with generative AI; the original generator/model was not recorded.

The 1440 × 900 cooking scene uses an AI-generated background made with OpenAI image generation using that reference, plus rectangular food and gesture crops from the reference. Codex assembled the editable Godot controls. The selected reference is the team's AIGC-assisted source described below.

OpenAI Codex 参与了文档起草与翻译、交互参考比较、仓库检查，以及 Python 输入路由、模拟和测试的编写，也协助制作了 Godot 初版工作台与输入反馈。文档曾使用 [Stop Slop](https://github.com/hardikpandya/stop-slop) 辅助编辑。

For the shared Figma kit, we used Codex to organise reusable controls, separate them from station content, extract decorative frame parts and check layout and resizing. This component pass reused the selected image; it did not generate new illustrations. The current workbench preview runs locally without a generative AI service.

整理公共 Figma 组件时，我们用 Codex 归纳共用控件、区分工作区内容、拆分装饰边框，并检查布局与拉伸效果。本轮组件制作复用了选定原图，没有新生成插画。当前工作台预览在本地运行，无需调用生成式 AI 服务。

On 21 November, we used Figma AI to generate the order-counter environment and customer illustration. Codex assisted with assembling the high-fidelity order page from the shared components, drawing the additional vector icons, configuring prototype links, and exporting and checking the design files. The reference-derived kit and the newly generated illustration are recorded separately in the design archive.

11 月 21 日，我们使用 Figma AI 生成点单柜台环境与顾客插画。Codex 协助使用公共组件组合点单区高保真、绘制新增矢量图标、配置原型连线，以及导出和检查设计文件。参考图拆出的公共组件与本次新生成插画在设计归档中分别记录。

The food-icon and numbered-gesture pass also used Figma AI. It produced two source atlases, from which we made separate raster components and transparent PNGs. Codex assisted with the asset organisation, reusable hint-card properties, recipe-row icon mapping and export checks. The hawthorn correction follows the team’s clarification: the fourth ingredient is red hawthorn strips.

食物图标和数字手势这一轮也使用了 Figma AI，生成两张源图集，再整理成独立位图组件与透明 PNG。Codex 协助素材整理、提示卡替换属性、配料行图标对应和导出检查。山楂条修正依据组内澄清：第 4 项食材为红色山楂条。

The current food and hand artwork is a Figma AI-assisted redraw in a simplified pixel game style, revised after feedback on the earlier realistic rendering. The source atlases, individual PNGs and Figma instances were updated together.

当前食物与手势使用 Figma AI 辅助重绘为简化像素游戏风格，依据对上一版偏写实效果的反馈调整。源图集、独立 PNG 和 Figma 实例已同步更新。

## Art and design sources / 美术与设计来源

The [design page](docs/design/README.md) links our Figma work and exported files. The [manifest](docs/design/exports/manifest.json) records the source node for each export. The selected wood-and-parchment reference was co-created by the team with generative AI, confirmed on 25 November. We reused it to build shared frames and scene textures; this origin is a team declaration, not a newly identified external stock-image license. The exact original generator/model is not recorded.

[设计页面](docs/design/README.md)保存 Figma 与导出文件入口，[清单](docs/design/exports/manifest.json)记录每份导出的来源节点。木框与羊皮纸公共参考图由我们与 AIGC 协作生成，11 月 25 日已确认；随后用于拆分公共边框与场景纹理。这里按组内确认记录来源，不再将它写成来源未明的外部图库图片；最初使用的生成工具／模型尚未记录。

## References / 参考

The [interaction notes](docs/INTERACTION-REFERENCES.md) list the projects we consulted while exploring gesture controls. We did not copy their code or media.

探索手势操作时查阅的项目记录在[交互参考](docs/INTERACTION-REFERENCES.md)中，没有复制它们的代码或媒体。

For the README’s structure, we looked at [SuperTux](https://github.com/SuperTux/supertux/blob/master/README.md) and [Endless Sky](https://github.com/endless-sky/endless-sky/blob/master/README.md): introduce the game, show it, then explain how to run it and where to find development details.

整理 README 时，我们参考了 [SuperTux](https://github.com/SuperTux/supertux/blob/master/README.md) 和 [Endless Sky](https://github.com/endless-sky/endless-sky/blob/master/README.md) 的信息顺序：先介绍游戏和展示画面，再说明运行方法与开发资料入口。

Our [project board](https://github.com/orgs/sd5913/projects/23) was set up by MiaJiao5 using the course’s [Group Project 2026 template](https://github.com/orgs/sd5913/projects/1).

[项目看板](https://github.com/orgs/sd5913/projects/23)由 MiaJiao5 使用课程的 [Group Project 2026 模板](https://github.com/orgs/sd5913/projects/1)建立。

## Order station implementation / 点单实现

The order station uses four AI-generated image assets and a shared-clock prototype built with Codex assistance. See [runtime asset notes](docs/technical/ORDER-ASSETS.md). System fonts are referenced locally, not redistributed. The original workbench, manager, tests and shared-order flow remain in the source history.

点单台使用四份 AI 生成图像，公共计时与订单流程由 Codex 辅助实现，详见[运行素材说明](docs/technical/ORDER-ASSETS.md)。系统字体不随工程分发；原工作台、管理器与测试的历史保留。


## Shared shift integration / 统一营业整合

We used Codex to implement the team-supplied six-part flow, reconcile branches, connect shared state and input, add scoring and automated regression checks, and update setup and handoff notes. Existing cooking textures and the archived food/hand PNGs were reused; this integration did not generate new art. The shared camera bridge reuses the cooking contributor's landmark-count function with a separate raw-count transport.

我们使用 Codex 实现组内六部分流程、处理分支冲突、连接共享状态与输入、增加评分和回归检查，并整理环境及对接说明。本轮复用料理纹理和已归档食物手势 PNG，没有生成新美术。统一摄像头桥接复用料理模块的手指计数函数，另行传输原始数字。

## Approved order counter / 定稿点单界面

Codex assisted with porting our approved Figma counter (`217:1122`) and its detail, all-orders and pause states into editable Godot controls. The existing customer illustration, shared texture atlas, food atlas and SVG icons were reused; this pass generated no new artwork. Layout regions and asset paths are recorded in `game/data/approved_order_layout.json` and the [integration notes](docs/technical/ORDER-UI-INTEGRATION.md).

Codex 协助将已定稿的 Figma 点单台（`217:1122`）及详情、全部订单和暂停状态接入可编辑的 Godot 控件。本轮复用已有顾客插画、公共纹理图集、食物图集与 SVG 图标，没有新生成美术。布局区域与素材路径记录在 `game/data/approved_order_layout.json` 和[接入说明](docs/technical/ORDER-UI-INTEGRATION.md)中。

Bree Serif Regular is distributed under the SIL Open Font License 1.1. The font and its original copyright and license notice are included in `game/assets/fonts/`. Source: [Google Fonts / Bree Serif](https://github.com/google/fonts/tree/main/ofl/breeserif).

Bree Serif Regular 按 SIL Open Font License 1.1 分发，字体及原版权和许可声明保存在 `game/assets/fonts/`。来源：[Google Fonts / Bree Serif](https://github.com/google/fonts/tree/main/ofl/breeserif)。

Codex also assisted with the review-pack export/check utility, clean-source reproduction and submission-status documentation. These checks are recorded separately from the team's classmate trials and tutor feedback.

Codex 也协助编写候选包导出检查工具、验证干净源码复现，并整理提交状态；这些检查与同学试玩和 tutor 反馈分开记录。

## Team cooking handoff / 组内料理交付

The integrated preparation view reuses the team-supplied cooking asset review package received on 25 November, including 48 PNGs, layout, layered food and editable Godot source. The exact ZIP and cooking PDF/serving DOCX are retained in the [handoff archive](docs/design/COOKING-HANDOFF-1125.md). Codex assisted with normalized runtime paths, the shared-session adapter, layout clearance and regression checks; no new artwork was generated in this pass. The serving design's existing attribution is preserved in its integration notes.

本轮料理界面复用 11 月 25 日收到的组内素材审查包，包括 48 张 PNG、布局、食物叠层和可编辑 Godot 源文件；ZIP、料理 PDF 和交付 Word 原件保存在[交接归档](docs/design/COOKING-HANDOFF-1125.md)。Codex 协助规范运行路径、连接共享状态、处理文字间距和回归检查，没有新增美术；交付设计原有署名保留在其整合说明中。
