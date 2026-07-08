# MVP2 Placeholder Art Asset Checklist

Derived from `docs/openspec/specs/ui-art-assets/spec.md` cross-referenced with
`lld-enemies`, `lld-companions`, `lld-vessels`, and `hld-combat-system` to resolve
the concrete instances the spec's categories require for the MVP2 Pilgrim /
Floor 3 run.

Placeholder convention (to be confirmed before populating): flat-shaded box in a
category colour + short label text, sized exactly to spec, transparent PNG,
`res://assets/art/...` path per `UI-ART-007`.

## 1. Damage type icons — 32×32
`res://assets/art/icons/dmg/`

- [x] `icon_dmg_physical.png` — "P", black solid bg, white text
- [x] `icon_dmg_fire.png` — "R", red solid bg, white text
- [x] `icon_dmg_lightning.png` — "L", yellow solid bg, black text
- [x] `icon_dmg_ice.png` — "I", blue solid bg, white text

## 2. Status effect icons — 16×16
`res://assets/art/icons/status/`

Spec's minimum list, plus the full status roster in `HLD-COMBAT-006` that
actually triggers in Floor 3 encounters (Exposed, Bleed, Type Convert,
Frenzied aren't in the spec's "at minimum" list but are used by Fire/Ice
Elementals, the Judge, and the Witnesses).

Style: white bg, colored 2-letter code (4-letter codes were tried first but
turn to mush at true 16×16 — see git history of this file for the abandoned
attempt).

- [x] `icon_status_burning.png` — "BN", red
- [x] `icon_status_poisoned.png` — "PS", green
- [x] `icon_status_chilled.png` — "CH", blue
- [x] `icon_status_shocked.png` — "SK", yellow
- [x] `icon_status_vulnerable.png` — "VL", pink
- [x] `icon_status_hardened.png` — "HD", black
- [x] `icon_status_mending.png` — "MD", green
- [x] `icon_status_emboldened.png` — "EB", blue
- [x] `icon_status_exposed.png` (Judge/Witness kits — shift-triggered Vulnerable) — "EX", purple
- [x] `icon_status_bleed.png` (Judge Suffer) — "BL", red
- [x] `icon_status_type_convert_physical.png` (Elemental Synergy omen cards) — "TY", black — split into 4 per-type files, matching `icon_dmg_*` colors exactly
- [x] `icon_status_type_convert_fire.png` — "TY", red
- [x] `icon_status_type_convert_lightning.png` — "TY", yellow
- [x] `icon_status_type_convert_ice.png` — "TY", blue
- [x] `icon_status_frenzied.png` (Bear Frenzy; Witness of Vengeance death effect) — "FZ", red
- [x] `icon_status_fortified.png` — `[OPEN·MVP3]`, deferred. Gated behind the Hedge Knight's Iron Pendant (`LLD-OMEN-CARD-007`), which can't appear in a Pilgrim-only MVP2 run. Built anyway for completeness — "FT", black.

## 3. Intent icons — 32×32
`res://assets/art/icons/intent/`

Generic categories per spec (not per-enemy):

Style: white bg, black text (no color-coding — kept distinct from the status
icon palette).

- [x] `icon_intent_attack.png` — "Atk"
- [x] `icon_intent_heavy_attack.png` — "Hvy"
- [x] `icon_intent_multi_hit.png` — "Mlt"
- [x] `icon_intent_defend.png` — "Def"
- [x] `icon_intent_charge.png` — "Chg"
- [x] `icon_intent_status.png` — "Sta"

## 4. Enemy sprites — normal, 32×32
`res://assets/art/characters/enemies/`

Floor 3 Normal Enemies table (`LLD-ENEMIES-002`):

- [x] `enemy_skeleton.png` (Undead) — "Skele"
- [x] `enemy_zombie.png` (Undead) — "Zomb"
- [x] `enemy_plague_rat.png` (Beast) — "Plague / Rat"
- [x] `enemy_wolf.png` (Beast) — "Wolf"
- [x] `enemy_fire_elemental.png` (Elemental) — "Fire / Elem"
- [x] `enemy_ice_elemental.png` (Elemental) — "Ice / Elem"
- [x] `enemy_low_hp_fanatic.png` (Fanatic — design-reference name, per spec `[OPEN·MVP3]`/`[OPEN·MVP2]` naming note) — "Fanatic"
- [x] `enemy_high_hp_fanatic.png` (Fanatic) — "Fanatic" (identical placeholder to Low HP Fanatic)

## 5. Enemy sprites — elite, 48×48
`res://assets/art/characters/enemies/`

Floor 3 Elite Enemies table (`LLD-ENEMIES-002`):

- [x] `enemy_bear.png` (Beast elite) — "Bear", dark purple bg
- [x] `enemy_lightning_elemental.png` (Elemental elite, Phase 1) — "Lightning / Elem", dark purple bg
- [x] `enemy_lightning_spark.png` — 32×32, normal size (Phase 2 split of the elite) — "Spark", dark purple bg (kept elite coloring since it's the elite's split)

## 6. Boss + boss-adjacent sprites

Spec doesn't define a distinct "boss" size tier — using elite size (48×48)
for the Judge since it's the largest threat on the floor. Witnesses are
normal size.

- [x] `enemy_the_judge.png` — 48×48 (boss, `LLD-ENEMIES-010`) — "Judge", dark purple bg
- [x] `enemy_witness_of_mercy.png` — 32×32 (`LLD-ENEMIES-021`, normal-size support entity, HP 10) — "Wit / Mercy", red bg
- [x] `enemy_witness_of_vengeance.png` — 32×32 (`LLD-ENEMIES-022`, normal-size support entity, HP 10) — "Wit / Venge", red bg

## 7. Vessel sprite — 48×48
`res://assets/art/characters/vessels/`

MVP2 scope is Pilgrim only (Drifter/Hedge Knight are MVP3):

- [x] `vessel_pilgrim.png` — "Pilgrim", blue bg

## 8. Companion sprites — 32×32
`res://assets/art/characters/companions/`

Floor 3 temporary companion pool (`LLD-MF-009`) — available to any vessel
including the Pilgrim, so in scope for MVP2:

- [x] `companion_raven.png` — "Raven", green bg
- [x] `companion_shadow.png` — "Shad", green bg
- [x] `companion_life_mote.png` — "Life / Mote", green bg

## 9. Loot screen placeholder — 200×80
`res://assets/art/ui/loot/`

- [x] `loot_reward_placeholder.png` (single shared image, category-agnostic per `UI-LOOT-003`) — gray box, "LOOT"

## Explicitly out of scope for MVP2

Not building placeholders for these — they're `[OPEN·MVP3]` or later:

- Buff Totem / Absorption Totem (`LLD-ENEMIES-019`, `-020`, Fanatic support entities)
- Drifter, Hedge Knight vessels
- Fortified status icon is tracked in section 2 but not needed until Hedge Knight ships

## Totals

| Category | Count |
|---|---|
| Damage type icons | 4 |
| Status icons | 16 (Type Convert split into 4 per-type files) |
| Intent icons | 6 |
| Normal enemy sprites | 8 |
| Elite enemy sprites | 3 |
| Boss/boss-adjacent sprites | 3 |
| Vessel sprites | 1 |
| Companion sprites | 3 |
| Loot placeholder | 1 |
| **Total assets** | **45** |
