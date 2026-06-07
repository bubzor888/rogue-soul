## ADDED Requirements

### Requirement: [LLD-ARCH-012] Handler Naming Convention
Handler class names SHALL be PascalCase with the suffix `Handler`. Their registered `handler_id` SHALL be snake_case matching the class name without the suffix. See `LLD-ARCH-005` for the AbilityPipeline architecture that consumes these handlers.

Example: `DealDamageHandler` → `"deal_damage"`, `ApplyStatusHandler` → `"apply_status"`

#### Scenario: Naming consistency
- **WHEN** a new handler is implemented
- **THEN** its class name is PascalCase ending in `Handler` and its registered handler_id is the snake_case equivalent; startup validation (per `LLD-ARCH-005`) fails if the ID is unregistered
