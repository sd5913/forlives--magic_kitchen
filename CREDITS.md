# Credits and AI assistance / 致谢与 AI 辅助说明

## AI-assisted development / AI 辅助开发

We used OpenAI Codex to draft and translate project documents, compare interaction references and set up the repository checks. Codex also helped write the Python input router, simulation and tests, and build the initial Godot workbench scenes and input feedback. We use [Stop Slop](https://github.com/hardikpandya/stop-slop) to edit documentation for clarity.

我们用 OpenAI Codex 起草和翻译项目文档、比较交互参考，并搭建仓库检查。Codex 也参与了 Python 输入路由、模拟和测试，以及 Godot 工作台初版场景和输入反馈的编写。文档措辞使用 [Stop Slop](https://github.com/hardikpandya/stop-slop) 辅助编辑。

The workbench preview uses Godot’s built-in controls and colours. It runs locally without calling a generative AI service.

工作台预览使用 Godot 自带的控件和颜色，在本地运行，无需调用生成式 AI 服务。

## Shared interface design / 公共界面设计

We used Codex to organise the shared Figma component library, separate common controls from station content, derive decorative frame parts from the team's selected image and inspect layout, text remnants and resize behaviour. The kit keeps text and vector icons editable while using local raster crops for decorative textures. No new generative image assets were created in this component pass.

我们用 Codex 整理共享 Figma 组件库，区分公共控件与工作台内容，从团队选定的图片拆出装饰边框，并检查布局、文字残影和拉伸表现。组件中的文字与矢量图标可编辑，装饰纹理使用原图局部位图。本轮组件整理没有新生成插画素材。

The [UI handoff](docs/design/UI-KIT.md) links the source image and components. The selected image's creator, original-generation details and permission for runtime redistribution have not yet been recorded here. Before exporting it into the game, we will document that provenance rather than infer authorship or a licence from Figma access.

[界面交接](docs/design/UI-KIT.md)保存原图与组件链接。所选图片的作者、原始生成信息及运行时再分发许可尚未在这里登记；导出进入游戏前，我们会补齐来源，不把 Figma 访问权限当作作者或授权证明。

## Tools and references / 工具与参考

We build the game with [Godot](https://godotengine.org/) and GDScript. The input simulation and repository checks use Python’s standard library. We consulted other projects when exploring gesture controls. The [interaction reference notes](docs/INTERACTION-REFERENCES.md) list those projects and what we looked at. We did not copy their code or media.

我们用 [Godot](https://godotengine.org/) 和 GDScript 制作游戏，输入模拟和仓库检查使用 Python 标准库。探索手势操作时，我们参考了其他项目。[交互参考记录](docs/INTERACTION-REFERENCES.md)列出了项目和查阅内容。我们没有复制其中的代码或媒体。

We use the course’s [Group Project 2026 template](https://github.com/orgs/sd5913/projects/1) for the [project board](https://github.com/orgs/sd5913/projects/23) that MiaJiao5 set up.

我们的[项目看板](https://github.com/orgs/sd5913/projects/23)由 MiaJiao5 使用课程的 [Group Project 2026 模板](https://github.com/orgs/sd5913/projects/1)建立。
