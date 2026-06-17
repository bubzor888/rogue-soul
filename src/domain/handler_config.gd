# @Spec: LLD-ARCH-018, LLD-ARCH-006
#
# HandlerConfig — one link in an ability/intent/omen handler chain. An ordered
# Array[HandlerConfig] is executed left-to-right by the AbilityPipeline; each
# handler_id must resolve in the AbilityRegistry at startup (LLD-ARCH-012).
# Pure data Resource (Domain layer): no Node, JSON-serialisable fields only.
class_name HandlerConfig
extends Resource

## Snake_case handler id; must resolve in AbilityRegistry at startup.
@export var handler_id: String = ""

## Handler-specific parameters, e.g. { "base_damage": 6, "damage_type": "physical" }.
@export var params: Dictionary = {}
