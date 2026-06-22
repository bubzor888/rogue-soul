# @Spec: LLD-ARCH-007, LLD-ARCH-002, LLD-ARCH-010, LLD-ARCH-014
#
# GameConfig — Infrastructure autoload holding environment flags and global
# constants. Pure data: no logic, no state mutation, no scene-tree work.
#
# Registered as an autoload in project.godot, so the global `GameConfig` is
# available everywhere. (Intentionally no `class_name` — the autoload already
# creates the `GameConfig` global; a matching class_name would collide with it.)
#
# Layer note (LLD-ARCH-002): `HEADLESS` is a *presentation* concern. Only
# Presentation nodes may read it (to `queue_free()` themselves when headless).
# Domain and Application code MUST NOT reference `HEADLESS`.
extends Node

## Environment flags ----------------------------------------------------------

# @Spec: LLD-ARCH-002
# True ⇒ no rendering/input; the AIPlayerAgent drives a full run with no scene
# tree (MVP1 is headless-only). Presentation nodes self-disable on this flag.
const HEADLESS: bool = true

# @Spec: LLD-ARCH-014
# The single switch for all debug UI and debug code paths. No separate debug
# build exists — every build ships the debug tooling gated behind this flag.
const DEBUG: bool = false

## Save / persistence ---------------------------------------------------------

# @Spec: LLD-ARCH-010
# Stamped into every save file by PersistenceService. A loaded save with a lower
# version triggers the migration path. Bump on any breaking save-schema change.
const SAVE_VERSION: int = 1
