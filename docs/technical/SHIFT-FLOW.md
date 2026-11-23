# Shared shift flow / 统一营业流程

We now play one shift across ordering, roasting, preparation and serving. The [six-part team flow](../design/sources/interaction_flow_six_parts.pdf), supplied on 23 November, is the implementation reference. The original order and cooking scenes remain available for independent editing; `shift_game.tscn` is the integrated entry.

我们把点单、烤制、料理和交付接到同一轮营业中。实现依据是 11 月 23 日收到的[六部分流程图](../design/sources/interaction_flow_six_parts.pdf)。原点单和料理场景保留，可单独编辑；整合入口为 `shift_game.tscn`。

## Play / 操作

1. Read the ticket and click **Accept order**. Select **Roast**.
2. In Roast, use **1** to place the duck, **2** to take it out, then **3** to slice it. Slicing takes one second. Two ducks can roast at once; switching tickets does not stop them.
3. Select **Prepare**. Use **1 duck, 2 hawthorn strips, 3 scallion, 4 cucumber, 5 sweet bean sauce**. Click an added side ingredient on the ticket to remove it before rolling. Only the recipe's required ingredients are needed.
4. Use **Space** or the fist card to roll. After one second, click **Complete order**. A wrap with duck can be served even with incorrect sides; the preparation score records those mistakes.
5. Read the three scores. **Return to work** unlocks after three seconds. Five served or expired tickets end the shift.

1. 看清小票，点击 **确认接单**，切换到 **烤炉台**。
2. 烤炉台按 **1 放入、2 取出、3 片鸭**。片鸭需要一秒。两个炉位可同时烤制，切换订单不会停表。
3. 进入 **料理台**，按 **1 鸭肉、2 山楂条、3 葱丝、4 黄瓜丝、5 甜面酱**。卷制前，点击小票上已加入的配菜可移除。只加配方要求的内容。
4. 按 **空格** 或点击握拳卡卷制，一秒后点击 **完成订单**。有鸭肉但漏加或多加配菜的卷仍可交付，错误会反映在料理分中。
5. 查看三站评分，三秒后可返回。交付或过期共五单后进入营业汇总。

Action cards and ingredient cards execute the same gameplay commands as keyboard input. **Esc** pauses; focus loss pauses until an explicit resume. Details and the order list keep the clock running. A new guest never steals the selected ticket.

动作卡、食材卡和键盘共用玩法入口。**Esc** 暂停；窗口失焦后需手动继续。查看详情和全部订单不停表。新顾客到达不会抢走正在查看的订单。

## Rules and state / 规则与状态

`game/data/shift_rules.json` contains the trial values marked † in the supplied flow. They are adjustable implementation defaults, not a claim that the group has approved the final balance.

`game/data/shift_rules.json` 集中保存流程中带 † 的试运行数值，作为可调整的实现默认值；不代表组内已经确认最终平衡。

| Rule / 规则 | Current default / 当前默认值 |
| --- | --- |
| Arrivals / 到达 | First guest at start, then every 20 gameplay seconds; delay while four tickets are active / 开始时首位顾客到店，之后每 20 秒；四单已满时延后 |
| Patience / 耐心 | 120 seconds from arrival; accepting does not reset it / 到店起 120 秒，接单不重置 |
| Roast / 火候 | Raw <12s; cooked 12–<18s; burnt ≥18s / 未熟、适熟、烤焦三段 |
| Ratings / 评分 | Wait = remaining patience ÷120×100; roast = 40/100/0; preparation = five ingredient-presence comparisons ×20 / 点单按剩余耐心，烘烤 40/100/0，五种食材逐项比较，每项 20 分 |
| Total / 总分 | Round the three-score average / 三站平均，四舍五入 |
| Goal / 目标 | At least 3 served; served-order average ≥70 / 至少交付 3 单，已交付平均分 ≥70 |
| Gesture / 手势 | Stable 0.5s, then neutral for 0.25s before the next action / 稳定 0.5 秒触发，释放 0.25 秒后才可再次触发 |

`shift_session.gd` owns the clock, arrivals, per-order food and scores. It uses the existing order manager with explicit four-ticket capacity. UI and input adapters submit actions; neither advances a second clock. Rating freezes all other kitchen timers until returning. Expiry frees food and oven slots; restart resets the shift while retaining monotonic order IDs.

`shift_session.gd` 统一管理时间、到达、每单食材与分数，并复用原订单管理器，明确设置四单容量。界面和输入只提交动作，不另开计时。评分期间其他计时暂停；返回后恢复。过期清空对应食物和炉位，重开清空本轮状态，订单编号仍保持不重复。

The original recipe catalog is preserved. The integrated session uses a private copy: sugar/melon recipes are excluded and portions are capped at one to match the new five-input flow. This must be reviewed with the planning owner before final balance is frozen.

原配方文件保留。整合流程使用独立副本：暂不生成白糖和哈密瓜配方，每种食材一份，以符合本次五输入流程；最终配方与份量需策划确认。

## Camera / 摄像头

Use Python 3.10–3.12, preferably 3.12, from the repository root:

在仓库根目录使用 Python 3.10–3.12，推荐 3.12：

```sh
python3.12 tools/setup_shift_camera.py
```

Then click **Camera**. On Windows, `py -3.12 tools/setup_shift_camera.py` creates the equivalent environment. `tools/shift_camera.py` reuses the cooking contributor's landmark-count function, sending only raw counts to loopback UDP 4243. The game maps the same count to the current station's action. The older standalone cooking bridge keeps its original port and behavior.

之后点击 **摄像头**。Windows 可用 `py -3.12 tools/setup_shift_camera.py`。`tools/shift_camera.py` 复用料理模块的手指计数函数，仅把数字发到本机 UDP 4243，由游戏按当前工作区解释动作；旧独立料理桥接保留原端口和行为。

Pause, switching stations/tickets and restart require a neutral release before another camera action. Stale signals are released. Camera setup errors leave keyboard/mouse controls usable. Exported packs currently support keyboard/mouse; camera launch requires the source checkout and its local environment.

暂停、切换工作区或订单、重开后，都要释放手势再触发；信号中断会释放输入。相机环境异常不会阻断键鼠。导出资源包支持键鼠；从游戏启动摄像头需要源码目录和本地环境。

## Checks / 检查

```sh
python3 tools/check_repository.py
python3 -m unittest discover -s tests -v
python3 tools/run_game_checks.py --godot /path/to/Godot
```

Verified on macOS with Godot 4.7.2: all seven game suites passed, including 67 new flow checks and 9 UDP checks; the existing manager (38), order UI (378), legacy shift (27) and cooking checks still pass. Seven integrated screen states were rendered and inspected. The camera environment imported OpenCV 4.11.0 and MediaPipe 0.10.21 and initialized the hand model against a blank frame. A project pack exported and launched successfully.

本轮在 macOS、Godot 4.7.2 下验证：七组游戏检查通过，包括新增流程 67 项、UDP 9 项；原管理器 38 项、点单界面 378 项、旧试玩 27 项和料理检查仍通过。整合界面的七种状态已实际渲染并检查。摄像头环境导入 OpenCV 4.11.0 与 MediaPipe 0.10.21，并完成模型初始化和空白帧处理；资源包已导出并成功启动。

Windows gameplay, real-camera gesture accuracy, an uncoached human playtest and tutor review remain pending. GitHub's three-platform repository checks do not substitute for those tests. The [integration handoff](INTEGRATION-HANDOFF.md) lists the specific decisions and assets still needed.

Windows 实机玩法、真人摄像头识别、未预先解释玩法的试玩和 tutor review 仍待完成。GitHub 三平台仓库检查不替代这些测试。需要补齐的决策与素材见[整合对接清单](INTEGRATION-HANDOFF.md)。
