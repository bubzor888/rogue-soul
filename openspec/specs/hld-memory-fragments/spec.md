## Purpose
Defines the Memory Fragment room system — the single-symbol door rule, the three-category weighted draw mechanic, and the structure of each category (fair trade, companion encounter, unfair trade).
## Requirements
### Requirement: [HLD-MF-001] Memory Fragment Door Symbol
Memory Fragment rooms SHALL use a single consistent door symbol regardless of which outcome category awaits inside. The symbol communicates room type only — not the category or content of the fragment. Player knowledge of what fragments contain is built through repeated play.

#### Scenario: Symbol consistency
- **WHEN** the player sees a Memory Fragment door
- **THEN** the symbol is always the same glyph, regardless of whether the outcome is Category A, Companion Encounter, or Category C

### Requirement: [HLD-MF-002] Three-Category Weighted Draw
Memory Fragment outcomes SHALL be drawn from three categories on room entry. The draw is random and not disclosed to the player before entry. Each category has a floor-specific weight defined in the corresponding LLD spec.

The three categories are:
- **Category A** — Fair Trade (see HLD-MF-003)
- **Companion Encounter** — Companion Gateway (see HLD-MF-004)
- **Category C** — Unfair Trade (see HLD-MF-005)

#### Scenario: Random category on entry
- **WHEN** a player enters a Memory Fragment room
- **THEN** the outcome category is drawn randomly using the floor's configured weights; the category is not disclosed before entry

---

### Requirement: [HLD-MF-003] Category A — Fair Trade
Category A SHALL present the player with a fully-revealed fair trade and the option to walk away. Both options are disclosed before the player commits.

**Option 1 — Take the deal:** Pay the cost, receive the reward. Cost and reward are at rough tier parity.
**Option 2 — Walk away:** No cost, no reward.

Valid cost/reward types (any combination): HP (at fair value), a main item (same or adjacent tier), a consumable (same or adjacent tier). All costs and rewards for a given scenario are fixed — the same scenario always presents the same trade.

#### Scenario: Fair trade accepted
- **WHEN** the player chooses Option 1 in a Category A fragment
- **THEN** the specified cost is paid and the specified reward is received

#### Scenario: Walk away
- **WHEN** the player chooses Option 2 in a Category A fragment
- **THEN** nothing is gained or lost; the player exits with their inventory unchanged

---

### Requirement: [HLD-MF-004] Companion Encounter
Companion Encounter fragments SHALL present a temporary companion offer. The companion is introduced through flavour text only — no passive effect or omen card is disclosed before acceptance.

If the player already has a temporary companion, they MUST choose between keeping their current companion or accepting the one from the fragment. The unchosen companion departs. Both are presented through flavour text only — the player chooses between two unknowns unless they have previously travelled with one.

Companion Encounter fragments may also hint at locked vessels — surfacing memories of lives the soul has not yet unlocked. These hints do not name or explain the unplayed vessel; they make them feel present and real.

#### Scenario: Companion offered with no current companion
- **WHEN** a Companion Encounter fragment occurs and the player has no temporary companion
- **THEN** the player is offered one companion via flavour text and may accept or decline

#### Scenario: Companion swap choice
- **WHEN** a Companion Encounter fragment occurs and the player already has a temporary companion
- **THEN** the player chooses between their current companion and the new one; the unchosen departs

---

### Requirement: [HLD-MF-005] Category C — Unfair Trade
Category C SHALL present two options, both of which cost something. Walking away is NOT an option — the fragment has already taken hold. The player must choose between a bad deal and cutting their losses.

**Option 1 — Take the bad deal:** Receive something, but pay more than it is worth by the tier system's standards. The reward is real; the price is deliberately above fair value.
**Option 2 — Cut your losses:** Lose something outright, receive nothing.

The choice MUST never be obvious. Option 2 must be genuinely tempting — if Option 1's cost exceeds what Option 2 takes, cutting losses is the correct play.

Valid cost/reward types (any combination on either option): HP, a main item, a consumable. No artificial pairing constraints.

#### Scenario: Both options have a cost
- **WHEN** a Category C fragment occurs
- **THEN** there is no option with zero cost; both Option 1 and Option 2 require the player to give something up

#### Scenario: Option 2 is genuinely tempting
- **WHEN** a Category C fragment offers Option 1 at an unfair price
- **THEN** Option 2's cost MUST be lower than Option 1's price, making it a real strategic choice

