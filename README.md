# Market Rickshaw Rush

Original offline three-lane Godot arcade racer for adults, set in a colourful fictional Indian bazaar. Repository chosen by the owner: `yogeshaneja/market-rickshaw-rush-godo` (the repository name ends in “godo”).

## Run on your computer

1. Install standard **Godot 4.6.3 stable** (GDScript, Compatibility renderer). This is the version actually checked; other stable 4.x versions require verification.
2. Open Godot Project Manager → Import → choose this folder’s `project.godot` → Import & Edit.
3. Press **F5** to run. Choose difficulty and Start run. Use A/D or arrow keys; on-screen buttons also work. P/Escape pauses.

This is a Godot project, not Expo: there is no `npm install`, QR code or Expo Go workflow. It uses original procedural artwork and the bundled OFL-licensed Noto Sans Devanagari font. Original synthesized music and sounds are bundled. No backend, cloud call, ads, payments or third-party plugins.

## Android phone testing

See `docs/android-testing.md`. A native APK export is still required; no APK or AAB has been built here. Configure verified Android tooling and matching export templates, then deploy via USB or paired wireless ADB. Developer-account setup is not needed for your own debug phone test. Production signing/publication remains separately approved.

## Play

Three difficulty presets, capped acceleration, seeded hazards, tokens, a guaranteed planned safe corridor, one-hit game over, immediate retry, pause/background protection and a 3-second explicit resume countdown. The guarantee is a reachable route, not protection from steering into obstacles. One accepted lane change per cooldown; holding a key does not auto-repeat input. Score is floor(world distance / 10) + 25 per collected token; distance is in fictional game units, not real metres. Seed 1729 repeats the same route per difficulty.

English defaults; Settings switches to Hindi. Best score per difficulty, language, audio/effects preferences and route/paint choices save to versioned `user://` JSON. Reset scores retains preferences except paint unlocks/selection, which return to the starter colour. No account or cloud sync. Interrupted runs do not resume after closing the app. Reduce effects removes nonessential bobbing, entry fades and token particles; essential road/lane movement remains.

## Verify

With Godot on PATH and Python 3 installed:

```sh
python tools/check.py
```

Or pass `--godot` with your editor executable’s absolute path. The wrapper checks exit codes, script errors and expected test summaries. It imports the actual project and runs three actual GDScript suites. Test persistence uses unique disposable filenames, not player saves.

The current result is 90,756 runner checks, 24 headless UI/store checks and 34 presentation/audio-control checks passed. These do not prove physical input, visible art quality, Hindi shaping, Android performance or standalone airplane-mode behavior. See `docs/verification.md` and `release/README.md`.

All four release steps have draft material. Public account/contact/hosting fields, Android package/export approval, final screenshots, independent Hindi/balance review, signed AAB and publication remain pending. No automatic CI/publishing is added. Nothing has been merged or released.

### Illustrated market visuals

The feature branch now bundles original vector market stalls, produce carts, cars and a detailed rickshaw, with festival pennants, animated driving details, coin sparkle and a dashboard dial. Nonessential driving effects respect Reduce Effects. Pull `feature/godot-market-racer`, allow Godot to finish importing the SVGs, then redeploy to replace the previous phone build. No new SDK, plugins or external services are required.

The market also includes tea stalls, shade umbrellas, trees, animated steam and flower garlands, two flying kites, three birds and lightweight driving dust. Flying objects are scenery, not obstacles. Additional motion freezes on pause and is static or hidden under Reduce Effects.

Elephants, monkeys and snakes also appear as avoidable lane obstacles, with gold ground markers and subtle reduced-motion-aware details. Colourful circus tents and animated flags are roadside scenery. All artwork is original and bundled; no extra plugins or services are used.

## Indian market atmosphere

Open **Routes & Rickshaw** from Home to choose Golden Bazaar, Coastal Market or Monsoon Street. These are visual settings with identical lane physics/difficulty, not different track layouts. Choose everyday, kite or festival-light decorations and optional evening lighting. Original arched shopfronts, balconies, palms/coastal edges, decorative rain/puddles, localized shop signs, marigolds, vendors and shoppers enrich the street. People stay on the pavement. All optional motion respects Reduce Effects; no new collision movement is added.

Rickshaws have original seat patterns, tassels and paintwork. Marigold/teal is available immediately; indigo and coral unlock at a best score of 300 and 800 in any difficulty. Selection and score-derived unlocks persist locally. Clearing scores resets these unlocks.

Settings has independent music and sound/ambience switches, volume sliders and a four-second preview. Audio starts only after Play or Preview, stops while paused/backgrounded/counting down and resumes music from its saved playback position. The player pool is bounded to five nodes; there is no streaming or microphone access.

The original **Bazaar Morning** synthesized instrumental, soft market chimes/rustle, rickshaw bell and coin/end cues total 73,000 bytes. These are synthesized flute-like and drum-inspired timbres, not sampled traditional performances. Source: `tools/generate_audio.py`; output permission and provenance: `assets/audio/LICENSE.txt` and `docs/audio-provenance.json`. Running the game does not require Python or ffmpeg; those tools are only for rebuilding audio. Listening/loop seams, actual Android interruptions and phone performance still need device review.
