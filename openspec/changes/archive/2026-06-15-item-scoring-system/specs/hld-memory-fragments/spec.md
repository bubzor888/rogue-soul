## MODIFIED Requirements

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
