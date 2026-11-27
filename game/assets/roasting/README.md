# Roasting station runtime layers

These layers reuse the team's approved Figma roasting station (page 195:1371), exported in `Roasting_Assets` v3. The reference canvas is 1536 × 1024. The empty background, six duck sprites and UI skins are separate resources; no full-screen screenshot is used as an interactive screen.

The original visual assets are team/AIGC co-created, as recorded in the existing design handoff. No new artwork was generated during this integration. The gesture illustrations reuse the shared runtime assets in `assets/ui/gestures/`. English uses the existing Bree Serif font and its bundled OFL license; Chinese uses the host's existing fallback font.

`scenes/roasting/roasting_station.tscn` is initialized by the shared shift host. It displays the selected ticket's actual ingredients and progress, the other active tickets, the raw/cooling/sliced tray contents, and up to two roasting orders. Clicking a hanging duck selects its bound order. Mouse action cards and keyboard/camera input use the unchanged shared session actions 1/2/3.

The selected duck's pointer moves along the three-colour track. Cooked and burnt boundaries come from `data/shift_rules.json`; those boundaries map to the track's colour boundaries. Removing a duck locks its time. Pausing, overlays, order identity, capacity, arrival timing, scoring and cooking handoff remain owned by the shared host/session.

The camera is optional and was not physically validated in this integration. The waiting scene shows the selected order's raw duck before loading; an unrelated spare raw duck is not displayed once that order is cooking. Undercooked/burnt ducks on the cooling tray currently reuse the lying cooked-duck silhouette with a state tint, because the supplied pack has only one lying cooked sprite. Slice completion changes to the supplied platter after the existing one-second slicing state; there is no new knife animation.

Verification: Godot 4.7.2 Standard, Windows, Compatibility renderer. Run `--path game --script res://tests/test_roasting_station.gd` for the roasting integration checks; set `MAGIC_KITCHEN_SCREENSHOT_DIR` to capture rendered states. Existing shared UI and gameplay tests cover the unchanged cross-station behavior. Automated checks are distinct from a human playtest.
