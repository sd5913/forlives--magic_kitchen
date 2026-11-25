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

`game/scenes/shift/shift_game.tscn` is the shared playable entry. `shift_session.gd` owns the clock, orders, food and scores. The approved order view uses a 1536 × 1024 design canvas; existing roasting/preparation/rating layouts use 1440 × 900 and are proportionally fitted by the host. Contributor scenes remain available for independent work; changing a branch's standalone entry must not silently replace the shared entry.

当前可玩入口为 `game/scenes/shift/shift_game.tscn`。`shift_session.gd` 管理共享时间、订单、食物和评分。定稿点单使用 1536 × 1024 画布，现有烤炉／料理／评分使用 1440 × 900，由主场景等比适配。组员独立场景继续保留，分支的独立启动页不能直接覆盖共享入口。

When two zones need to communicate, expose a named signal or method and connect it from their parent. For example, an order panel can emit `order_selected(order_id)`. Keep device events inside the input layer and have gameplay code consume named actions. See the [input contract](../INPUT-ARCHITECTURE.md).

两个区域要通信时，提供有名称的信号或方法，由父场景连接。例如，订单面板可以发出 `order_selected(order_id)`。设备事件留在输入层，玩法代码接收已命名的动作。参见[输入协议](../INPUT-ARCHITECTURE.md)。

## Files in Git / 文件提交规则

- Commit scene and script changes together with the `.uid` sidecars and any source assets they reference. For a move or rename, keep the UID with the script, check the references in Godot and commit the changes together.
- 提交场景、脚本时，一并提交 `.uid` 文件和它们引用的素材。移动或重命名脚本时，保留对应 UID，在 Godot 中检查引用，再把相关改动放在同一次提交。
- Keep Godot's `.godot/` cache, local environments, exports and temporary experiments out of commits. Record the source and permitted use of external assets, and document AI assistance in [CREDITS.md](../../CREDITS.md).
- `.godot/` 缓存、本地环境、导出包和临时实验不进提交。外部素材的来源与授权范围，以及 AI 辅助的实际用途，写入[致谢说明](../../CREDITS.md)。

## Integration checks / 集成检查

1. Sync `main` before starting a change. Keep each commit focused and use a message that describes its effect, such as `fix: keep mortar feedback visible after keyboard activation`.
2. Open the changed scene in Godot, then run the shared shift. Check its native design size, 960 × 540, and resizing. For input changes, try mouse and keyboard, including one ordinary invalid or interrupted action when applicable.
3. From the repository root, run the file checker and the input contract tests below. GitHub Actions runs these Python checks on Windows, macOS and Linux. Record Godot editor or gameplay checks separately, with the platform you actually tested.
4. Share the change and verification results with the technical lead for integration. For shared scenes and settings, reconcile overlapping edits before pushing to `main`.

1. 开始前同步 `main`。一次提交解决一个问题，提交信息写出具体效果，例如 `fix: keep mortar feedback visible after keyboard activation`。
2. 在 Godot 中打开改过的场景，再运行统一营业。检查原设计尺寸、960 × 540 和窗口缩放。输入改动要试键盘和鼠标，适用时再试一次误操作或输入中断。
3. 在仓库根目录运行下面两项检查。GitHub Actions 会在 Windows、macOS 和 Linux 上运行这些 Python 检查。Godot 编辑器或玩法检查单独记录，并注明实际验证的平台。
4. 把改动和验证结果交给技术负责人统筹集成。涉及共享场景或设置时，先处理重叠改动，再推送到 `main`。

```sh
python3 tools/check_repository.py
python3 -m unittest discover -s tests -v
```

On Windows, use `py -3` in place of `python3`.

Windows 上可用 `py -3` 替代 `python3`。

## Review packaging / 候选版本打包

```sh
python3 tools/package_review.py --godot /path/to/Godot
```

The ignored `build/review_candidate.zip` contains the project pack, setup instructions, build evidence and font license. Import/export/startup must succeed before a new archive is produced. This validates the current host only. Verify actual interaction and human feedback separately. The pack still requires Godot 4.7.2 Standard; camera launch needs the source checkout/environment. Resolve the recorded reference-art permissions before treating it as a cleared public release.

输出在忽略提交的 `build/review_candidate.zip`，包含资源包、运行方法、构建证据和字体许可。导入、导出、启动成功后才生成新包；只验证当前主机，实际交互及他人反馈另测。资源包仍需 Godot 4.7.2 Standard，摄像头需要源码环境；参考图许可明确前不当作已核清许可的正式发布。
