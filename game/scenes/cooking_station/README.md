# Cooking station prototype / 料理台原型

Open `game/project.godot` in Godot, open `scenes/cooking_station/cooking_station.tscn`, and press **F6** to run this scene independently. F5 still opens the existing shared workbench.

在 Godot 中打开 `game/project.godot`，再打开 `scenes/cooking_station/cooking_station.tscn`，按 **F6** 单独运行料理台。F5 仍运行原有公共工作台。

The sample order needs duck, cucumber, scallion and sweet bean sauce. Click the food cards or press 1–5 to add ingredients, 0 to roll, Backspace to undo, and Enter to submit. R restarts the sample and Escape pauses. Wrong ingredients can be removed in reverse order with Undo; the wrap can be rolled after the ingredients match the order.

示例订单需要鸭肉、黄瓜、葱和甜面酱。点击食材卡或按 1–5 添加食材，0 卷饼，Backspace 撤销，Enter 完成订单，R 重新开始，Esc 暂停。放错食材时可按加入顺序的逆序撤销，配料与订单一致后可以卷饼。

The background and food use the selected 1536 × 1024 cooking-station reference image from the repository's Figma backup. Ingredient regions are clickable, while the order text, checks, plate feedback, buttons and gesture guide are separate controls. The shared navigation, ticket and parchment frames come from `docs/design/exports/components`. Source and runtime-use permission for the reference remain to be confirmed as recorded in `CREDITS.md`. The header tabs and empty order-queue slots await integration with the shared host.

背景和食材图使用仓库 Figma 备份中选定的 1536 × 1024 料理台参考图。食材区域可以点击；订单文字、勾选框、饼上的反馈、按钮和手势说明是独立控件。顶部导航、订单框和羊皮纸面板来自 `docs/design/exports/components` 中的公共组件。参考图的来源及运行时使用许可仍需按 `CREDITS.md` 确认。顶部导航和空订单槽等待公共主场景接入。

The reference canvas is 3:2; this standalone scene fits it inside the existing 960 × 540 host with side margins. The shared viewport decision is still pending.

参考画布为 3:2，独立场景会在现有 960 × 540 窗口内等比显示，两侧留边；团队尚需决定公共视口比例。

There is **no camera or hand tracking yet**. A future adapter can send `receive_action(action, true)` once on recognition and `receive_action(action, false)` on release using `add_duck`, `add_cucumber`, `add_scallion`, `add_radish`, `add_sauce` or `roll_wrap`. The adapter must handle stable recognition, tracking loss, pause, focus loss and stale callbacks according to `docs/INPUT-ARCHITECTURE.md` before use. `set_order(id, ingredients)` accepts the same ingredient IDs; `order_completed` emits the order ID, selected ingredient IDs and rolled state. The shared host and scoring station still need to agree on their final data contract.

**目前尚未接入摄像头或手势识别。** 后续识别适配层可以在识别时调用 `receive_action(action, true)`、释放时调用 `receive_action(action, false)`；动作名为 `add_duck`、`add_cucumber`、`add_scallion`、`add_radish`、`add_sauce` 和 `roll_wrap`。适配层需要按 `docs/INPUT-ARCHITECTURE.md` 处理稳定识别、丢失跟踪、暂停、失焦和过期回调。`set_order(id, ingredients)` 接收相同食材 ID；`order_completed` 信号传出订单 ID、实际食材和卷饼状态。最终数据格式仍需与公共主场景和评分台负责人共同确定。
