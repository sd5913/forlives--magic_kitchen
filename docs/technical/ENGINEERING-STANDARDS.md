# Engineering standards / 工程规范

Use this guide when adding a scene, script or asset to Magic Kitchen. The current baseline uses Godot 4.7.2 Standard, GDScript and the Compatibility renderer. Import `game/project.godot` to open the project.

新增场景、脚本或素材时，按这份规范放置和命名文件。当前工程使用 Godot 4.7.2 Standard、GDScript 和 Compatibility 渲染器，从 `game/project.godot` 导入。

## Repository layout / 仓库目录

| Path / 路径 | Contents / 用途 |
| --- | --- |
| `game/project.godot` | Shared Godot settings and entry scene / Godot 公共设置和启动场景 |
| `game/scenes/` | Godot scenes and scripts tied to them / Godot 场景及其专用脚本 |
| `interaction/` | Python reference implementation for the input contract / 输入协议的 Python 参考实现 |
| `tests/` | Python input contract tests / Python 输入协议测试 |
| `tools/` | Repository checks and development utilities / 仓库检查与开发工具 |
| `docs/` | Design, setup and engineering notes / 设计、环境和工程文档 |

Add `game/assets/` when the game first needs imported art or audio. Use a subfolder for each type, such as `sprites/`, `ui/` or `audio/`. Keep editable source files outside the Godot project unless the runtime needs them.

首次引入美术或音频时，再创建 `game/assets/`，按 `sprites/`、`ui/` 或 `audio/` 等类型归档。PSD 等编辑源文件放在 Godot 工程外，供运行时加载的导出文件放进工程。

## Naming / 命名

| Item / 对象 | Rule / 规则 | Example / 示例 |
| --- | --- | --- |
| Scene, script, resource and asset files / 场景、脚本、资源和素材文件 | Lowercase `snake_case` / 小写下划线 | `order_panel.tscn`, `mortar.gd`, `mortar_grind.ogg` |
| Godot nodes and GDScript classes / 节点和类 | `PascalCase` | `OrderPanel`, `DeliveryCounter` |
| GDScript variables, methods, signals and input actions / 变量、方法、信号及输入动作 | `snake_case` | `active_order_id`, `deliver_order()`, `order_delivered` |
| Constants / 常量 | `CONSTANT_CASE` | `MAX_ACTIVE_ORDERS` |
| Branches / 分支 | Purpose prefix and lowercase hyphenated topic / 用途前缀加小写短横线主题 | `feature/order-panel`, `fix/mortar-feedback`, `docs/engineering-standards` |

Use descriptive English names for new runtime files and folders, with no spaces. Prefer stable filenames for assets used by scenes. Git tracks revisions to a file. Write text as UTF-8 with LF line endings and indent GDScript with tabs.

运行时文件和目录用能看出用途的英文名称，路径不带空格。场景引用的素材使用稳定文件名，修改历史由 Git 记录。文本使用 UTF-8 和 LF 换行，GDScript 用 Tab 缩进。

## Scene boundaries / 场景职责

`workbench.tscn` lays out the four zones. Each subscene owns the controls inside its zone. Change a zone's position in the main scene and its contents in the subscene. Coordinate changes to shared settings or zone dimensions with the main scene owner. See the [scene ownership table](README.md#workbench-layout-and-ownership).

`workbench.tscn` 负责四个区域的摆放，各子场景负责本区域内的控件。挪位置改主场景，改内容进子场景。调整区域尺寸或公共设置前，与主场景负责人对齐。分工见[场景分工表](README.md#workbench-layout-and-ownership)。

When two zones need to communicate, expose a named signal or method and connect it from their parent. For example, an order panel can emit `order_selected(order_id)`. Keep device events inside the input layer and have gameplay code consume named actions. See the [input contract](../INPUT-ARCHITECTURE.md).

两个区域要通信时，提供有名称的信号或方法，由父场景连接。例如，订单面板可以发出 `order_selected(order_id)`。设备事件留在输入层，玩法代码接收已命名的动作。参见[输入协议](../INPUT-ARCHITECTURE.md)。

## Files in Git / 文件提交规则

- Commit scene and script changes together with the `.uid` sidecars and any source assets they reference. For a move or rename, keep the UID with the script, check the references in Godot and commit the changes together.
- 提交场景、脚本时，一并提交 `.uid` 文件和它们引用的素材。移动或重命名脚本时，保留对应 UID，在 Godot 中检查引用，再把相关改动放在同一次提交。
- Keep Godot's `.godot/` cache, local environments, exports and temporary experiments out of commits. Record the source and permitted use of external assets, and document AI assistance in [CREDITS.md](../../CREDITS.md).
- `.godot/` 缓存、本地环境、导出包和临时实验不进提交。外部素材的来源与授权范围，以及 AI 辅助的实际用途，写入[致谢说明](../../CREDITS.md)。

## Integration checks / 集成检查

1. Sync `main` before starting a change. Keep each commit focused and use a message that describes its effect, such as `fix: keep mortar feedback visible after keyboard activation`.
2. Open the changed scene in Godot, then run the full workbench. Check its placement at 960 × 540 and after resizing. For input changes, try mouse and keyboard, including one ordinary invalid or interrupted action when applicable.
3. From the repository root, run the file checker and the input contract tests below. GitHub Actions runs these Python checks on Windows, macOS and Linux. Record Godot editor or gameplay checks separately, with the platform you actually tested.
4. Share the change and verification results with the technical lead for integration. For shared scenes and settings, reconcile overlapping edits before pushing to `main`.

1. 开始前同步 `main`。一次提交解决一个问题，提交信息写出具体效果，例如 `fix: keep mortar feedback visible after keyboard activation`。
2. 在 Godot 中打开改过的场景，再运行完整工作台。检查 960 × 540 下的布局和缩放效果。输入改动要试键盘和鼠标，适用时再试一次误操作或输入中断。
3. 在仓库根目录运行下面两项检查。GitHub Actions 会在 Windows、macOS 和 Linux 上运行这些 Python 检查。Godot 编辑器或玩法检查单独记录，并注明实际验证的平台。
4. 把改动和验证结果交给技术负责人统筹集成。涉及共享场景或设置时，先处理重叠改动，再推送到 `main`。

```sh
python3 tools/check_repository.py
python3 -m unittest discover -s tests -v
```

On Windows, use `py -3` in place of `python3`.

Windows 上可用 `py -3` 替代 `python3`。
