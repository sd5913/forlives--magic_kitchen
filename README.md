# Magic Kitchen

We're building a short 2D time-management game set in a fantasy herbal shop. You play an apprentice who picks ingredients, prepares fictional remedies and delivers orders before customers lose patience. We're making it for players who enjoy juggling small tasks under pressure.

我们在做一款以奇幻药房为背景的 2D 限时经营游戏。你扮演药房学徒，挑选药材、配制虚构药方，在顾客失去耐心前交付订单。适合喜欢在限时内安排多项任务的玩家。

## How a shift works / 一轮怎么玩

Our first playable shift will start with one prescription. Read the order, pick the herbs, grind them at the mortar, then wrap and deliver the medicine. Once a second order comes in, you’ll have to decide whether to finish the batch already in the mortar or switch to a customer who is about to leave.

我们计划先做一张处方的完整流程。你先读订单、挑药材，再用研钵磨药，最后包好交给顾客。第二张订单进来后，你就得决定是先磨完手上这份药，还是先处理快等不及的顾客。

We want to try grinding with one hand while using the mouse to manage another order. We’ll test that after the keyboard and mouse version can handle a full order.

我们想试试能不能一只手研磨，另一只手用鼠标处理另一张订单。等键鼠版能完整做完一单，我们再试这种双手操作。

## Workbench preview / 工作台预览

You can try a workbench with four areas: ingredients, mortar, orders and delivery. Click **Test input** in the mortar area to switch its status between idle and active. You can also press **Tab** to focus the button, then **Enter** or **Space**. The preview covers layout and input feedback. Order fulfilment and gesture controls are still planned.

你可以打开工作台预览，查看药材、研钵、订单和交付四个区域。点击研钵区的 **Test input**，状态会在待机和激活之间切换。也可以按 **Tab** 选中按钮，再按 **Enter** 或 **Space**。当前版本可以体验工作台布局和输入反馈，完整的配药交付流程与手势操作仍在计划中。

## Run the preview / 运行预览

Install **Godot 4.7.2 Standard**, then clone or download the [repository](https://github.com/sd5913/forlives--magic_kitchen). In Godot’s Project Manager, choose **Import**, open [`game/project.godot`](game/project.godot) and click **Run Project**. [Download Godot](https://godotengine.org/download/archive/4.7.2-stable/)

安装 **Godot 4.7.2 Standard**，然后克隆或下载[项目仓库](https://github.com/sd5913/forlives--magic_kitchen)。在 Godot 项目管理器中选择 **导入**，打开 [`game/project.godot`](game/project.godot)，再点击 **运行项目**。[下载 Godot](https://godotengine.org/download/archive/4.7.2-stable/)

We build the game in GDScript for Windows and macOS. We’ve verified the preview on macOS. Windows testing is pending. The preview needs a keyboard or mouse and runs without a camera or API key.

我们用 GDScript 开发，目标平台为 Windows 和 macOS。预览已在 macOS 上验证，Windows 版待测。用键盘或鼠标就能运行预览，无需摄像头或 API 密钥。

## Development standards / 开发规范

The Godot project lives in `game/`. The workbench assembles four separate scenes in `game/scenes/`, and Python development tools live at the repository root. We use `snake_case` for game files and `PascalCase` for Godot nodes. The engineering guide covers asset placement, scene ownership, Git and verification. [Engineering standards](docs/technical/ENGINEERING-STANDARDS.md) · [Technical overview](docs/technical/README.md)

Godot 工程放在 `game/`，工作台由 `game/scenes/` 中的四个子场景组成，Python 开发工具放在仓库根目录的独立目录中。游戏文件用 `snake_case`，Godot 节点用 `PascalCase`。素材归档、场景分工、Git 和验证流程见[工程规范](docs/technical/ENGINEERING-STANDARDS.md)与[技术总览](docs/technical/README.md)。

## Project notes / 项目资料

[Project board](https://github.com/orgs/sd5913/projects/23) · [Development progress](docs/WEEKLY-PROGRESS.md) · [Credits and AI assistance](CREDITS.md)

[项目看板](https://github.com/orgs/sd5913/projects/23) · [开发进度](docs/WEEKLY-PROGRESS.md) · [致谢与 AI 辅助说明](CREDITS.md)
