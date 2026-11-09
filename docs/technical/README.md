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

I verified that the pinned Godot build starts on the Mac and can run a small headless check for a 2D node and InputMap press/release. That does not establish rendered performance, a Windows export or a playable build. The [development notes](../DEVELOPMENT.md) explain the checks currently in the repository.

I will first check for an existing local project from the team. Then I want one shared Godot scene where an ordinary input produces a visible response, with launch steps checked on the two target platforms. That is the point to grow the one-order loop. I would revisit the engine only if verified existing work or a blocker on the demonstration machines changes the trade-off.
