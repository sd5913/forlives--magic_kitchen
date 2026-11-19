# Roast Duck Kitchen / 烤鸭小店

Roast Duck Kitchen is a 2D time-management game about running a roast duck shop, inspired by Papa's Burgeria.

《烤鸭小店》是一款经营烤鸭店的 2D 限时游戏，灵感来自《老爹汉堡店》。

## How to Play / 一轮怎么玩

1. **Take an order.** Check what the customer ordered.
2. **Roast the duck.** Use hand gestures to control roasting.
3. **Finish the dish.** Prepare the order at the workbench.
4. **Serve and get rated.** Deliver the dish and see your score.

1. **接单。** 查看顾客的订单。
2. **烤鸭。** 用手势操控烤制。
3. **工作台。** 按订单完成餐点。
4. **送餐与评分。** 送出餐点并查看评分。

## Workbench Preview / 工作台预览

The kitchen preview follows one order across four screens. At the order counter, check what the customer asked for. Then move to the roasting station and use hand gestures to control the roast. Once the duck is ready, take it to the workbench and finish the dish according to the order. On the last screen, serve the dish and see the score for that order.

厨房预览用一张订单串起四个场景。先在接单区看清顾客的要求，再到烤制区用手势操控烤鸭。烤鸭出炉后，转到工作台，按订单要求完成餐点。最后进入送餐与评分场景，把餐点交给顾客，查看这一单的得分。



## Run the preview / 运行预览

Install **Godot 4.7.2 Standard**, then clone or download the [repository](https://github.com/sd5913/forlives--magic_kitchen). In Godot’s Project Manager, choose **Import**, open [`game/project.godot`](game/project.godot) and click **Run Project**. [Download Godot](https://godotengine.org/download/archive/4.7.2-stable/)

安装 **Godot 4.7.2 Standard**，然后克隆或下载[项目仓库](https://github.com/sd5913/forlives--magic_kitchen)。在 Godot 项目管理器中选择 **导入**，打开 [`game/project.godot`](game/project.godot)，再点击 **运行项目**。[下载 Godot](https://godotengine.org/download/archive/4.7.2-stable/)

We build the game in GDScript for Windows and macOS. We’ve verified the preview on macOS. Windows testing is pending. The preview needs a keyboard or mouse and runs without a camera or API key.

我们用 GDScript 开发，目标平台为 Windows 和 macOS。预览已在 macOS 上验证，Windows 版待测。用键盘或鼠标就能运行预览，无需摄像头或 API 密钥。

## UI design / 界面设计

Our [shared Figma file](https://www.figma.com/design/OUk4C7fCqrzPmnOuzZpYGZ?node-id=0-1) contains the low-fidelity flow, the approved visual reference and the [UI Kit](https://www.figma.com/design/OUk4C7fCqrzPmnOuzZpYGZ?node-id=148-1119). The kit brings together shared navigation, controls, order-ticket frames, decorative borders, materials and icons. Station content is kept separate from reusable interface elements. See the [UI design handoff](docs/design/UI-KIT.md) for component coverage and implementation status.

我们的[共享 Figma 文件](https://www.figma.com/design/OUk4C7fCqrzPmnOuzZpYGZ?node-id=0-1)集中保存低保真流程、已选定的视觉基准和[公共 UI Kit](https://www.figma.com/design/OUk4C7fCqrzPmnOuzZpYGZ?node-id=148-1119)。组件库包含共用导航、控件、订单票框、装饰边框、材质和图标，具体工作台的内容与公共界面分开。组件范围和接入状态见[界面设计交接](docs/design/UI-KIT.md)。

## Development standards / 开发规范

The Godot project lives in `game/`. The workbench assembles four separate scenes in `game/scenes/`, and Python development tools live at the repository root. We use `snake_case` for game files and `PascalCase` for Godot nodes. The engineering guide covers asset placement, scene ownership, Git and verification. [Engineering standards](docs/technical/ENGINEERING-STANDARDS.md) · [Technical overview](docs/technical/README.md)

Godot 工程放在 `game/`，工作台由 `game/scenes/` 中的四个子场景组成，Python 开发工具放在仓库根目录的独立目录中。游戏文件用 `snake_case`，Godot 节点用 `PascalCase`。素材归档、场景分工、Git 和验证流程见[工程规范](docs/technical/ENGINEERING-STANDARDS.md)与[技术总览](docs/technical/README.md)。

## Project notes / 项目资料

[Project board](https://github.com/orgs/sd5913/projects/23) · [Development progress](docs/WEEKLY-PROGRESS.md) · [Credits and AI assistance](CREDITS.md)

[项目看板](https://github.com/orgs/sd5913/projects/23) · [开发进度](docs/WEEKLY-PROGRESS.md) · [致谢与 AI 辅助说明](CREDITS.md)
