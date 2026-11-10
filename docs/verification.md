# Executed checks and pending evidence

Actual editor/runtime: Godot **4.6.3.stable.official.7d41c59c4**, Compatibility renderer configured, GDScript. Headless editor import and project launch succeeded. `python tools/check.py` imports the actual project and executes both suites, detecting script errors even if Godot exits with code zero.

- **90,687 runner checks passed**: lane boundaries/cooldown, deterministic seeds, 30,000 safe rows across 300 seed/difficulty combinations, no full barriers, corridor play for 300 simulated seconds on each difficulty, speed/memory caps, pause/countdown/background-state scoring, idempotent collisions, one-time token collection, 30/60/120 render-cadence fixed-step equivalence, malformed-save recovery, reset retention, real unique-test-file save/reload/overwrite and bilingual string coverage.
- **18 headless UI/store checks passed**: actual main-scene instantiation; menu construction, Hindi setting and font code-point coverage; input mappings; start/pause/resume/focus-loss state changes; collision→results/save; offline license view; unpublished store gating, Android URL fallback and error containment. This invokes actual scene methods, not physical taps or pixel inspection.
- Engine and third-party notices extracted from the actual engine binary. Font bytes retain OFL license/copyright and a SHA-256 record.

Desktop UI attempt: Godot Project Manager opened, but desktop automation could not reliably focus/type the project path. A rendered gameplay review did not complete. No gameplay screenshot, visual quality result, actual keyboard/swipe test, Hindi shaping review or measured FPS claim is made.

Not executed: native Android export, signed APK/AAB, phone deployment/ADB pairing, physical touch, TalkBack, device restart/backup behavior, standalone airplane-mode play, device frame pacing/memory/heat, current Play declaration review, independent Hindi/editorial review and human gameplay balancing. Font code-point coverage alone is not proof of correct Devanagari shaping.

No model/cloud call, downloaded character art, sound, plugin, CI workflow, signing secret, merge or publication was introduced. The owner explicitly approved the initial README-only default-branch commit; implementation is isolated on a feature branch for PR review.
