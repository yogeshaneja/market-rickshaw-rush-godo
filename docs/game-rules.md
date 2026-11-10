# Simulation and safety contract

`runner_sim.gd` is independent of menus and rendering. The actual game calls it at fixed 60 Hz in `_physics_process`. World distance uses delta; rendering cadence does not accumulate score. Difficulty starts/caps are 170/270, 210/340 and 250/410 world units per second; acceleration is 2/3/4 units per second per second. Row spacing is 490/570/650 world units. Decorative time has no simulation effect.

The car has logical target lane 0–2 and an authoritative interpolated lane position. Lane changes take 0.22 seconds; accepted-input cooldown is 0.26 seconds. Continuous keyboard repeats and UI-originating swipes are excluded. Horizontal swipes need 42 virtual units and horizontal displacement greater than 1.4 times vertical displacement.

## Constructed safe corridor

Each seeded row chooses a safe lane at most one lane away from the preceding safe lane. Hazards occupy one or two distinct other lanes, never the safe lane. The collision envelope uses ±80 world-distance units and ±0.60 normalized lane units, conservatively covering the common axis-aligned player/hazard bounds. All hazard types share this conservative envelope; potholes can therefore end a run before the visible edge would touch.

The generator validates `(row gap − 2 × 80) / maximum speed >= reaction margin 0.6 + 2 × input cooldown 0.26`. This reserves time for reaction and two accepted lane changes in the clearance between row hazard envelopes even at capped speed. The planned corridor needs no more than one adjacent change. First hazard starts 900 world units ahead. Spawn memory is pruned; the generator and decoration do not share randomness. Scenery is procedural and deterministic rather than consuming gameplay RNG.

This guarantees a constructed reachable path, not safe movement after arbitrary late inputs. Tests validate 30,000 rows across 300 seed/difficulty combinations and play one planned-corridor route for 300 simulated seconds per difficulty. Human balance and perceived reaction fairness still need review.

## Score and state

Score = floor(distance / 10) + 25 × tokens. Running alone advances distance; pause, countdown and game over do not. Each row token has a collected guard. The first valid collision transitions to over and later hits return false. Main records the best result once on the running→over transition. Restart fully resets the run and RNG.

Focus loss/background pauses immediately, including during a resume countdown. Return does not auto-resume. Explicit resume starts a fresh 3-second countdown with simulation stopped. Best scores and settings survive a restart; active runs do not. Save validation rejects unknown versions, invalid language/effects fields, malformed score arrays, fractional, negative, non-finite and excessive scores. Writes flush a temporary file and rename it; actual write/overwrite is tested. Failures remain visible and are not claimed as successful persistence.
