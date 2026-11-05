# Interaction references and design comparisons

Reviewed 6 November 2026. We screened the description and opening README sections of 36 supplied repositories and inspected selected source excerpts from eight related projects. This is a focused design comparison, not a full code audit, playtest, grade ranking or claim of originality. We did not run the examples. Source links may change after this review.

## Closest comparisons

| Reference | Evidence inspected | Implication for our proposal |
| --- | --- | --- |
| [Yummy Spaghetti Monster](https://github.com/TuringRoot/Yummy-Spaghetti-Monster-Web) | README describes hand-controlled cooking and feeding. [StageCooking.tsx](https://github.com/TuringRoot/Yummy-Spaghetti-Monster-Web/blob/main/components/StageCooking.tsx) includes hand landmarks, pinch/fist logic and an active-pot input shared with the mouse | Gesture-controlled cooking is an existing neighbour. Test our particular two-hand order-management relationship instead of claiming novelty from a webcam |
| [Controller Liberator](https://github.com/Rostave/controller-liberator) | [mapping.py](https://github.com/Rostave/controller-liberator/blob/main/mapping.py) exposes steering safe angles and throttle/brake ranges | Calibrate controls and show interpreted input; recognition alone does not establish usable control |
| [Fingertip Tales: Westward](https://github.com/sirichu3/Fingertip-Tales-Westward) | [match.py](https://github.com/sirichu3/Fingertip-Tales-Westward/blob/main/piying/handpose2/match.py) includes finger-angle mapping, inverse kinematics and neutral calibration for a puppet | Relate physical movement to the represented craft. Our gesture should visibly manipulate the preparation process |
| [EmotiKeys 2](https://github.com/YaraMeng/EmotiKeys_2) | [app.js](https://github.com/YaraMeng/EmotiKeys_2/blob/main/head09_test/app.js) connects mouse/touch input to regions, synthesized notes and recording | Ordinary input can support expressive continuous interaction; special hardware is not a substitute for a meaningful mapping |
| [MyFlower](https://github.com/Phyllis-Li/MyFlower) | [main.py](https://github.com/Phyllis-Li/MyFlower/blob/main/main.py) reads mouse position and evaluates open/closed protection across growth stages and hazards | A small control set can support contextual choices. Test a small set of readable preparation rules |
| [Sound Jumper](https://github.com/tulips20L/Sound-Jumper) | [prototype](https://github.com/tulips20L/Sound-Jumper/blob/main/sound_jumper_prototype.py) maps audio RMS above a threshold to bounded jump force and exposes sensitivity adjustment | Continuous input magnitude can change a result; provide calibration and bounds rather than rewarding uncontrolled motion |
| [LuminousMatrix](https://github.com/yy58/LuminousMatrix) | [detector](https://github.com/yy58/LuminousMatrix/blob/main/Main/AreciboMessage/A_ArUcoDetector.py) tracks ArUco markers; [simulation](https://github.com/yy58/LuminousMatrix/blob/main/Main/AreciboMessage/B_AreciboMessage.py) calculates ray intersections | Physical props, simulated behaviour and sensory feedback can share one concept. Distinguish sensor measurements from simulated outputs |
| [Bad Witch](https://github.com/liusenjun/Bad-Witch) | [analysis routes](https://github.com/liusenjun/Bad-Witch/blob/main/routes/analysis_routes.py) connect object-photo upload to analysis, naming and image generation, with error fallbacks | A shared magic theme does not mean a shared game loop. Our proposed ordering and preparation focus differs from object-to-familiar generation |

These observations support design hypotheses. We have not established that our proposed combination is unique, more enjoyable or easier to use.

## Other examples included in the initial screen

The introductory material also covered these projects. No source-level or runtime conclusions are claimed for them in this review.

- [Mind Maze NaN](https://github.com/GRUUIS/Mind_Maze_NaN), [Culturo](https://github.com/linhvuongpolyu/Culturo), [Poly-U-Nap](https://github.com/ZXSJessie/Poly-U-Nap), [King of Python](https://github.com/xueyu-coco/King-of-Python)
- [Urban Legends Forum](https://github.com/Melos47/Urban_Legends_Forum), [FocusSpectrum](https://github.com/Ginandtoshi/FocusSpectrum), [Codepilot Teamwork](https://github.com/Li-Bingjia/Codepilot-teamwork), [Papercraft Maestro](https://github.com/BAO-Hongzhen/Papercraft_Maestro)
- [Soulnote Journal](https://github.com/TinaCEN/Soulnote-Journal), [Let's Yum Cha!](https://github.com/Delores-yip/Let-s-Yum-Cha-), [2MB](https://github.com/Bismarck-KL/2MB), [Dokimeki Audience](https://github.com/Jiayao-lex/Dokimeki_Audience)
- [Zammi's Delivery](https://github.com/tong02160216/Zammis-Delivery), [Grant Scholar Survival Kitchen](https://github.com/Xander-Lucien/GrantScholarSurvivalKitchen), [CRT Buddy](https://github.com/Seeglo0052/CRT_Buddy), [Rockstar Pet](https://github.com/drishtigh/Rockstar-Pet)
- [Eye Maze](https://github.com/JimmyLu333/Eye-Maze), [group / Comfy](https://github.com/WangZetian-IVERSON/group), [Splicing](https://github.com/mckenzieaaa/Splicing), [Aetheria](https://github.com/Zhuyufeng-02/Aetheria)
- [Judgment in Fifteen Days](https://github.com/Huicong967/Judgment-in-Fifteen-Days), [Two-Player Mini-Games Showdown](https://github.com/ChenYingwen-Iris/Two-Player-Mini-Games-Showdown), [Code Rat King](https://github.com/25110291g-YCJ/Code-Rat-King), [Nvwa](https://github.com/Jj-yyy/Nvwa)
- [Digital Garden](https://github.com/HalcyonChen01/Digital-Garden), [Moodify Music](https://github.com/DavidZhou927/moodify-music), [Pixel Creature Generator](https://github.com/Jake-yutong/Pixel-Creature-Generator-PCG-), [CR Final Group Project](https://github.com/Ruoxin-Yu/CR-Final-Group-Project)

## Commercial design references

- [Potion Craft](https://store.steampowered.com/app/1210320/Potion_Craft_Alchemist_Simulator/): its official description emphasises manipulating tools and ingredients. Consider material feedback, without adding a full recipe-research economy to our first slice.
- [Strange Horticulture](https://www.strangehorticulture.com/): its official description connects plant identification, reference information and effects. Consider readable fictional-herb identities, without claiming medical instruction.
- [Overcooked! 2](https://www.team17.com/games/overcooked-2): the publisher describes collaborative cooking and changing kitchens. Consider equipment bottlenecks and recoverable disruption, without importing multiplayer or dynamic levels into the first slice.

No source code, screenshots, sounds or other assets from these examples were copied into the project. If the team later reuses material, check its licence and add the exact source and permitted use to CREDITS.md. A public repository alone does not grant reuse permission.
