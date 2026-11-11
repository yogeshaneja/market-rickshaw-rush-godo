extends SceneTree
const Sim = preload("res://scripts/runner_sim.gd")
const Save = preload("res://scripts/save_service.gd")
const Words = preload("res://scripts/localization.gd")
var failures := 0
var checks := 0
func check(value: bool, message: String) -> void:
 checks += 1
 if not value:
  failures += 1
  push_error(message)

func _initialize() -> void:
 test_lanes()
 test_seeds_and_safety()
 test_pause_score_collision()
 test_animal_obstacles()
 test_fixed_render_rates()
 test_saves()
 test_localization()
 print("RUNNER CHECKS: %d passed / %d checks" % [checks-failures,checks])
 quit(1 if failures else 0)

func test_lanes() -> void:
 var sim = Sim.new()
 sim.begin(0,1729)
 check(sim.move(-1),"left accepted")
 check(not sim.move(-1),"repeat blocked during cooldown")
 for i in range(20): sim.tick(1.0/60.0)
 check(sim.lane == 0 and is_equal_approx(sim.x,0.0),"left interpolation")
 check(not sim.move(-1),"edge blocked")
 check(not sim.move(2),"invalid direction blocked")
 sim.pause()
 check(not sim.move(1),"paused input blocked")

func test_seeds_and_safety() -> void:
 var rows_checked := 0
 var seen_kinds: Dictionary = {}
 for difficulty in range(3):
  for seed_value in range(100):
   var a = Sim.new()
   var b = Sim.new()
   a.begin(difficulty,seed_value)
   b.begin(difficulty,seed_value)
   check(a.rows == b.rows,"seed reproducibility")
   var last_safe := 1
   var previous_distance: float = 900.0-float(Sim.CONFIG[difficulty].gap)
   for batch in range(100):
    var row: Dictionary = a.rows[-1]
    check(a.valid_row(row,last_safe,previous_distance),"reachable safe corridor")
    check(row.safe not in row.blocked,"safe lane unblocked")
    check(row.blocked.size() < 3,"no full-width barrier")
    last_safe = row.safe
    previous_distance = row.at
    seen_kinds[row.kind] = true
    rows_checked += 1
    # Generate an arbitrary future row without allowing collision to terminate the test.
    a.distance = a.next_row-1700.0
    a._fill()
   var invalid: Dictionary = a.rows[-1].duplicate(true)
   invalid.blocked = [0,1,2]
   check(not a.valid_row(invalid,last_safe,previous_distance),"reject full barrier")
 for kind in range(Sim.HAZARD_COUNT): check(seen_kinds.has(kind),"all obstacle kinds occur in seeded routes")
 print("Spawn safety: %d generated rows across 300 seed/difficulty combinations" % rows_checked)
 # Play long routes by steering through the guaranteed safe corridor at the right time.
 for difficulty in range(3):
  var sim = Sim.new()
  sim.begin(difficulty,405)
  for tick in range(18000):
   var target: int = sim.lane
   for row in sim.rows:
    if row.at > sim.distance+Sim.DANGER_HALF_DEPTH and row.at-sim.distance < 330.0:
     target = row.safe
     break
   if target != sim.lane: sim.move(signi(target-sim.lane))
   sim.tick(1.0/60.0)
   if sim.state == "over": break
  check(sim.state == "running","safe corridor actually playable for 300 seconds")
  check(sim.speed <= Sim.CONFIG[difficulty].cap,"speed capped")
  check(sim.rows.size() < 10,"active spawn memory bounded")

func test_pause_score_collision() -> void:
 var sim = Sim.new()
 sim.begin(1,44)
 for i in range(30): sim.tick(1.0/60.0)
 var distance: float = sim.distance
 var score: int = sim.score()
 sim.pause()
 for i in range(100): sim.tick(1.0/60.0)
 check(sim.distance == distance and sim.score() == score,"pause prevents score inflation")
 sim.resume()
 for i in range(60): sim.tick(1.0/60.0)
 check(sim.state == "countdown" and sim.distance == distance,"countdown no movement")
 sim.pause()
 sim.resume()
 check(sim.countdown == 3.0,"background during countdown requires fresh countdown")
 for i in range(181): sim.tick(1.0/60.0)
 check(sim.state == "running","countdown completes")
 check(sim.hit() and not sim.hit() and sim.collisions == 1,"fatal collision once")
 var final_score: int = sim.score()
 sim.tick(1.0)
 check(sim.score() == final_score,"game over score frozen")
 sim.begin(0,5)
 check(sim.tokens == 0 and sim.collisions == 0 and sim.score() == 0,"restart clears run")
 sim.rows = [{"at":sim.distance,"safe":1,"blocked":[],"kind":0,"collected":false,"id":0}]
 sim.tick(1.0/60.0)
 check(sim.tokens == 1,"collect token")
 sim.tick(1.0/60.0)
 check(sim.tokens == 1,"token cannot collect twice")

func test_fixed_render_rates() -> void:
 var reference := -1.0
 for fps in [30,60,120]:
  var sim = Sim.new()
  sim.begin(0,9)
  sim.rows.clear()
  sim.next_row = 1000000.0
  var accumulator := 0.0
  for frame in range(fps*5):
   accumulator += 1.0/float(fps)
   while accumulator+0.0000001 >= 1.0/60.0:
    sim.tick(1.0/60.0)
    accumulator -= 1.0/60.0
  if reference < 0: reference = sim.distance
  check(is_equal_approx(reference,sim.distance),"fixed simulation independent of rendering cadence")

func test_saves() -> void:
 var test_path := "user://runner-test-" + str(Time.get_ticks_usec()) + ".json"
 var saves = Save.new(test_path)
 var defaults: Dictionary = saves.defaults()
 check(saves.validate(defaults) == defaults,"valid default save")
 for invalid in [null,[],{}, {"version":2}, {"version":1,"language":"xx","reduce_effects":false,"scores":[0,0,0]}, {"version":1,"language":"en","reduce_effects":false,"scores":[-1,2,3]}, {"version":1,"language":"en","reduce_effects":false,"scores":[1.5,2,3]}]:
  check(saves.validate(invalid) == defaults,"invalid saves recover")
 var data := {"version":1,"language":"hi","reduce_effects":true,"scores":[10,20,30]}
 var reset: Dictionary = saves.reset_scores(data)
 check(reset.scores == [0,0,0] and reset.language == "hi" and reset.reduce_effects,"reset retains preferences")
 check(data.scores == [10,20,30],"reset does not mutate original")
 # Test real I/O in a unique disposable test file, never a player save.
 check(saves.save_data(data),"actual temporary-file save")
 check(saves.load_data() == saves.validate(data),"actual save reload")
 check(saves.save_data(reset) and saves.load_data() == saves.validate(reset),"actual overwrite rename")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))

func test_localization() -> void:
 for key in Words.TEXT:
  check(Words.TEXT[key].size() == 2 and not Words.TEXT[key][0].is_empty() and not Words.TEXT[key][1].is_empty(),"paired English/Hindi strings")

func test_animal_obstacles() -> void:
 for level in range(3):
  for kind in range(4,Sim.HAZARD_COUNT):
   var sim = Sim.new()
   sim.begin(level,1729)
   sim.rows = [{"at":0.0,"safe":0,"blocked":[1],"kind":kind,"collected":false,"id":0}]
   sim.next_row = 1000000.0
   sim.pause()
   sim.tick(1.0/60.0)
   check(sim.collisions == 0 and sim.distance == 0.0,"paused animal does not collide")
   sim.state = "running"
   sim.tick(1.0/60.0)
   check(sim.state == "over" and sim.collisions == 1,"animal in blocked lane ends run")
   sim.tick(1.0/60.0)
   check(sim.collisions == 1,"animal collision counted once")
   sim.begin(level,1729)
   sim.rows = [{"at":0.0,"safe":1,"blocked":[0,2],"kind":kind,"collected":false,"id":0}]
   sim.next_row = 1000000.0
   sim.tick(1.0/60.0)
   check(sim.state == "running" and sim.collisions == 0,"animal obstacles preserve safe middle lane")
