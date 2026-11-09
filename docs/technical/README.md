# Technical module

I chose **Godot 4.7.2 Standard, GDScript and Compatibility rendering** for the Windows and macOS versions of Magic Kitchen. Godot is the engine; GDScript is the game scripting language. Go is not part of the stack. The [engine decision](../ENGINE-DECISION.md) records the pinned version and links to the official download.

## Why Godot for this game?

I started with the smallest playable version: one 2D workbench, one prescription, a few visible ingredient states, and feedback when an action starts, stops or finishes. The difficult part is making the order state and the player's next action readable while they work. I want us to adjust the layout, animations and feedback in an editor while keeping order rules in code. Godot's [dedicated 2D workflow](https://docs.godotengine.org/en/stable/tutorials/2d/index.html) fits that job, and the Standard build lets us use GDScript without adding a separate .NET setup.

Unity has a capable [2D workflow](https://docs.unity.com/en-us/engine/6000.6/manual/unity2d) and its [Input System](https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/Actions.html) also separates actions from controls. I would prefer Unity if the team already had a usable Unity prototype, could build appreciably faster in C#, or needed a specific package that we had verified on both target platforms. I have not verified any of those advantages for this project. Starting both engines would split our limited time across two projects, so I chose one and pinned the version.

Pygame was a reasonable starting point when we were thinking in Python. I am keeping Python for isolated input experiments and tests. For the actual game, I prefer an editor where a teammate can adjust a workbench layout or animation without making the same change in Python code. This is a workflow decision; I did not benchmark the engines against each other.

## What the engine does and what the game owns

| Area | Where I put it |
| --- | --- |
| Workbench layout, pointer and keyboard bindings, animation and audio | Godot scenes, UI and [InputMap](https://docs.godotengine.org/en/stable/classes/class_inputmap.html) |
| Which order is active, whether an action is allowed, and what changes when it completes | GDScript game rules that consume named actions |
| Optional camera or other gesture input | An adapter that reports the same actions; any recognition, calibration and tracking-loss handling belong at that boundary |

For example, holding a key and a future gesture can both mean “start preparation.” The order logic needs to know that preparation started; it does not need the keycode or camera frames. The [input contract](../INPUT-ARCHITECTURE.md) describes how overlapping sources and interruptions behave. A gesture is not required to finish the first playable loop.

## Implementation and evidence

I verified the workbench on macOS with Godot 4.7.2 Standard. The project opened in a normal window with Compatibility rendering, and simulated mouse and keyboard events switched the mortar status. Windows launch and a desktop export are still to be checked. The [development notes](../DEVELOPMENT.md) cover the repository checks.

## Workbench layout and ownership

Import [game/project.godot](../../game/project.godot) in Godot 4.7.2 Standard and run the project. Click **Test input** or press **Tab** then **Enter** or **Space** to switch the mortar status.

The baseline uses a 960 × 540 reference viewport. Ingredients sit on the left, preparation in the centre, and orders above delivery on the right. This is a starting layout for integration and can change after review.

| Proposed owner | Files | First responsibility |
| --- | --- | --- |
| JIN Minyi | [workbench.tscn](../../game/scenes/workbench.tscn), [project.godot](../../game/project.godot) | Maintain the main scene, zone placement and shared project settings. Integrate subscenes and check the full workbench. |
| MiaJiao5 | [order_panel.tscn](../../game/scenes/order_panel.tscn) | Build the order display inside the assigned zone. |
| ZHANGYan-Sybil | [ingredient_storage.tscn](../../game/scenes/ingredient_storage.tscn), [delivery_counter.tscn](../../game/scenes/delivery_counter.tscn) | Build ingredient and delivery interfaces inside their respective zones. |
| deadlytomatovo | [mortar.tscn](../../game/scenes/mortar.tscn), [mortar.gd](../../game/scenes/mortar.gd) | Build preparation feedback and keep the keyboard and mouse check working. |

I propose these assignments for the team to confirm. Contributors edit their subscenes in separate branches. I adjust instance positions in the workbench. Changes to a zone's footprint or to shared project settings go through the workbench owner.

## Naming and review

- Use `snake_case` for scene and script filenames, variables and functions. Use `PascalCase` for scene nodes and classes. Use tabs in GDScript and UTF-8 with LF in source files.
- Commit scene files, scripts and their generated `.gd.uid` sidecars. Keep the local `.godot/` cache out of Git.
- Use `feature/`, `fix/` or `docs/` branches and keep each PR focused on its assigned area. Open the workbench and check that the changed zone fits and the input check still responds before integration.

[Godot GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) · [Contribution workflow](../../CONTRIBUTING.md)
