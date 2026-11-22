# Cooking Station / 料理台

## 当前版本

按 F5 运行 `res://scenes/cooking_station/cooking_station_layered.tscn`。画布为 1440 x 900：顶部 100 px、游戏区 560 px、手势区 240 px。不要运行旧的 `cooking_station.tscn` 或 `workbench.tscn`。

食材、Roll、Undo、Complete 和底部三张手势卡都可以点击。Complete 只有在订单所需食材全部加入并成功卷饼后才会启用。键盘 1-5 添加食材，0 卷饼，Backspace 撤销，Enter 完成，Esc 暂停，R 重置。

摄像头手势已接入。首次使用先在仓库根目录运行 `powershell -ExecutionPolicy Bypass -File tools/setup-gesture.ps1`，之后在游戏状态栏点击 **Start Camera**。1-5 指分别对应鸭肉、黄瓜、葱、萝卜、甜面酱，握拳对应卷饼。动作需稳定保持约 8 帧；做下一次动作前先改变手势或把手移出画面。

共享导航框、订单框和羊皮纸面板来自 `docs/design/exports/components`。当前仓库的 Figma 备份不含最新节点 `257:2724`，连接 Figma 插件后需要再进行最终视觉核对。

Open `game/project.godot` in Godot and press **F5** to run the cooking station on this branch. To edit it, open `scenes/cooking_station/cooking_station_layered.tscn`. The original `scenes/workbench.tscn` remains in the project for later team integration. The older `cooking_station.tscn` can still be open in an editor; use the layered scene for the new design.

在 Godot 中打开 `game/project.godot`，按 **F5** 即可运行本分支的料理台。需要编辑时，打开 `scenes/cooking_station/cooking_station_layered.tscn`。原来的 `scenes/workbench.tscn` 仍保留在项目中，供之后团队集成使用。旧版 `cooking_station.tscn` 可能仍在编辑器中打开；新版请使用带 `layered` 的场景。

The sample order needs duck, cucumber, scallion and sweet bean sauce. Click the food cards or press 1–5 to add ingredients, 0 to roll, Backspace to undo, and Enter to submit. R restarts the sample and Escape pauses. Wrong ingredients can be removed in reverse order with Undo; the wrap can be rolled after the ingredients match the order.

示例订单需要鸭肉、黄瓜、葱和甜面酱。点击食材卡或按 1–5 添加食材，0 卷饼，Backspace 撤销，Enter 完成订单，R 重新开始，Esc 暂停。放错食材时可按加入顺序的逆序撤销，配料与订单一致后可以卷饼。

The scene is built at 1440 × 900, with editable `Canvas/Top`, `Canvas/Game` and `Canvas/Gestures` nodes. The navigation, ingredients, plate, order text, status and three 432 × 160 gesture cards are separate Godot controls; the ingredient artwork uses rectangular crops from the selected reference image. The kitchen background was generated using that reference. The shared navigation, ticket and parchment frames come from `docs/design/exports/components`. The reference image's creator and runtime-use permission remain to be confirmed as recorded in `CREDITS.md`. The other station tabs emit `navigation_requested`; the team host still needs to connect that signal. Empty queue slots await the shared order system.

场景按 1440 × 900 制作，`Canvas/Top`、`Canvas/Game` 和 `Canvas/Gestures` 都可以在 Godot 中展开编辑。导航、食材、盘子、订单文字、状态和三张 432 × 160 手势卡是独立控件；食材图片是参考图的矩形裁切。厨房背景根据该参考图生成。导航、订单框和羊皮纸面板来自 `docs/design/exports/components` 中的公共组件。参考图的来源及运行时使用许可仍需按 `CREDITS.md` 确认。其他工作台按钮会发出 `navigation_requested` 信号，等待公共主场景连接；空订单槽也等待公共订单系统。

This branch uses a 1440 × 900 viewport and initial window size, matching the 16:10 cooking canvas. Resizing preserves the aspect ratio. In Godot's embedded Game window, open the top-right menu and select **Keep Aspect Ratio** to enlarge the game with the preview window. **Fixed Size** keeps the game small on a large monitor. The speed multiplier at the top left changes game speed, not display zoom.

本分支的运行视口和初始窗口均为 1440 × 900，与 16:10 料理台画布一致；调整窗口时保持比例。在 Godot 内嵌预览窗口右上角菜单选择 **Keep Aspect Ratio（保持宽高比）**，画面会随预览窗口放大。**Fixed Size（固定尺寸）** 在大屏上仍会显得小。左上角的倍率调整游戏速度，不是画面缩放。

Camera tracking is implemented by `tools/gesture_camera.py`. It sends debounced local UDP actions to `gesture_adapter.gd`; video frames stay in the camera process. `set_order(id, ingredients)` accepts the ingredient IDs, and `order_completed` emits the order ID, selected ingredients and rolled state.

摄像头识别由 `tools/gesture_camera.py` 完成，经过防抖后仅把动作通过本机 UDP 传给 `gesture_adapter.gd`，视频帧不会发送给 Godot。主场景可以调用 `set_order(id, ingredients)`，并监听 `order_completed` 和 `navigation_requested` 信号。
