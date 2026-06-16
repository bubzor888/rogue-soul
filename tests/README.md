# `tests/` — GdUnit4 Test Suites

Soul Protocol's test suites run on **GdUnit4 v6.1.3** (installed at `addons/gdUnit4/`), which
matches Godot **4.6.x** (`LLD-ARCH-015`). Suites live here as `test_*.gd` extending
`GdUnitTestSuite`. The five mandated core systems (RNG, CombatResolver, EventLog, GameState
serialiser, ActionInjector) are TDD — write the test here first, then the implementation.

## Running headless (the canonical command)

GdUnit4 ships a runner at `addons/gdUnit4/bin/GdUnitCmdTool.gd`. The verified headless invocation:

```bash
# From the project root. Replace the binary path with your Godot 4.6.x executable.
"<godot-4.6-binary>" --headless --path . \
  -d --remote-debug tcp://127.0.0.1:0 \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  --ignoreHeadlessMode \
  -a res://tests
```

On this machine, use the **console** build for command-line runs:
`C:\Program Files\GoDot\Godot_v4.6.3-stable_win64_console.exe`

> Windows ships two binaries. The plain `…win64.exe` is built with the GUI subsystem and won't
> attach its stdout to an interactive terminal; the `…win64_console.exe` wrapper attaches to the
> console and forwards output. For headless/CLI/CI use, prefer the `_console` build. (Output is
> still captured fine when stdout is piped/redirected either way.)

Exit code `0` = all green. JUnit XML is written to `reports/report_<n>/results.xml` (plus an HTML
report alongside it). `reports/` is git-ignored.

### Why each flag

| Flag | Reason |
|---|---|
| `--headless` | No window — server/CI mode (`--display-driver headless --audio-driver Dummy`). |
| `--path .` | Run against this project. |
| `-d --remote-debug tcp://127.0.0.1:0` | `-d` (debug) is needed for correct exit codes/asserts. The unbindable port 0 refuses the debugger connection instead of dropping Godot into an interactive `debug>` loop on a parse error. The "remote port must be between 1 and 65535" line is the guard working as intended — harmless. |
| `-s …/GdUnitCmdTool.gd` | Run GdUnit4's command-line runner script. |
| `--ignoreHeadlessMode` | GdUnit4 refuses headless by default (exit 103) because UI `InputEvent` tests don't work without a window. Our suites are pure logic, so we opt out. **Do not** add UI-input tests to the headless suite. |
| `-a res://tests` | Add this directory as the test source. |

### Convenience: GdUnit4's own wrapper

`addons/gdUnit4/runtest.cmd` (Windows) / `runtest.sh` (Unix) wrap the above. Point them at the
binary with `--godot_binary "<path>"` or the `GODOT_BIN` env var. Note the wrappers run **windowed**
by default; the explicit command above is the headless one used for CI/determinism gates.

## First-time setup note (already done for this repo)

Adding the addon requires Godot to build its global class cache once, or `class_name`s like
`GdUnitTestCIRunner` won't resolve. If you ever see *"Could not find type GdUnitTestCIRunner"*,
rebuild the cache headlessly:

```bash
"<godot-4.6-binary>" --headless --import --path .
```

The plugin is enabled in `project.godot` under `[editor_plugins]`.

## Sample test

`test_sample.gd` is a trivial smoke test proving the runner works (T0.2). It can be deleted once
the first real suite (`test_rng.gd`, T1.1) lands.
