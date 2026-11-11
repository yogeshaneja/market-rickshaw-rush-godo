# Executed checks and pending evidence

Actual editor/runtime: Godot **4.6.3.stable.official.7d41c59c4**, Compatibility renderer configured, GDScript. Headless editor import and project launch succeeded. `python tools/check.py` imports the actual project and executes both suites, detecting script errors even if Godot exits with code zero.

- **90,687 runner checks passed**: lane boundaries/cooldown, deterministic seeds, 30,000 safe rows across 300 seed/difficulty combinations, no full barriers, corridor play for 300 simulated seconds on each difficulty, speed/memory caps, pause/countdown/background-state scoring, idempotent collisions, one-time token collection, 30/60/120 render-cadence fixed-step equivalence, malformed-save recovery, reset retention, real unique-test-file save/reload/overwrite and bilingual string coverage.
- **18 headless UI/store checks passed**: actual main-scene instantiation; menu construction, Hindi setting and font code-point coverage; input mappings; start/pause/resume/focus-loss state changes; collision→results/save; offline license view; unpublished store gating, Android URL fallback and error containment. This invokes actual scene methods, not physical taps or pixel inspection.
- Engine and third-party notices extracted from the actual engine binary. Font bytes retain OFL license/copyright and a SHA-256 record.

Desktop UI attempt: Godot Project Manager opened, but desktop automation could not reliably focus/type the project path. A rendered gameplay review did not complete. No gameplay screenshot, visual quality result, actual keyboard/swipe test, Hindi shaping review or measured FPS claim is made.

Not executed: native Android export, signed APK/AAB, phone deployment/ADB pairing, physical touch, TalkBack, device restart/backup behavior, standalone airplane-mode play, device frame pacing/memory/heat, current Play declaration review, independent Hindi/editorial review and human gameplay balancing. Font code-point coverage alone is not proof of correct Devanagari shaping.

No model/cloud call, downloaded character art, sound, plugin, CI workflow, signing secret, merge or publication was introduced. The owner explicitly approved the initial README-only default-branch commit; implementation is isolated on a feature branch for PR review.

## Illustrated market update

Seven original bundled SVG illustrations replace the simple stall, rickshaw, car and cart shapes. Road edging, festival pennants, gold coins, a home-screen vehicle illustration and a speed dial enrich the presentation. Rickshaw lean and wheel motion respect Reduce Effects. Simulation geometry, spawning, scoring and input rules are unchanged.

Validation: Godot 4.6.3 headless import and existing simulation/UI suites pass (90,687 simulation checks and 18 UI/store checks). New SVG imports load through actual Godot preloads. This does not verify rendered Android appearance, frame rate or physical touch. Phone visual review and a fresh local debug deployment remain required. No Android APK/AAB was built in this workspace.

## Market life and flying decorations

Added original bundled tea-stall, tree, umbrella and kite SVG illustrations. A lightweight native CanvasItem drawing helper adds steam, garlands, two swaying kites, three flapping birds and at most eight dust puffs. Flying decorations are drawn before hazards and never enter the collision simulation or its RNG. Kites stay over pavement; birds cross the upper scene. All extra motion freezes during pause, resume countdown and results. Reduce Effects supplies static ambient alternatives and hides dust. No new dependencies, network requests or emitter nodes.

Validation: Godot import, 90,687 simulation checks and 23 UI/store checks, including new pause/countdown/results and reduced-motion clock checks. SVG raster review covers asset loading, not Android gameplay screenshots. Physical-phone performance/readability review and export remain pending.

## Animal obstacles and circus scenery

Three new obstacle kinds (elephant, monkey, snake) share the existing blocked-lane collision rules, conservative danger depth and reachable safe corridor. Original bundled SVGs remain within a single-lane visual envelope; gold ground rings identify small animals as obstacles. Collisions end the run with no injury animation. Animal ear/tail details use the existing frozen-on-pause decorative clock and respect Reduce Effects. Circus tents and flags stay on the pavement and have no collision. The expanded obstacle-kind range changes generated run layouts compared with older builds, but replay is deterministic within this version.

Validation: Godot 4.6.3 import; 90,731 simulation checks and 23 UI/store checks passed. All seven obstacle types occur across the 30,000-row seeded sample. Additional tests check animal collision once, pause and an unobstructed safe lane on all three difficulties. The original art was rasterized by Godot and visually inspected as a contact sheet. Full rendered gameplay, physical-phone readability/performance and Android export remain pending.
