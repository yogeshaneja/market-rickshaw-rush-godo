extends RefCounted
## Pure fixed-step runner. Visual effects never change collision, score or spawn state.
const CONFIG = [
 {"start":170.0,"cap":270.0,"accel":2.0,"hazards":1,"gap":490.0},
 {"start":210.0,"cap":340.0,"accel":3.0,"hazards":2,"gap":570.0},
 {"start":250.0,"cap":410.0,"accel":4.0,"hazards":2,"gap":650.0}
]
const CHANGE_TIME = 0.22
const INPUT_COOLDOWN = 0.26
const REACTION_MARGIN = 0.6
const DANGER_HALF_DEPTH = 80.0
const TOKEN_BONUS = 25
var state: String = "ready"
var difficulty: int = 0
var lane: int = 1
var x: float = 1.0
var cooldown: float = 0.0
var distance: float = 0.0
var tokens: int = 0
var collisions: int = 0
var countdown: float = 0.0
var speed: float = 0.0
var rows: Array = []
var rng := RandomNumberGenerator.new()
var next_row: float = 900.0
var safe_lane: int = 1
var row_id: int = 0

func begin(level: int, seed_value: int) -> void:
 difficulty = clampi(level, 0, 2)
 state = "running"
 lane = 1
 x = 1.0
 cooldown = 0.0
 distance = 0.0
 tokens = 0
 collisions = 0
 countdown = 0.0
 rows.clear()
 next_row = 900.0
 safe_lane = 1
 row_id = 0
 rng.seed = seed_value
 speed = CONFIG[difficulty].start
 _fill()

func move(direction: int) -> bool:
 if state != "running" or cooldown > 0.0 or abs(direction) != 1:
  return false
 var target := clampi(lane + direction, 0, 2)
 if target == lane:
  return false
 lane = target
 cooldown = INPUT_COOLDOWN
 return true

func pause() -> void:
 if state in ["running", "countdown"]:
  state = "paused"

func resume() -> void:
 if state == "paused":
  state = "countdown"
  countdown = 3.0

func hit() -> bool:
 if state != "running":
  return false
 collisions += 1
 state = "over"
 return true

func score() -> int:
 return int(floor(distance / 10.0)) + tokens * TOKEN_BONUS

func valid_row(row: Dictionary, previous_safe: int, previous_distance: float) -> bool:
 var config: Dictionary = CONFIG[difficulty]
 var safe: int = row.safe
 if safe < 0 or safe > 2 or absi(safe - previous_safe) > 1:
  return false
 if row.blocked.size() > 2 or safe in row.blocked:
  return false
 var used: Array = []
 for blocked in row.blocked:
  if blocked < 0 or blocked > 2 or blocked in used:
   return false
  used.append(blocked)
 # Free interval permits a reaction margin plus two full accepted lane changes.
 var free_seconds: float = (row.at - previous_distance - 2.0 * DANGER_HALF_DEPTH) / config.cap
 return free_seconds >= REACTION_MARGIN + 2.0 * INPUT_COOLDOWN

func _fill() -> void:
 while next_row < distance + 1800.0:
  var candidate := clampi(safe_lane + rng.randi_range(-1, 1), 0, 2)
  var candidates: Array = [0, 1, 2]
  candidates.erase(candidate)
  if rng.randi_range(0, 1) == 1:
   candidates.reverse()
  var blocked: Array = candidates.slice(0, int(CONFIG[difficulty].hazards))
  var row: Dictionary = {"id":row_id,"at":next_row,"safe":candidate,"blocked":blocked,"kind":rng.randi_range(0,3),"collected":false}
  # Spacing is fixed by cap, not current speed, and cannot shrink at high speed.
  if not valid_row(row, safe_lane, next_row - float(CONFIG[difficulty].gap)):
   push_error("Unsafe configured spawn spacing")
   state = "over"
   return
  rows.append(row)
  safe_lane = candidate
  next_row += CONFIG[difficulty].gap
  row_id += 1

func tick(delta: float) -> void:
 if state == "countdown":
  countdown = maxf(0.0, countdown - delta)
  if countdown <= 0.0:
   state = "running"
  return
 if state != "running":
  return
 var dt := clampf(delta, 0.0, 1.0 / 30.0)
 cooldown = maxf(0.0, cooldown - dt)
 x = move_toward(x, float(lane), dt / CHANGE_TIME)
 speed = minf(CONFIG[difficulty].cap, speed + CONFIG[difficulty].accel * dt)
 distance += speed * dt
 _fill()
 for row in rows:
  var relative: float = row.at - distance
  if absf(relative) <= DANGER_HALF_DEPTH:
   for blocked in row.blocked:
    if absf(x - float(blocked)) < 0.60:
     hit()
     return
   if not row.collected and absf(relative) <= 28.0 and absf(x - float(row.safe)) < 0.42:
    row.collected = true
    tokens += 1
 rows = rows.filter(func(row: Dictionary) -> bool: return row.at >= distance - 160.0)
