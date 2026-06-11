## 1. Schema Extensions — LLD-ARCH-018

- [x] 1.1 Add `hit_count: int` row to IntentWeight table in `openspec/specs/lld-technical-architecture/spec.md` (default 1; number of independent damage rolls per execution)
- [x] 1.2 Add `summon_enemy_id: String` row to IntentWeight table (empty = no summon; spawns enemy + injects Tier 1 omen card)
- [x] 1.3 Add `intent_ids: Array[String]` row to IntentConditional table and clarify mutual exclusivity with `intent_id`
- [x] 1.4 Update EnemyData `intent_conditionals` notes to mention pool-restriction behaviour when `intent_ids` is set
- [x] 1.5 Add three new scenarios to LLD-ARCH-018: intent_ids restricts pool, hit_count > 1 produces multiple rolls, summon_enemy_id spawns with omen card

## 2. CombatResolver Interface — LLD-ARCH-019

- [x] 2.1 Update `resolve_enemy_turns` step 2 in `openspec/specs/lld-technical-architecture/spec.md` to describe conditional branching: forced `intent_id` vs restricted pool via `intent_ids` vs full roll
- [x] 2.2 Update `resolve_enemy_turns` step 7 to describe `hit_count` multi-hit loop and `summon_enemy_id` post-intent spawn call
- [x] 2.3 Add `resolve_enemy_summon(enemy_id, game_state)` method signature to the CombatResolver interface block
- [x] 2.4 Add four new scenarios to LLD-ARCH-019: intent_ids wolf pack pool, intent_ids wolf alone pool, resolve_enemy_summon wolf howl, Bear Swipe two independent hits

## 3. Beast Enemy Intent Tables — LLD-ENEMIES

- [x] 3.1 Add intent table (bite 70% / evade 30%) to LLD-ENEMIES-006 Plague Rat in `openspec/specs/lld-enemies/spec.md`; add bite and evade scenarios
- [x] 3.2 Add intent table and intent conditionals to LLD-ENEMIES-007 Wolf (bite_pack/evade pack pool; bite_lone/howl alone pool; howl max_consecutive 1, summon_enemy_id wolf); add all wolf scenarios
- [x] 3.3 Add intent table and intent conditionals to LLD-ENEMIES-008 Bear (sleeping forced turn 1; bite 40%; swipe 40% hit_count 2; frenzy 20% status_target self); remove `[OPEN·MVP1]` intent stub; add all bear scenarios

## 4. Omen System — HLD-OMEN-006

- [x] 4.1 Add mid-combat summon corollary sentence to the Tier 1 paragraph in `openspec/specs/hld-omen-system/spec.md` (summon injects family card; removed on death per normal Tier 1 rules)
- [x] 4.2 Add clarifying sentence to Tier 2 paragraph: a summon of an existing type does not add a second type card
- [x] 4.3 Add two new scenarios: mid-combat summon injects family card (not type card); summoned enemy death removes its family card (and type card if last of type)
