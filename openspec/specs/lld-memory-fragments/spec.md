
### Requirement: [LLD-MF-001] Memory Fragment Door Symbol
The Memory Fragment room SHALL have a single consistent door symbol regardless of which outcome category awaits inside. The symbol communicates room type only — not what kind of fragment it will be. Player knowledge of what fragments contain is built through play.

#### Scenario: Symbol consistency
- **WHEN** the player sees a Memory Fragment door
- **THEN** the symbol is always the same glyph, regardless of whether the outcome is Category A, B, or C

---

### Requirement: [LLD-MF-002] Outcome Category Draw
The outcome category SHALL be drawn randomly on entry. The player does not know which category they are entering. Pool weighting: **40% Category A / 40% Category B / 20% Category C**.

`[OPEN]` Category B (companion gateway) weighting to be tuned if the Worn Map companion encounter makes companion offers too frequent on the floor.

#### Scenario: Random category on entry
- **WHEN** a player enters a Memory Fragment room
- **THEN** the outcome category is determined randomly using the confirmed pool weights; it is not disclosed before entry

---

### Requirement: [LLD-MF-003] Category A — Fair Trade (Optional)
Category A SHALL present the player with a fully-revealed fair trade and the option to walk away. Both options are shown before the player commits.

**Option 1 — Take the deal:** Pay the cost, receive the reward. Cost and reward are at rough tier parity.
**Option 2 — Walk away:** No cost, no reward.

**Valid cost/reward types (any combination):** HP (at fair value), a main item (same or adjacent tier), a consumable (same or adjacent tier).

All costs and rewards are fixed per scenario. The same scenario always presents the same trade.

#### Scenario: Fair trade accepted
- **WHEN** the player chooses Option 1 in a Category A fragment
- **THEN** the specified cost is paid and the specified reward is received

#### Scenario: Walk away
- **WHEN** the player chooses Option 2 in a Category A fragment
- **THEN** nothing is gained or lost; the player exits the room with their inventory unchanged

---

### Requirement: [LLD-MF-004] Category B — Companion Gateway
Category B SHALL present a temporary companion offer from the fragment. The companion is presented through flavour text only — no passive effect or omen card is disclosed before acceptance.

If the player already has a temporary companion, they MUST choose between keeping their current companion or accepting the one from the fragment. The unchosen companion departs. Both are presented through flavour text only — the player chooses between two unknowns unless they have travelled with one before.

Category B fragments may also hint at locked vessels — surfacing memories of lives the soul has not yet unlocked. These hints do not name or explain the unplayed vessel; they make them feel real and present.

`[OPEN]` Temporary companion pool for Floor 3 (identities, passives, omen cards) to be defined in a companion design session.

#### Scenario: Companion offered with no current companion
- **WHEN** a Category B fragment occurs and the player has no temporary companion
- **THEN** the player is offered one companion via flavour text and may accept or decline

#### Scenario: Companion swap choice
- **WHEN** a Category B fragment occurs and the player already has a temporary companion
- **THEN** the player chooses between their current companion and the new one; the unchosen departs

---

### Requirement: [LLD-MF-005] Category C — Unfair Trade (Mandatory)
Category C SHALL present two options, both of which cost something. Walking away is NOT an option — the fragment has already taken hold. The player must choose between a bad deal and cutting their losses.

**Option 1 — Take the bad deal:** Receive something, but pay more than it is worth by the tier system's standards. The reward is real; the price is deliberately above fair value.
**Option 2 — Cut your losses:** Lose something outright, receive nothing.

The choice MUST never be obvious. Option 2 must be genuinely tempting — if the bad deal's cost is higher than what Option 2 takes, cutting losses is the correct play.

**Valid cost/reward types (any combination on either option):** HP, a main item, a consumable. No artificial pairing constraints.

**Examples of valid Category C structures:**
- Option 1: Pay 8 HP for a consumable worth 5 HP / Option 2: Lose 4 HP for nothing
- Option 1: Give up a Tier 2 consumable for a Tier 1 consumable / Option 2: Lose a Tier 1 consumable outright
- Option 1: Pay HP well above fair value for a Tier 1 item / Option 2: Lose a consumable for nothing

#### Scenario: Both options have a cost
- **WHEN** a Category C fragment occurs
- **THEN** there is no option with zero cost; both Option 1 and Option 2 require the player to give something up

#### Scenario: Option 2 is genuinely tempting
- **WHEN** a Category C fragment offers Option 1 at an unfair price
- **THEN** Option 2's cost MUST be lower than Option 1's price, making it a real strategic choice

---

### Requirement: [LLD-MF-006] Memory Fragment Scenario Pool
`[OPEN]` 8–10 distinct mechanical scenarios for Floor 3, distributed across Categories A and C (recommended: 4 A / 2 C as first pass; remaining slots filled by Category B companion gateway). Narrative content (flavour text, locked vessel hints) deferred to floor-specific writing sessions.

#### Scenario: [OPEN] Scenario pool design
- **WHEN** Memory Fragment scenarios are written for Floor 3
- **THEN** each scenario specifies: category, both options, exact costs/rewards, which locked vessel (if any) it hints at
