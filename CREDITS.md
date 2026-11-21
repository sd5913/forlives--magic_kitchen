# Credits / 致谢

## Tools and AI assistance / 工具与 AI 辅助

We’re building the game with [Godot](https://godotengine.org/) and GDScript. The input simulation and repository checks use Python’s standard library.

我们使用 [Godot](https://godotengine.org/) 和 GDScript 制作游戏，输入模拟与仓库检查使用 Python 标准库。

OpenAI Codex helped us draft and translate documentation, compare interaction references, write repository checks and work on the Python input router, simulation and tests. It also helped build the initial Godot workbench and input feedback. Documentation has also been edited with [Stop Slop](https://github.com/hardikpandya/stop-slop).

Codex also helped build the standalone cooking-station prototype, including placeholder food drawings and interaction logic, using the team's exported UI frames.

OpenAI Codex 参与了文档起草与翻译、交互参考比较、仓库检查，以及 Python 输入路由、模拟和测试的编写，也协助制作了 Godot 初版工作台与输入反馈。文档曾使用 [Stop Slop](https://github.com/hardikpandya/stop-slop) 辅助编辑。

For the shared Figma kit, we used Codex to organise reusable controls, separate them from station content, extract decorative frame parts and check layout and resizing. This component pass reused the selected image; it did not generate new illustrations. The current workbench preview runs locally without a generative AI service.

整理公共 Figma 组件时，我们用 Codex 归纳共用控件、区分工作区内容、拆分装饰边框，并检查布局与拉伸效果。本轮组件制作复用了选定原图，没有新生成插画。当前工作台预览在本地运行，无需调用生成式 AI 服务。

## Art and design sources / 美术与设计来源

The [design page](docs/design/README.md) links our Figma work and exported files. The [manifest](docs/design/exports/manifest.json) records the source node for each export. The selected reference image’s creator and runtime-use permission still need to be added before those textures are published as game assets.

[设计页面](docs/design/README.md)保存 Figma 与导出文件入口，[清单](docs/design/exports/manifest.json)记录每份导出的来源节点。选定参考图的作者与运行时使用许可还需补齐，再将对应纹理发布为游戏素材。

## References / 参考

The [interaction notes](docs/INTERACTION-REFERENCES.md) list the projects we consulted while exploring gesture controls. We did not copy their code or media.

探索手势操作时查阅的项目记录在[交互参考](docs/INTERACTION-REFERENCES.md)中，没有复制它们的代码或媒体。

For the README’s structure, we looked at [SuperTux](https://github.com/SuperTux/supertux/blob/master/README.md) and [Endless Sky](https://github.com/endless-sky/endless-sky/blob/master/README.md): introduce the game, show it, then explain how to run it and where to find development details.

整理 README 时，我们参考了 [SuperTux](https://github.com/SuperTux/supertux/blob/master/README.md) 和 [Endless Sky](https://github.com/endless-sky/endless-sky/blob/master/README.md) 的信息顺序：先介绍游戏和展示画面，再说明运行方法与开发资料入口。

Our [project board](https://github.com/orgs/sd5913/projects/23) was set up by MiaJiao5 using the course’s [Group Project 2026 template](https://github.com/orgs/sd5913/projects/1).

[项目看板](https://github.com/orgs/sd5913/projects/23)由 MiaJiao5 使用课程的 [Group Project 2026 模板](https://github.com/orgs/sd5913/projects/1)建立。
