# Team plan

## Proposed goal for 6 to 12 November 2026

Share any existing local project before starting parallel implementation. Connect one prescription from herb selection through grinding to delivery, then test grinding with one hand while managing another order with the mouse. See [design refinement](DESIGN-REFINEMENT.md) for scope and acceptance checks. Confirm owners and the tutor's feedback before treating this as the team's agreed commitment.

The original goal was a first working interaction for 5 November. Its delivery and review evidence remain unrecorded; this planning update does not mark that goal complete.

## Decisions to make

| Decision | Current state | Owner |
| --- | --- | --- |
| Intended user and purpose | Proposed: PC players who enjoy short time-management games and want to try hands-on preparation | Team/tutor to confirm |
| Main input, response and visible feedback | Proposed: continuous grinding with one hand while the mouse manages orders; visible material progress and order binding | Prototype owner to agree |
| Chosen platform/runtime | Original proposal tentatively selects Godot 2D; existing local work, version and camera integration need confirmation | Team to agree |
| Multimedia needed for the idea | Proposed: readable herb/tool states, grinding animation and sound, customer/order feedback; asset sources to record | Team to agree |
| Tutor and exact meeting slot | To confirm | Team to agree |
| Group member GitHub usernames | IceyHikari, MiaJiao5, deadlytomatovo, ZHANGYan-Sybil | Confirmed from supplied accounts |
| Repository Write access | 29 October snapshot: first three Admin, ZHANGYan-Sybil invitation pending; current access needs rechecking | Repository administrator / invitee |
| Team Project board | [Existing board #23](https://github.com/orgs/sd5913/projects/23), created by MiaJiao5 and linked to repository; IceyHikari can edit | Board administrators; teammates to verify access |

Do not put student numbers, emails or private meeting details in this public document.

## Scope and implementation backlog

| Task | Acceptance checks | State |
| --- | --- | --- |
| Agree audience, scope and first interaction | Record who uses it, what they do, expected response, feedback and an ordinary error; confirm with tutor | Todo |
| Confirm team access and planning board | All actual teammates can push a branch and edit the board; tutor can view; README links the team's board | In progress |
| Build the first interaction | A teammate can run the documented command/build and use the agreed interaction; attach real evidence | Backlog, depends on scope |
| Share existing work and review evidence | Link any local implementation and record the actual 5 November delivery/feedback, or record why no delivery occurred | Unverified; owner to agree |
| Test the two-hand interaction | Complete a bound grinding task while selecting a second order; pause/resume safely; show tracking status and a fallback | Proposed; owner to agree |
| Integrate a playable shift | Add customer patience, a recoverable interruption, an end state and retry after the one-order loop works | Proposed; depends on prototype |

Assign each implementation task to a real teammate before starting. The initial workflow work is being prepared at IceyHikari's request; this does not assign other team members to unagreed responsibilities.

## Board setup

[Magic Kitchen team board #23](https://github.com/orgs/sd5913/projects/23) is the existing board created by MiaJiao5 from [Group Project 2026](https://github.com/orgs/sd5913/projects/1), owned by **sd5913**. It contains all five tutor review cards, the final deadline card and the starter planning card. Those existing cards are preserved. The repository is linked, and the setup issues have been added. A temporary duplicate was created while this board was inaccessible; setup was consolidated back into #23 at the team's request.

Use the template's weekly Iteration field and views. A useful status flow is Backlog → Todo → In progress → Review → Done. Check the copied automation settings rather than assuming closed issues or merged PRs meet the Definition of Done. A Project's collaborators and repository links do not automatically come from the template.

Three repository issues are linked to the board: [scope #1](https://github.com/sd5913/forlives--magic_kitchen/issues/1), [access #2](https://github.com/sd5913/forlives--magic_kitchen/issues/2) and [first interaction #3](https://github.com/sd5913/forlives--magic_kitchen/issues/3). Scope/access belong to the first weekly iteration; implementation remains Backlog until scope is agreed. Access remains In progress pending invitation acceptance and teammate verification. The board is private; check its base access in Settings (Read or No access), and confirm tutor visibility. These settings were not assumed from repository membership.
