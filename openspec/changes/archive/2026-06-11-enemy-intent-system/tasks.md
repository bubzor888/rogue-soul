## 1. HLD Combat System Updates

- [x] 1.1 Apply MODIFIED `HLD-COMBAT-009` — expand Enemy Intent requirement with weighted selection, trigger override, consecutive limiting, and non-attack display language
- [x] 1.2 Apply ADDED `HLD-COMBAT-014` — add Charge→Release multi-turn intent pattern requirement
- [x] 1.3 Apply ADDED `HLD-COMBAT-015` — add Chilled idempotency requirement
- [x] 1.4 Apply ADDED `HLD-COMBAT-016` — add enemy damage variance / player damage flat asymmetry requirement

## 2. Technical Architecture Updates

- [x] 2.1 Apply MODIFIED `LLD-ARCH-017` — add `last_intent_id`, `intent_streak`, and `is_charging` fields to `EnemyState`
- [x] 2.2 Apply MODIFIED `LLD-ARCH-018` — remove `base_damage` from `EnemyData`; expand `IntentWeight` with `intent_id`, `damage_min`, `damage_max`, `is_charge_release`, `max_consecutive`, `status_apply`; update `IntentConditional.intent_type` → `intent_id`
- [x] 2.3 Apply MODIFIED `LLD-ARCH-019` — update `resolve_enemy_turns` with streak re-roll steps and enemy damage variance roll; update damage resolution order step 1 to distinguish player (flat) vs enemy (range) damage

## 3. Enemy Intent Tables

- [x] 3.1 Apply MODIFIED `LLD-ENEMIES-004` — add Skeleton intent table (Strike 4–6 / Chill Touch), update kill references to turn ranges, add intent scenarios
- [x] 3.2 Apply MODIFIED `LLD-ENEMIES-005` — add Zombie intent table (Swipe 2–4 / Slam 5–7 / Shamble), update kill references, add intent scenarios
