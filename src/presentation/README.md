# src/presentation/ — the UI layer (MVP2)

Four-layer rule: this layer may depend on all others; nothing depends on it.
ScreenManager (Application) switches screens by RESOURCE-PATH STRING only — never import a screen type
into Application.

## Target: mobile-first portrait, web export first (LLD-PLATFORM-001, LLD-PLATFORM-005)
Primary release is MOBILE, shipped first as a WEB export; a native iOS/Android or desktop port is a
potential second target (TBD). Single portrait layout (390×844, touch-first) is the ONLY layout — there
is no separate desktop variant. The engine needs no rewrite for a second-target port: PersistenceService
(LLD-ARCH-007) and abstract input (LLD-PLATFORM-002) already isolate platform specifics from Domain/
Application.
