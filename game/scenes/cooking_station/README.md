# Cooking station prototype / 料理台原型

Open `game/project.godot` in Godot, open `scenes/cooking_station/cooking_station.tscn`, and press **F6** to run this scene independently. F5 still opens the existing shared workbench.

在 Godot 中打开 `game/project.godot`，再打开 `scenes/cooking_station/cooking_station.tscn`，按 **F6** 单独运行料理台。F5 仍运行原有公共工作台。

The sample order needs duck, cucumber, scallion and sweet bean sauce. Click the food cards or press 1–5 to add ingredients, 0 to roll, Backspace to undo, and Enter to submit. R restarts the sample and Escape pauses. Wrong ingredients can be removed in reverse order with Undo; the wrap can be rolled after the ingredients match the order.

示例订单需要鸭肉、黄瓜、葱和甜面酱。点击食材卡或按 1–5 添加食材，0 卷饼，Backspace 撤销，Enter 完成订单，R 重新开始，Esc 暂停。放错食材时可按加入顺序的逆序撤销，配料与订单一致后可以卷饼。

The food drawings are placeholders. The paper frames come from the shared Figma kit in `docs/design/exports/components`; their source and runtime-use permission remain to be confirmed as recorded in `CREDITS.md`. The header tabs are visual placeholders for integration with the shared host.

食材图形为占位插画，纸质边框来自 `docs/design/exports/components` 中的公共 Figma 组件。对应图片的来源与运行时使用许可仍需按 `CREDITS.md` 确认。顶部导航是等待公共主场景接入的视觉占位。

There is **no camera or hand tracking yet**. A future adapter can send `receive_action(action, true)` once on recognition and `receive_action(action, false)` on release using `add_duck`, `add_cucumber`, `add_scallion`, `add_radish`, `add_sauce` or `roll_wrap`. The adapter must handle stable recognition, tracking loss, pause, focus loss and stale callbacks according to `docs/INPUT-ARCHITECTURE.md` before use. `set_order(id, ingredients)` accepts the same ingredient IDs; `order_completed` emits the order ID, selected ingredient IDs and rolled state. The shared host and scoring station still need to agree on their final data contract.

**目前尚未接入摄像头或手势识别。** 后续识别适配层可以在识别时调用 `receive_action(action, true)`、释放时调用 `receive_action(action, false)`；动作名为 `add_duck`、`add_cucumber`、`add_scallion`、`add_radish`、`add_sauce` 和 `roll_wrap`。适配层需要按 `docs/INPUT-ARCHITECTURE.md` 处理稳定识别、丢失跟踪、暂停、失焦和过期回调。`set_order(id, ingredients)` 接收相同食材 ID；`order_completed` 信号传出订单 ID、实际食材和卷饼状态。最终数据格式仍需与公共主场景和评分台负责人共同确定。
