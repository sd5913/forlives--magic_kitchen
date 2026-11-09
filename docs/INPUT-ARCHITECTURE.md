# Interaction input boundary

I want the team to be able to change how an action is triggered without rewriting the rules that respond to it. I tested that boundary before choosing the [Godot runtime](ENGINE-DECISION.md). Gameplay and gesture design remain open.

```text
Mouse / keyboard adapter     Optional gesture adapter or simulated input
                 \           /
             Named action + active/inactive
                           |
                       InputRouter
                           |
                  Action state transitions
                           |
              Future game rules and feedback
```

## Contract

1. The adapter translates its own control into a named action. It sends `set_active(action, True)` to start and `set_active(action, False)` to stop. The action name has no engine, key, pointer or landmark data in it.
2. `InputRouter` emits a transition only when the first source starts or the last source stops the action. Repeats and duplicate releases have no effect. A different action remains independent.
3. On tracking loss or device disconnect, call `disconnect()` and deliver its returned releases. On pause or focus loss, call `suspend()` and deliver its releases. Both operations invalidate the affected connection handles, so delayed callbacks from those handles cannot resume an action. On recovery, reconnect and wait for fresh input.
4. The future engine adapter consumes transitions on the game thread. The game decides what an action does, whether it is currently allowed, and how to show progress. The router does not store gameplay progress. For example, a stopped action does not itself reset preparation progress.

Each source reports the combined held state of its physical controls if several of those controls map to the same action. If tracking is added later, the adapter owns confidence thresholds, calibration and the mapping from gesture to action. Queue callbacks for the game thread and keep the connection handle that produced them; do not retarget old callbacks to a replacement handle.

This first contract supports discrete start/stop actions. It does not define continuous values, gesture shapes, timing rules, order IDs or a binding between an action and a particular workbench. Add those at the layer that needs them after the team tests the first slice. Keep camera frames and device details out of gameplay code.

## What I can run now

From the repository root, with Python 3.9 or later:

```sh
python3 -m interaction.demo
python3 -m unittest discover -s tests -v
```

On Windows, use `py -3` in place of `python3`. The demo replays a gesture and keyboard holding the same action, then loses tracking, ignores a late sample and releases the final hold. It also shows pause/focus-loss cleanup. It uses no camera or device access and does not read real keyboard or mouse events.

## Integration checkpoint

I will first wire one Godot InputMap action to a visible response and run equivalent contract checks against the GDScript implementation. Python here is a reference harness and is not part of the game runtime. I will add a gesture source only if the team chooses one, and verify loss/recovery and ordinary input fallback before calling it ready. No hardware or camera choice is required for this change.
