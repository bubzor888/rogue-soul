## MODIFIED Requirements

### Requirement: [LLD-FLOOR-PATT-002] No Guaranteed Rest Room
There SHALL be no guaranteed rest or recovery room on Floor 3 unless the player chooses the elite combat door at room 5 (see `LLD-FLOOR-BEATS-006`). Outside that path, healing is only available if the player encounters a Wandering Soul through normal generation. Resource management across the full floor is the intended pressure.

#### Scenario: No forced recovery on standard path
- **WHEN** Floor 3 is generated and the player takes the standard combat door at room 5
- **THEN** no rest or mending room is inserted at any position; healing depends on what room types the player encounters

#### Scenario: Rest room locked behind elite choice
- **WHEN** the player wants a rest room on Floor 3
- **THEN** the only way to get one is to take the elite combat door at room 5

---

### Requirement: [LLD-FLOOR-PATT-003] Non-Combat Encounter Caps
Non-combat encounter types SHALL be capped per floor segment (pre-elite and post-elite) to shape pacing:

| Encounter type | Pre-elite cap | Post-elite cap | Floor total |
|---|---|---|---|
| Standard combat | 2–3 | 1–2 | Max 5 |
| Memory Fragment | 1–2 | 1–2 | Max 3 |
| Wandering Soul | 0–1 | Exactly 1 | 1–2 |

Once an encounter type reaches its cap for a segment, it is removed from the generation pool for that segment. The Temporary Companion encounter is a forced beat (see `LLD-FLOOR-BEATS-003`) and is not drawn from the generation pool. The standard combat door option at room 5 counts toward the floor total but not toward either segment bucket.

#### Scenario: Memory Fragment cap reached
- **WHEN** the player has completed 2 Memory Fragments in the pre-elite phase
- **THEN** no further Memory Fragment doors appear in the pre-elite phase

#### Scenario: Standard combat cap reached pre-elite
- **WHEN** the player has completed 3 standard combats in the pre-elite phase
- **THEN** no further standard combat doors appear in the pre-elite phase

---

### Requirement: [LLD-FLOOR-BEATS-004] Beat 4 — Elite Gate (Room 5)
Room 5 SHALL always present the Elite Gate: one door shows an elite combat encounter; the other shows a standard combat encounter. This is a forced structural beat at the floor midpoint — not drawn from the general pool.

Choosing the **standard combat** door: counts toward the floor's overall standard combat total (see `LLD-FLOOR-PATT-003`) but does not belong to the pre-elite or post-elite segment buckets. No rest room follows.

Choosing the **elite combat** door: triggers a guaranteed rest encounter at room 6 (see `LLD-FLOOR-BEATS-006`) — the only rest room on the floor.

Full elite combat design in `lld-elite-gate`.

#### Scenario: Elite Gate always at room 5
- **WHEN** the player completes room 4
- **THEN** room 5 always presents elite combat vs standard combat; no other room type can appear at this position

#### Scenario: Standard combat door counts toward floor total
- **WHEN** the player chooses the standard combat door at room 5 and completes it
- **THEN** the floor's standard combat count increments; it does not count toward the pre-elite or post-elite segment caps

#### Scenario: Elite choice unlocks rest room
- **WHEN** the player chooses the elite combat door at room 5
- **THEN** room 6 becomes a rest encounter (see `LLD-FLOOR-BEATS-006`)
