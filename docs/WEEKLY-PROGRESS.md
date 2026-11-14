# Weekly progress and tutor deliveries

Final Canvas deadline: **6 December 2026, 23:59 HKT**. The dates below are Thursday class weeks; the tutor confirms the exact meeting time. There is no extra Canvas upload for these weekly records.

## 29 October 2026: repository setup

- Verified: the repository is public and owned by sd5913; IceyHikari has Admin access.
- Existing product state: only the initial README was present when setup began. No runnable project or playtest evidence yet.
- Work prepared: collaboration guidance, proposed Definition of Done, scope/access backlog and this dated delivery record, using the official project brief and Week 8 teamwork guide.
- Board: use MiaJiao5's existing [#23](https://github.com/orgs/sd5913/projects/23), with its template iterations/views and existing delivery cards preserved. The repository is linked. Issues #1–#3 track scope, access and the first interaction.
- Access: IceyHikari, MiaJiao5 and deadlytomatovo have repository Admin access. ZHANGYan-Sybil has a pending repository invitation. IceyHikari can edit board #23; other teammates' actual board access and organization base-access setting still need verification. A temporary duplicate board was consolidated into the existing board at the user's request.
- Blockers: audience, platform, scope and tutor slot are not recorded yet; pending invitation/access checks remain open.
- Next: confirm access and scope, then implement the first small interaction. No tutor feedback has been received in this setup record.

## Class week of 5 November 2026: first working interaction

Goal: someone can try one input and see the intended response. Agree the next small goal with the tutor.

- Task owners: to agree
- Usable delivery / run link: pending
- Issues, PRs and tests: pending
- User or teammate observations: not yet recorded
- Tutor feedback: not recorded here; confirm with attendees rather than assuming no review took place
- Blocker or question: to prepare
- Next goal, owners and acceptance checks: to agree after review

## 6 November 2026: proposal and interaction review

- Completed documentation work: compared the current proposal with the course brief, screened the introductions of 36 supplied example repositories and inspected selected source excerpts from eight related projects. Added [design refinement](DESIGN-REFINEMENT.md) and [interaction references](INTERACTION-REFERENCES.md); updated README and the proposed team plan.
- Kept: the fantasy pharmacy setting and the original two-hand preparation idea. The original proposal remains unchanged.
- Changed: prioritise a small two-hand grinding prototype; explain the proposed relationship between gesture, material state and order scheduling instead of presenting camera use alone as the distinguishing feature. Keep a non-camera fallback and test tracking loss and comfort.
- Evidence boundary: no example projects were run, no new game code was produced and no user/tutor trial is claimed. The shared main branch contained documentation only at the start of this update; teammates may have work elsewhere.
- Open: share existing local work, confirm the actual 5 November review, agree prototype ownership and verify the current runtime and access. Do not close implementation tasks based on this document update.
- Assistance: Codex conducted the repository reading and drafted this refinement at IceyHikari's request. Team decisions and actual observations still need confirmation.

## Class week of 12 November 2026: integrated core experience

Goal: demonstrate the main game loop, app flow or installation interaction working together.

- Owners / usable delivery / evidence: pending
- Tutor feedback and blockers: not yet recorded
- Next goal with owners: pending review

## Class week of 19 November 2026: playtest and feedback

### 14 November: NEKO ordering implementation prepared for review

- Design input: user supplied GDD v1.0 for Peking duck rolls and confirmed NEKO / JIN Minyi owns ordering. The user rejected the first flat-vector visual draft and supplied a warm, faceted low-poly kitchen reference; that draft was replaced before any push.
- Implemented on `feature/order-station`: isolated order manager, data-driven ingredient requests, customer arrival and selection, guarded acceptance/capacity, waiting and expiry, English/Chinese UI, pause and restart confirmation. Added a station overlay to the existing order panel; other zones and shared project settings were left unchanged.
- Art: generated background, customer sheet, food-icon sheet and panel textures to follow the supplied reference. UI text, order state and buttons remain live Godot controls. Existing remote branches contained no matching art; Figma access was denied, so this is not a verified Figma reproduction.
- Verification on Windows / Godot 4.7.2 / Compatibility renderer: 38 manager checks and 31 rendered UI checks passed, along with six existing Python router tests. Fixed oversized texture borders and verified local art imports, alpha, small-window layout, capacity, expiry, mouse/keyboard input and open/close behaviour. Screenshots and reproduction commands are linked in the [module guide](technical/ORDER-STATION.md).
- Pending: review by the team's visual owner, real teammate trial and integration of oven/prep/delivery/scoring. No player or tutor feedback was invented. This is a usable ordering increment, not the completed cooking game.

### 15 November: bilingual alignment follow-up

- User feedback: English and Chinese appeared misaligned; use English by default for presentation and retain a Chinese toggle.
- Changed: explicit vertical centring and text rectangles, language-specific heading fonts, queue subtitle/time heights, centred ingredient captions and customer nameplates. Some short text boxes were smaller than the system font's minimum height and Godot expanded them; the layout check now catches that condition.
- Evidence: the rendered UI/layout run passes 385 assertions, including same-ticket bilingual screenshots, label bounds and button-geometry comparisons. The checks use simulated input; this is user-directed iteration, not an invented classmate trial. Final visual-owner review and fresh-machine/export checks remain pending.
- Reproduction: a fresh local clone of code commit `141e96c`, without cached imports, passed asset import, 38 state checks, 385 UI/layout assertions and the repository checker on this Windows machine. A second physical machine and exported build have not been tested.

Goal: bring observations from another person trying the experience and choose an improvement.

- Owners / usable delivery / evidence: pending
- Actual playtest observations: not yet recorded
- Tutor feedback and next improvement with owner: pending review

## Class week of 26 November 2026: delivery candidate

Goal: test a runnable build, deployment or installation setup on the chosen platform.

- Owners / build or deployment / reproduction checks: pending
- Tutor feedback, remaining blockers and next goal: pending review

## Class week of 3 December 2026: final tutor delivery review

Goal: rehearse the experience, check setup/access/credits and identify final fixes.

- Owners / demonstration / final run evidence: pending
- Tutor feedback and final fixes with owners: pending review

## 6 December 2026: final submission

This is the final Canvas deadline, not a tutor meeting.

- Final repository and README access: not yet checked for submission
- Runnable delivery and instructions: pending implementation
- Credits, weekly evidence and team contributions: keep updated
- Canvas group submission: not yet verified

Record actual results after each review. Plans, template cards and automated checks must not be presented as completed user trials or tutor feedback.
