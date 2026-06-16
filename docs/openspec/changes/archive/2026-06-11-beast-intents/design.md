## Context

Three beast intent tables are tagged `[OPEN·MVP1]` in lld-enemies: Plague Rat, Wolf, and Bear. Filling them in is straightforward for the Rat (70/30 bite/evade) but requires two schema extensions for Wolf and Bear. The current `IntentConditional` can only force a single specific intent; Wolf needs two different 50/50 probability distributions depending on pack size. Wolf's Howl summon has no representation in `IntentWeight` at all. Bear's Swipe is a two-hit intent; the schema has no `hit_count` concept.

## Goals / Non-Goals

**Goals:**
- Full intent definitions for Plague Rat, Wolf, and Bear
- Minimal targeted schema additions to `IntentConditional` and `IntentWeight` that cover these three cases
- Omen deck injection on mid-combat wolf summon, consistent with HLD-OMEN-006 Tier 1

**Non-Goals:**
- Overhauling the intent system for hypothetical future cases
- Adding a `unit_spawned` signal to LLD-ARCH-009 SignalBus (deferred to a future architecture pass)
- Designing Fanatic, Elemental, or any non-beast enemy intents

## Decisions

### 1 — `intent_ids` pool restriction on IntentConditional

**Chosen:** Add optional `intent_ids: Array[String]` to `IntentConditional`. When non-empty, the conditional fires but instead of forcing a single intent the CombatResolver performs a weighted roll restricted to only those entries in `intent_weights`. The existing `intent_id` forced-selection path (no roll) is unchanged.

**Alternative considered:** Separate `weight_tables` keyed by condition — a richer structure that maps each condition to its own complete weight table. More expressive but duplicates weight values and adds significant schema complexity for one use case.

**Why chosen:** Wolf is the only enemy that needs pool-conditional distribution. Reusing the existing weight table with a filter avoids any duplication; wolves declare their four intents once with weights, and the conditionals simply restrict which subset is eligible per-turn.

### 2 — `summon_enemy_id: String` on IntentWeight

**Chosen:** Add a single explicit string field to `IntentWeight`. When non-empty, `resolve_enemy_turns` calls the new `resolve_enemy_summon` helper after executing the intent, which creates a fresh `EnemyState` and injects the family card.

**Alternative considered:** Routing through `AbilityPipeline` with a `spawn_enemy` handler (consistent with how abilities work). More general but introduces handler infrastructure for a single effect, and `IntentWeight` doesn't have a `handlers` field — adding it just for Howl would be a bigger change.

**Why chosen:** Wolf Howl is the only summon mechanic in MVP1–MVP2 scope. An explicit named field is self-documenting and cheap to implement. If more summon variety emerges later, a handler approach can supersede it.

### 3 — `hit_count: int` on IntentWeight

**Chosen:** Simple integer multiplier on the existing damage roll. Default 1 preserves all current behavior. When > 1, `resolve_enemy_turns` performs `hit_count` independent `[damage_min, damage_max]` rolls, each subject to evasion miss independently.

**Alternative considered:** Two separate Bear intents (`swipe_1`, `swipe_2`) chained via charge→release. This misrepresents the semantics — Swipe is one decision, two hits, not two turns — and would require the player to see a "charge" turn for what should be instant.

**Why chosen:** Swipe is conceptually one attack that lands twice. `hit_count` captures this directly without touching turn-flow logic.

### 4 — Two bite intents (`bite_pack` / `bite_lone`) for Wolf

**Chosen:** Two distinct `IntentWeight` entries with different `damage_min`/`damage_max`, each gated behind a conditional pool. Pack conditional restricts to `[bite_pack, evade]`; alone conditional restricts to `[bite_lone, howl]`.

**Alternative considered:** One `bite` intent with runtime scaling — damage conditionally varies based on current ally count at resolution time. This would require a new "pack context" lookup step in the damage pipeline.

**Why chosen:** Explicit data is clearer and testable: the data file says exactly what damage each pool delivers. No hidden runtime branching in the damage resolver.

## Risks / Trade-offs

**Wolf infinite loop risk** → Mitigation: `max_consecutive: 1` on Howl prevents a wolf from howling twice in a row (it must attack in between). The theoretical loop — last wolf howls, kill the summoned wolf, last wolf alone again, howls again — persists but requires the player to repeatedly fail to kill the lone wolf; each cycle has 50% probability. Accepted as acceptable roguelite variance.

**Summoned wolf omen deck timing** → Mitigation: family card is injected into the draw pile (not discard) immediately on spawn. If the draw pile is empty at that moment (mid-reshuffle), the injection uses the post-reshuffle draw pile. This edge case is handled by `resolve_enemy_summon` running after the current intent resolves, not during it.

## Open Questions

- Should `SignalBus` gain a `unit_spawned(enemy_id, instance_id)` signal for presentation layer feedback on Howl? Not scoped here — defer to architecture pass.
- Bear Swipe damage range (3–5 per hit) to be validated in playtesting. Currently marked `[OPEN·MVP1]`.
