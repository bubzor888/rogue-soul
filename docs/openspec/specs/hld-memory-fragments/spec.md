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

**Option 1 — Take the deal:** Pay the cost, receive the reward. Cost and reward are within the score tolerance window (see `LLD-IR-010` and `HLD-ITEMS-009`).
**Option 2 — Walk away:** No cost, no reward.

Valid cost/reward types (any combination): HP (at fair value), a main item (within score tolerance), a consumable (within score tolerance). All costs and rewards for a given scenario are fixed — the same scenario always presents the same trade.

#### Scenario: Fair trade accepted
- **WHEN** the player chooses Option 1 in a Category A fragment
- **THEN** the specified cost is paid and the specified reward is received

#### Scenario: Walk away
- **WHEN** the player chooses Option 2 in a Category A fragment
- **THEN** nothing is gained or lost; the player exits with their inventory unchanged

---

### Requirement: [HLD-MF-004] Companion Encounter
Companion Encounter fragments SHALL present a temporary companion offer. The companion is introduced through flavour text only — no passive effect, granted ability, or omen card contribution is disclosed before acceptance. The player chooses based on flavour text alone (or prior run knowledge).

**Companion encounters are mandatory.** There is no option to walk away. When a Companion Encounter fragment fires, the companion is accepted.

**One companion encounter per floor.** Once a companion encounter has been offered — whether from a Memory Fragment draw or from a starting item beat (e.g. Worn Map, see `LLD-FLOOR-BEATS-003`) — the Companion Encounter category is removed from the Memory Fragment pool for the remainder of that floor. A player cannot receive more than one companion offer per floor. This guarantee holds by construction: while the player holds an unfired Worn Map, Memory Fragment generation excludes the Companion Encounter category outright (see `LLD-FLOOR-BEATS-003`), so a companion encounter can never fire while another companion offer is still pending.

Companion Encounter fragments may also hint at locked vessels — surfacing memories of lives the soul has not yet unlocked. These hints do not name or explain the unplayed vessel; they make them feel present and real.

#### Scenario: Companion encounter is mandatory
- **WHEN** a Memory Fragment draws the Companion Encounter category
- **THEN** the player must accept the companion; there is no option to decline or walk away

#### Scenario: One companion encounter per floor
- **WHEN** a companion encounter has already been offered this floor (via any source)
- **THEN** subsequent Memory Fragment draws exclude the Companion Encounter category for the rest of that floor

---

### Requirement: [HLD-MF-005] Category C — Unfair Trade
Category C SHALL present two options, both of which cost something. Walking away is NOT an option — the fragment has already taken hold. The player must choose between a bad deal and cutting their losses.

**Option 1 — Take the bad deal:** Receive something, but pay significantly more than it is worth by the scoring system's standards. The reward is real; the price is deliberately above fair value. Option 1's cost SHALL exceed the reward's score by at least 50% above the fair tolerance window (see `LLD-IR-010`).
**Option 2 — Cut your losses:** Lose something outright, receive nothing.

The choice MUST never be obvious. Option 2 must be genuinely tempting — if Option 1's cost exceeds what Option 2 takes, cutting losses is the correct play.

Valid cost/reward types (any combination on either option): HP, a main item, a consumable. No artificial pairing constraints.

#### Scenario: Both options have a cost
- **WHEN** a Category C fragment occurs
- **THEN** there is no option with zero cost; both Option 1 and Option 2 require the player to give something up

#### Scenario: Option 2 is genuinely tempting
- **WHEN** a Category C fragment offers Option 1 at an unfair price
- **THEN** Option 2's cost MUST be lower than Option 1's price, making it a real strategic choice

