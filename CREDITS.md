# Credits and AI assistance / 致谢与 AI 辅助说明

## AI-assisted development / AI 辅助开发

We used OpenAI Codex to draft and translate project documents, compare interaction references and set up the repository checks. Codex also helped write the Python input router, simulation and tests, and build the initial Godot workbench scenes and input feedback. We use [Stop Slop](https://github.com/hardikpandya/stop-slop) to edit documentation for clarity.

我们用 OpenAI Codex 起草和翻译项目文档、比较交互参考，并搭建仓库检查。Codex 也参与了 Python 输入路由、模拟和测试，以及 Godot 工作台初版场景和输入反馈的编写。文档措辞使用 [Stop Slop](https://github.com/hardikpandya/stop-slop) 辅助编辑。

The original workbench uses Godot's built-in controls and colours. The order station added on 14 November uses four image assets generated with OpenAI's built-in image tool from the user's supplied kitchen style reference. Codex wrote the module, tests and supporting documentation under NEKO / JIN Minyi's direction. The user corrected the first visual draft to match the team's established restaurant style. See [asset provenance and generation briefs](docs/technical/ORDER-ASSETS.md).

旧工作台使用 Godot 自带控件和颜色。11 月 14 日新增点单模块使用内置图片生成工具制作的四份图像素材，以用户提供的厨房渲染稿为风格参考；Codex 在 NEKO / JIN Minyi 的指导下编写模块、测试和文档。用户指出初版风格不统一，随后替换为团队的暖色低多边形方向。[素材来源与生成说明](docs/technical/ORDER-ASSETS.md)

Both previews run locally without calling a generative AI service. System fonts are referenced from the operating system, not redistributed. We did not retrieve Figma artwork, copy the supplied reference screenshot into the runtime, or import code/media from the example repositories for this module.

两种预览都在本地运行，不调用在线生成服务。字体使用系统字体，不随仓库分发。点单模块没有声称取得 Figma 资源，也没有把参考截图整张贴入游戏；未复制课程例子仓库的代码或素材。

## Tools and references / 工具与参考

We build the game with [Godot](https://godotengine.org/) and GDScript. The input simulation and repository checks use Python’s standard library. We consulted other projects when exploring gesture controls. The [interaction reference notes](docs/INTERACTION-REFERENCES.md) list those projects and what we looked at. We did not copy their code or media.

我们用 [Godot](https://godotengine.org/) 和 GDScript 制作游戏，输入模拟和仓库检查使用 Python 标准库。探索手势操作时，我们参考了其他项目。[交互参考记录](docs/INTERACTION-REFERENCES.md)列出了项目和查阅内容。我们没有复制其中的代码或媒体。

We use the course’s [Group Project 2026 template](https://github.com/orgs/sd5913/projects/1) for the [project board](https://github.com/orgs/sd5913/projects/23) that MiaJiao5 set up.

我们的[项目看板](https://github.com/orgs/sd5913/projects/23)由 MiaJiao5 使用课程的 [Group Project 2026 模板](https://github.com/orgs/sd5913/projects/1)建立。
