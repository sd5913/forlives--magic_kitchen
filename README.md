# Magic Kitchen

The current GDD v1.0 defines **Peking duck roll preparation**, a 2D time-management cooking game for Windows PC. Players take ingredient-specific orders, roast and slice duck, assemble rolls and deliver them. The earlier herbal-shop documents are historical exploration, not the current gameplay specification.

当前以 **Magic_Kitchen_GDD_v1.0** 的北京烤鸭卷制作方案为准：点单、烤鸭与片鸭、配料卷制、点击交付。目标是喜欢轻量经营、烹饪模拟和节奏管理的 Windows PC 玩家。早期药房文档作为历史探索保留，不再作为当前玩法要求。

## Playtest / 试玩

The `feature/playable-shift` branch connects ordering, roasting, preparation and delivery in one workbench. Read the ticket and accept it at the order station. Click **Roast** to return to the workbench, then **Start roast**. The prototype roasts and slices the duck after a short wait. Select each other ingredient and click **Add ingredient** once per required portion. Click **Finish roll**, then **Serve roll**.

`feature/playable-shift` 分支把点单、烤制、料理和交付接到了同一工作台。先在点单台查看并接受订单。点击 **Roast** 返回工作台，再点 **Start roast**。原型会在短暂等待后完成烤制和片鸭。选择其余配料，按订单要求的份数点击 **Add ingredient**。最后点击 **Finish roll**，再点击 **Serve roll**。

You can clear the ingredients and try again if they do not match the ticket. Keep an eye on the countdown as you switch stations. The prototype clears unfinished food when an order expires and counts each successful delivery once.

配料不符时，可以清空后重试。切换工作区域时留意倒计时。订单过期后会清掉未完成的食材，每份成功交付的订单只计一次。

## Run the preview / 运行预览

Install **Godot 4.7.2 Standard**, then switch to the [playtest branch](https://github.com/sd5913/forlives--magic_kitchen/tree/feature/playable-shift). In Godot’s Project Manager, choose **Import**, open [`game/project.godot`](game/project.godot) and click **Run Project**. [Download Godot](https://godotengine.org/download/archive/4.7.2-stable/)

安装 **Godot 4.7.2 Standard**，然后切到[试玩分支](https://github.com/sd5913/forlives--magic_kitchen/tree/feature/playable-shift)。在 Godot 项目管理器中选择 **导入**，打开 [`game/project.godot`](game/project.godot)，再点击 **运行项目**。[下载 Godot](https://godotengine.org/download/archive/4.7.2-stable/)

The earlier workbench was checked on macOS. This order-station change was checked on Windows with Godot 4.7.2 Standard, Compatibility rendering and simulated mouse/keyboard events. The preview runs locally without a camera, API key or runtime AI service. The order station also passed its automated checks on macOS. A packaged Windows export remains pending.

旧工作台有 macOS 检查记录；本次点单模块在 Windows、Godot 4.7.2 Standard 和 Compatibility 渲染下检查了画面及模拟鼠标/键盘操作。运行不需要摄像头、API 密钥或在线 AI 服务。点单模块也已通过 macOS 自动检查，Windows 导出包待验证。

## Development standards / 开发规范

The Godot project lives in `game/`. The workbench assembles four separate scenes in `game/scenes/`, and Python development tools live at the repository root. We use `snake_case` for game files and `PascalCase` for Godot nodes. The engineering guide covers asset placement, scene ownership, Git and verification. [Engineering standards](docs/technical/ENGINEERING-STANDARDS.md) · [Technical overview](docs/technical/README.md)

Godot 工程放在 `game/`，工作台由 `game/scenes/` 中的四个子场景组成，Python 开发工具放在仓库根目录的独立目录中。游戏文件用 `snake_case`，Godot 节点用 `PascalCase`。素材归档、场景分工、Git 和验证流程见[工程规范](docs/technical/ENGINEERING-STANDARDS.md)与[技术总览](docs/technical/README.md)。

## Project notes / 项目资料

[Project board](https://github.com/orgs/sd5913/projects/23) · [Development progress](docs/WEEKLY-PROGRESS.md) · [Credits and AI assistance](CREDITS.md)

[项目看板](https://github.com/orgs/sd5913/projects/23) · [开发进度](docs/WEEKLY-PROGRESS.md) · [致谢与 AI 辅助说明](CREDITS.md)
