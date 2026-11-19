# Shared UI Kit / 公共界面组件

Updated 19 November 2026, Hong Kong time. I maintain this handoff as JIN Minyi (`IceyHikari`). It records the current design delivery and its path into Godot.

更新于 2026 年 11 月 19 日，香港时间。我以 JIN Minyi（`IceyHikari`）的身份维护这份交接，记录当前设计成果及后续 Godot 接入方式。

## Design sources / 设计入口

| Source / 来源 | Purpose / 用途 |
| --- | --- |
| [Shared design file / 共享设计文件](https://www.figma.com/design/OUk4C7fCqrzPmnOuzZpYGZ?node-id=0-1) | Low-fidelity flow and team designs / 低保真流程与小组设计 |
| [Approved reference / 选定原图](https://www.figma.com/design/OUk4C7fCqrzPmnOuzZpYGZ?node-id=131-1686) | 1536 × 1024 cooking-station visual reference / 1536 × 1024 料理台视觉基准 |
| [UI Kit page / 组件页](https://www.figma.com/design/OUk4C7fCqrzPmnOuzZpYGZ?node-id=148-1119) | Reference copy, main components and instances / 原图对照、主组件与实例 |
| [Shared controls / 公共控件](https://www.figma.com/design/OUk4C7fCqrzPmnOuzZpYGZ?node-id=159-1459) | Header states, buttons and order-ticket shells / 顶栏状态、按钮和订单票框 |
| [Frames and decoration / 边框与装饰](https://www.figma.com/design/OUk4C7fCqrzPmnOuzZpYGZ?node-id=178-2243) | Resizable frames, ornaments, materials and icon specimens / 可拉伸边框、装饰、材质与图标规格 |

I confirmed the low-fidelity flow as completed for this progress update. The other teammates' low-fidelity screens were not individually re-audited during the component work. I selected the reference above as the common visual basis; earlier low-poly explorations remain historical material.

本次进度同步中，我确认低保真流程已完成；组件整理期间没有逐张重新审查其他组员的低保真页面。我已选定上面的原图作为统一视觉依据，早期 low-poly 探索保留为历史材料。

## Delivered components / 已完成组件

| Family / 类别 | Coverage / 范围 |
| --- | --- |
| Header and station tabs / 顶栏与工作台导航 | Order, Roasting and Cooking selected states; consistent position, size and pause control / 点单、烤制、料理三种选中状态，位置、尺寸和暂停入口一致 |
| Controls / 控件 | Action buttons with default, hover, pressed and disabled states; icon buttons; checkbox states / 操作按钮的默认、悬停、按下、不可用状态，图标按钮与勾选框状态 |
| Orders / 订单 | Main and mini ticket shells with editable order numbers and empty content areas / 大小订单票框、可编辑订单编号和留空内容区 |
| Frames / 边框 | Wood-and-paper and vermilion plaques, parchment panels, inset frames and scalloped paper; separate corners and edges / 木框纸面、朱红木牌、羊皮纸面板、内嵌框、锯齿纸及独立角饰、边条 |
| Decorations / 装饰 | Hanging rope and anchors, reusable clips, wood rail, paper divider, numbered medallions and small label plaques / 挂单绳及固定端、共用夹子、木质横条、纸面分隔线、圆形编号和小铭牌 |
| Materials / 材质 | Parchment, dark wood, vermilion and brass samples from the approved reference / 从定稿提取的羊皮纸、深木、朱红和黄铜局部材质 |
| Icons / 图标 | Pause, Close, Expand, Collapse and Check, shown at 28 and 32 px; icon-button hit area 64 × 64 / 暂停、关闭、展开、收起和确认，展示 28、32 px 规格，图标按钮点击区 64 × 64 |
| Foundations / 基础样式 | Shared colour and spacing variables, typography styles and component properties / 共用颜色、间距变量、文字样式与组件属性 |

These are reusable Figma components with instances in the specimen boards. Decorative textures are raster crops from the reference; editable text and vector icons remain separate. This is not a fully vectorised version of the original illustration.

展示区使用可复用的 Figma 组件实例。装饰纹理取自原图局部位图，文字和矢量图标保持独立可编辑；原图插画本身并未全部转为矢量。

Food, customers, recipes, station artwork and specific gesture instructions are outside the shared kit. The approved reference still contains those items as context. They have not been added back as reusable kit content.

食材、顾客、配方、工作台场景和具体手势步骤不属于公共组件。对照原图仍包含这些内容，但它们没有重新进入公共组件库。

## Shared layout rules / 共用布局规则

- Use the approved 1536 × 1024 design canvas. Shared header geometry is identical across the three station states.
- 设计画布采用定稿的 1536 × 1024，三种工作台状态使用相同的顶栏几何布局。
- Keep station navigation available independently of accepting an order. Carry the same order identity and state between stations.
- 工作台导航不以接单作为解锁条件；切换时保留同一订单身份和状态。
- Use instances and editable properties for state, label, number and icon changes. Put station-specific content into the empty content areas.
- 状态、文字、编号和图标通过实例属性修改，具体工作台内容放入留空内容区。
- Preserve frame corners when resizing; stretch straight edges and the interior. Do not scale the entire frame as one image.
- 调整边框大小时保留四角，只拉伸直边和内部，避免把整框当作一张图等比例放大。

## Verification / 已做检查

During the Figma work, I checked the rendered specimens and corrected source-text remnants, seal wrapping and alignment. Structural inspection confirmed component instances and identical header positions across stations. A parchment panel resized from 484 × 213 to 720 × 280 retained four 24 × 24 corners. The kit contains no food or station-specific gesture components.

Figma 整理中，我检查了渲染展示，修正取材中的文字残影、印章换行与错位。结构检查确认展示使用组件实例，三站顶栏位置一致；纸面板从 484 × 213 放大到 720 × 280 时，四角仍为 24 × 24。组件库中没有食材或单站手势组件。

These are design and structure checks, not a human playtest or verification of the final visuals in Godot.

以上是设计与结构检查，不是玩家试玩，也不代表最终视觉已在 Godot 中验证。

## Godot handoff / Godot 接入

| Stage / 阶段 | Status on 19 November / 11 月 19 日状态 |
| --- | --- |
| Low-fidelity flow / 低保真流程 | Completed, confirmed by me / 已完成，由我确认 |
| Approved reference and shared UI Kit / 定稿与公共组件 | Prepared in the shared Figma file / 已整理在共享 Figma 文件 |
| Runtime asset export and source credits / 运行时素材导出与来源记录 | Pending; source-image authorship and export permission must be recorded before runtime publication / 待完成，运行时发布前补齐原图作者与导出授权记录 |
| Godot reusable controls and theme / Godot 公共控件与主题 | Final-kit integration pending / 最终组件库接入待完成 |
| Full-game visual consistency / 游戏内视觉一致性 | Pending integration and rendered checks / 待接入与实际渲染检查 |
| Human trial and tutor feedback / 真人试玩与 tutor 反馈 | No new evidence in this design update / 本次设计同步没有新增记录 |

I will integrate the shared header, controls and empty panel shells first, then connect their properties to the existing game state. Export runtime assets under `game/assets/ui/` with descriptive `snake_case` names, preserve editable sources in Figma and record provenance in [credits](../../CREDITS.md). For frame artwork, Godot `StyleBoxTexture` or `NinePatchRect` should preserve the same border margins.

后续我先接入公共顶栏、控件和空面板，再把实例属性连接到现有游戏状态。运行时导出素材放入 `game/assets/ui/`，使用描述性 `snake_case` 文件名；可编辑源保留在 Figma，来源写入[致谢说明](../../CREDITS.md)。边框使用 Godot `StyleBoxTexture` 或 `NinePatchRect` 时，应保留相同的边距。

The Figma canvas does not automatically change the Godot viewport. The current main-branch scaffold uses 960 × 540; the order-station branch documents an older 1440 × 900 virtual layout. I need to reconcile aspect ratio, scaling and safe areas in the shared host before replacing that layout. Do not edit teammates' scene sizes independently.

Figma 画布不会自动改变 Godot 视口。当前主分支基础工程使用 960 × 540，点单分支记录的是较早的 1440 × 900 虚拟布局。我需要在公共主场景中统一宽高比、缩放和安全区域，再替换旧布局，不分别修改组员场景尺寸。

Use [project status](../PROJECT-STATUS.md) for branch integration and [weekly progress](../WEEKLY-PROGRESS.md) for dated evidence. Keep using [board #23](https://github.com/orgs/sd5913/projects/23); this document does not close implementation or playtest tasks.

分支整合见[项目状态](../PROJECT-STATUS.md)，带日期的证据见[周进度](../WEEKLY-PROGRESS.md)。继续使用[看板 #23](https://github.com/orgs/sd5913/projects/23)；本文件不将实现或试玩任务标记为完成。
