# Engine decision: Godot for the desktop game

**Decided by JIN Minyi, 9 November 2026.** I chose **Godot 4.7.2 Standard, GDScript and the Compatibility renderer**. Windows and macOS desktop are the first targets. Use the same [official stable build](https://godotengine.org/download/archive/4.7.2-stable/) on both computers and keep that version through the course delivery unless a specific blocker requires an upgrade.

## Why I chose it

The current scope is a single-player 2D game with one workbench and a short order loop. The likely work is combining readable controls, ingredient and order state, timers, animation and sound. Godot gives us a [dedicated 2D workflow](https://docs.godotengine.org/en/stable/tutorials/2d/index.html), editable scenes and UI, and named actions through [InputMap](https://docs.godotengine.org/en/stable/classes/class_inputmap.html). The Compatibility renderer is sufficient for this scope; check [system requirements](https://docs.godotengine.org/en/stable/about/system_requirements.html) and verify on the actual demo machines.

I considered Pygame because the team can reuse its Python experience. It remains useful for isolated experiments, but for this project the shared editor and built-in UI/scene tools are worth more than keeping the game in Python. Unity could also support the game; I did not see a requirement that justified adopting another larger toolchain. I am keeping Godot's Standard build and GDScript so we do not need a separate .NET setup.

## Input and delivery boundaries

- Map keyboard and mouse through Godot. Keep game rules behind the [named action boundary](INPUT-ARCHITECTURE.md) so input changes do not require rewriting order or workbench logic.
- Use GDScript for game code. The Python reference and tests remain useful for exploring the contract; the shipped game will not need Python for its base controls.
- Make the first slice fully operable with ordinary input. If we later choose gestures, treat recognition as an optional source. First test tracking loss and recovery with simulated input, then evaluate a camera on the target machines. No external controller, camera or recognition dependency is required to start the game.
- The engine decision leaves interaction mapping, art, recipe content and the scope of the shift open for team discussion.

## First engineering checkpoint

I will reconcile any unpushed team project before creating a competing scene. The first Godot commit should open on both desktop platforms and have one workbench placeholder where an ordinary input produces visible feedback. Then I can wire the one-order loop and test its invalid-action path before adding a second order. Verify editor launch, keyboard/mouse input, focus loss and a desktop export on the intended demonstration machines. This decision is not evidence that a Godot game or desktop export already exists.
