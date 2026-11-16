# Order-station art and generation briefs

Prepared 14–15 November 2026 for NEKO / JIN Minyi's module. Runtime files live in [game/assets/ui/orders](../../game/assets/ui/orders/). There were no matching restaurant assets on the inspected remote branches. Figma access was denied, so these are newly generated assets for review, not retrieved Figma exports or a claim of exact design reproduction.

The user supplied a roasting-station reference with warm wooden fixtures, amber lighting, honey-coloured paper and faceted low-poly 2D/2.5D shading. The user rejected the earlier flat-vector draft. This implementation preserves the revised visual direction and renders interactive text and controls separately; it does not ship the user's reference screenshot as a full-screen game image. Source art review and final team approval remain pending.

## Files and use

| Runtime file | Content | Godot use |
| --- | --- | --- |
| `order_counter_background.png` | Text-free order-counter interior in the same restaurant direction | Background stretched to the virtual 1440 × 900 canvas; all ticket text, buttons and counters are live controls |
| `customer_portraits.png` | Three customer busts, alpha background, equal horizontal cells | AtlasTexture regions for Lin, Mr. Chen and Mei. Mr. Wu reuses the second portrait as an explicit prototype limitation |
| `panel_atlas.png` | Four panel surfaces: parchment, dark wood, highlighted gold, subdued parchment | Runtime quadrant slicing/downsampling and nine-slice styles; this prevents oversized borders folding over short buttons |
| `ingredient_atlas.png` | Eight alpha-backed food icons in a four-column, two-row sheet | Atlas regions in the order duck, pancake, cucumber, sauce / sugar, melon, hawthorn, scallion. Captions and counts are separate labels |

PNG `.import` sidecars are tracked; the generated `.godot/` cache is ignored. System fonts are referenced from the OS and not redistributed. Windows checks used Microsoft YaHei for UI text, Georgia for English headings and KaiTi for Chinese headings, with fallback families declared. Other OS font rendering still needs review.

## Tool and prompts

Generated with the built-in OpenAI image tool, not a third-party asset download or a CLI API call. The same user reference was supplied as a style/setting reference, not as an edit target. The following generation briefs record the prompt set; descriptive wording is condensed here. No inference-time AI service is needed to play.

1. **Background:** a production 16:10 order-counter background for the same Peking duck restaurant; warm amber light, faceted hand-painted timber and tiled architecture, chestnut wood and honey-paper palette. Reserve the top 100/900 for a broad empty wooden header; middle 100–660 for a counter interior, left lattice window, quiet centre behind a ticket overlay, and an empty right service window for a separate customer; bottom 660–900 a dark wooden panel for live instructions. Restrict props to corners. No characters, oven, tickets, UI, text, icons or watermark. Output reference: `exec-11f199ac-0ce6-47ba-b4d3-e722c3deaa84.png`.
2. **Customers:** three bust sprites in one transparent horizontal sheet, equal columns and a shared baseline. Friendly East Asian guests: short-haired young woman in muted copper, middle-aged man with round glasses and a brown jacket, tied-back-haired woman in russet/cream. Match faceted low-poly cooking-game shading, not flat vector or photography. Keep head, shoulders, chest and resting hands inside each cell. No room, counter, frames, text or watermark. Output reference: `exec-4660e50d-59ba-4242-b9d4-f65155eda505.png`.
3. **Panels:** a text-free 2×2 UI texture atlas matching the warm restaurant. Equal quadrants: pale parchment with geometric corners; chestnut carved wooden plaque; honey-gold highlighted parchment/button; desaturated beige parchment. Keep decoration at edges and plain centres for live text, face the camera without tilt. No icons, words, room or watermark. Output reference: `exec-4946af7a-4dfb-4d36-952f-8b29db7c1459.png`.
4. **Food:** a transparent 4×2 sheet with one padded icon per cell: sliced roast duck, pancakes, cucumber, bean sauce / sugar, melon, hawthorn, scallion. Match amber-lit faceted cooking-game art, with white/green scallion distinct from cucumber. No interface, captions, grid, background or watermark. Runtime regions inset the cell edges to avoid edge artefacts. Output reference: `exec-e4f7ec14-6445-4082-8227-cb96eb56bc68.png`.

The atlas layout is a runtime sampling convention, not a guarantee that generated art perfectly respects every pixel boundary. The imported regions and their appearance were checked in the running Godot station. No code or media from the 36 example repositories was copied for this module. The team should decide its repository licence before redistributing project assets outside the team; this document does not assert an external stock-art licence.

## Verification and revisions

The original generated PNGs remain unchanged. Godot samples the sprite regions and scales the panel tiles at runtime. The generated background and alpha sheets were imported and rendered on Windows. The first nine-slice treatment folded large borders over small controls; it was replaced with proportionally downsampled tiles. The user's bilingual-alignment feedback led to explicit label rectangles, vertical centring, language-specific heading fonts, ingredient-caption centring and customer-nameplate alignment.

The rendered UI regression checks verify nonempty art/alpha, text width and specified label bounds, equal button geometry after translation, queue/capacity/expiry states and a small-window layout. Actual Godot screenshots are in [docs/images](../images/). These checks are not Figma approval, a human playtest or platform certification.
