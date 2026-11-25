# Integration handoff / 整合对接

26 November update: the [latest supplied cooking scene](../design/COOKING-HANDOFF-1125.md) is now connected to the shared session with actual tickets, food layers and scoring. The original source files remain archived. Its new 2 hawthorn / 4 cucumber mapping agrees with main; exact-recipe gating, post-roll undo and one-order demo scope remain planning differences.

11 月 26 日更新：[最新料理交付场景](../design/COOKING-HANDOFF-1125.md)已连接共享订单、食物叠层与真实评分，原件留档；新包 2 山楂／4 黄瓜与主线一致。配齐才能卷制、卷后撤销及单单 Demo 范围仍属策划差异。


## Resolved in code / 已直接处理

- Preserved the latest main design archive and the order/playable-shift implementation history; retained the cooking, serving and roasting-design branch contributions.
- Unified the default scene at `game/scenes/shift/shift_game.tscn`, with one clock, order identity, navigation and lifecycle. Original contributor scenes remain independently editable.
- Fixed the invalid text in the old cooking scene by forwarding it to the layered scene. Updated the small-window order test to set its logical viewport explicitly.
- Connected dual ovens, explicit take-out/slicing, per-order preparation, imperfect-recipe scoring, duplicate guards, expiry, five-guest summary and restart.
- Used the newest flow mapping: **2 hawthorn, 4 cucumber**. The older Figma annotation and standalone cooking input still document earlier mappings; those previews are not the integrated control specification.
- Added a cross-platform camera launcher path and current-station count routing without replacing the contributor's standalone bridge.

- 保留最新主线设计归档和点单、旧试玩历史；纳入料理、交付场景及烘烤策划分支。
- 统一启动到 `game/scenes/shift/shift_game.tscn`，共享时间、订单、导航和生命周期，原独立场景继续保留。
- 修复旧料理场景中的无效文本，以新版分层场景作为兼容入口；小窗口点单测试明确设置逻辑视口。
- 接通双炉位、取出与片鸭、分单制作、错误配方计分、防重复、过期、五单汇总和重开。
- 以新稿 **2 山楂、4 黄瓜** 为准；旧 Figma 标注和独立料理预览仍是早期映射，不能作为整合版控制规范。
- 增加跨平台摄像头启动路径和按工作区解释数字输入的桥接，保留组员旧桥接。

## Planning and roasting / 策划与烘烤对接

Confirm the trial values in `game/data/shift_rules.json`: arrival/capacity/patience, two oven slots, heat thresholds, rating pause/weights, five-order goal, gesture timing and correction rules. Confirm that each ingredient has one portion and whether melon/sugar recipes remain outside this delivery. The implementation already has usable defaults; change the config and matching test expectations together after agreement.

确认配置中的试运行值：到达、容量、耐心、双炉位、火候、评分暂停与权重、五单目标、手势触发和纠错规则。确认每种食材一份，以及本次是否排除哈密瓜和白糖配方。实现已提供默认值；定稿后同步修改配置和对应测试。

Supply separated oven, whole-duck, fire/heat and slicing artwork/animation. The shared host currently gives operational oven slots, timers, heat-color bars and slicing state; these are not a claim that final roasting art is finished.

交付炉体、整鸭、火焰、火候及片鸭的分层素材和动画。整合版当前提供可操作炉位、计时、火候色条和片鸭状态，尚不代表最终烘烤美术完成。

## Cooking and common UI / 料理与公共组件对接

Review the shared shell against the final cooking page. Its textures and food/hand assets are reused; the layered cooking scene is preserved as the editable reference rather than overwritten. Confirm which final layout elements should replace the integrated preparation area's temporary arrangement. Update the standalone preview's old radish label and numeric hints when its owner resumes work, so its instructions match the new flow.

核对共享界面与最终料理稿。整合复用了纹理和食物手势素材，保留分层料理场景作为可编辑参考。确认哪些最终排版元素需要替换整合料理区当前布局；独立预览由该模块继续维护时，同步修正旧萝卜标签及数字提示，避免和新流程相反。

## Serving and testing / 交付与测试对接

Supply final tasting expressions/animation, score-panel art and serving-page interaction details. The current shared host already scores the actual dish, holds the rating screen and displays the shift result; the serving branch's original header scaffold remains preserved.

交付品尝表情或动画、评分面板素材及交付页交互细节。整合版已按实际餐点评分，控制展示停留并显示营业结果；交付分支原页头场景仍保留。

Run a real camera trial and Windows gameplay check, and organize an uncoached human playtest. Record what actually happened, device/platform, problems and changes; do not convert automated checks into player or teacher feedback. Confirm source-image attribution and runtime-use permission already identified in CREDITS.

安排真人相机与 Windows 实机检查，并组织未解释玩法的其他人试玩。记录真实设备、操作、问题和改进；自动检查不写成玩家或教师反馈。补齐 CREDITS 已列出的参考图来源及运行使用许可。
