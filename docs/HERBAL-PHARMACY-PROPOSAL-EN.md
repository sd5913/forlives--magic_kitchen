# Herbal Pharmacy Game Proposal

Working title: Herbs on the Clock

## Concept

Players work as an apprentice in an ancient Chinese fantasy pharmacy. During timed shifts, they take prescriptions, find herbs, slice and weigh ingredients, wrap orders and deal with unexpected problems.

The setting combines traditional herb drawers, small balance scales, grinding tools and oil-paper packages with magical plants that run away, herbs that need calming and customers with unusual symptoms. The herbs, prescriptions and effects are fictional and designed around the game.

## Gameplay

Take a prescription → collect herbs from the cabinet → slice and weigh them as needed → wrap the order → hand it over.

Each prescription has its own ingredients and preparation steps, and each customer has a patience timer. Players can prepare the next order while another task is underway. They need to decide what to do first to keep orders accurate and customers waiting as little as possible.

Not every herb needs every step. Some only need weighing, others need slicing, and some need their magic stabilised before they can be used.

## Controls

The right hand uses the mouse for selecting ingredients and managing orders. The left hand uses webcam gestures for preparation and spells. Players can click or use the mouse wheel to switch between work areas.

| Task | Right hand mouse | Left hand gesture |
| --- | --- | --- |
| Take orders and collect herbs | Read the prescription, open drawers and select herbs | No gesture needed |
| Slice herbs | Place herbs on the cutting board and start | Short up-and-down movements to control the chopping rhythm |
| Weigh herbs | Add or remove herbs while watching the scale | No gesture needed |
| Grind herbs | Select the herbs in the grinder | Move in circles to grind |
| Wrap and deliver | Click or hold to wrap; drag the package to its order | No gesture needed |
| Handle accidents | Select the affected object | Hold an open palm briefly to cast a stabilising spell |

Starting a gesture locks it to the selected tool or ingredient, so the mouse can work on another order. Highlights, progress indicators and sounds show what is being controlled and when it is finished. The movements should feel like using the tool, taking inspiration from motion-controlled games. The current control plan is webcam plus mouse.

## Example

You are weighing the first order when a second customer starts getting impatient. You put the second order into the grinder, make circles with your left hand and use the mouse to finish weighing the first order.

Then a magical herb escapes from a drawer. Do you deliver the nearly overdue order first, or catch the herb before it knocks over the scale? The aim is a busy shift that needs both hands, with room to recover when something goes wrong.

## Unexpected events

Two possible events, each with a warning and a way to recover:

- Escaping herbs: a herb shakes before escaping, then briefly disrupts the work area. Catch it with the mouse.
- Unstable magic: unusual light effects appear during preparation. Pause the task and use the stabilising gesture before time runs out.
## References

- Airplane Chefs: customer patience, preparation steps and increasing pressure during a shift.
- Overcooked!: shared equipment, overlapping tasks and recovering from mistakes.
- Motion-controlled games: simple physical movements that match the action on screen.
The main idea is to combine traditional Chinese pharmacy tasks with two-hand controls, letting players manage orders while physically preparing herbs.

## First prototype

We are tentatively planning a 2D game using VS Code and Godot:

- One pharmacy workbench scene.
- Four fictional herbs and three basic prescriptions.
- Collecting, weighing, grinding, wrapping and delivering herbs.
- One main gesture: circular grinding.
- One unexpected event.
- Customer patience, scoring, an end-of-shift summary and basic sound effects.
First, test whether grinding with the left hand while handling other tasks with the mouse feels smooth and fun. Slicing, stabilising spells, more orders and upgrades can come later.

## Visual and interaction references

Reference images from the original proposal are included below. Joy-Con movement is an interaction reference; the current plan uses webcam gestures and a mouse.

English translation assisted by Codex.

*English translation assisted by Codex. Reference images are included in the Word version.*
