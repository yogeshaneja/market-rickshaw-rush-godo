extends SceneTree
const Sim = preload("res://scripts/runner_sim.gd")
const Save = preload("res://scripts/save_service.gd")
var failures := 0
var checks := 0
func check(value: bool, message: String) -> void:
 checks += 1
 if not value: failures += 1; push_error(message)
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 check(ProjectSettings.get_setting("display/window/handheld/orientation")==DisplayServer.SCREEN_LANDSCAPE,"landscape orientation")
 check(ProjectSettings.get_setting("display/window/size/viewport_width")==1280 and ProjectSettings.get_setting("display/window/size/viewport_height")==720,"landscape canvas")
 var sim = Sim.new()
 sim.begin(0,9)
 sim.rows.clear()
 sim.next_row = 1000000.0
 check(sim.jump() and not sim.jump(),"jump starts once; no double jump")
 for i in range(12): sim.tick(1.0/60.0)
 check(sim.jump_height()>0.0 and sim.jump_clearance(),"airborne arc and clearance")
 sim.pause()
 var frozen: float = sim.jump_elapsed
 var cooldown: float = sim.jump_cooldown
 for i in range(5): sim.tick(1.0/60.0)
 check(sim.jump_elapsed==frozen and sim.jump_cooldown==cooldown and not sim.jump(),"pause freezes jump and cooldown")
 sim.resume()
 sim.tick(0.5)
 check(sim.jump_elapsed==frozen,"resume countdown does not advance jump")
 sim.state = "running"
 for i in range(65): sim.tick(1.0/60.0)
 check(sim.jump_elapsed<0.0 and not sim.jump(),"landing still obeys cooldown")
 for i in range(25): sim.tick(1.0/60.0)
 check(sim.jump(),"jump re-arms after cooldown")
 sim.begin(0,9)
 check(sim.jump_elapsed<0.0 and sim.jump_cooldown==0.0,"restart clears jump state")
 # A single short crossing for each low hazard and difficulty, not the large seed suite.
 for level in range(3):
  for kind in Sim.JUMPABLE_KINDS:
   sim.begin(level,9)
   sim.rows = [{"id":0,"at":80.0+float(Sim.CONFIG[level].start)*0.15,"safe":0,"blocked":[1],"kind":kind,"collected":false}]
   sim.next_row = 1000000.0
   sim.jump()
   for i in range(75): sim.tick(1.0/60.0)
   check(sim.state=="running" and sim.collisions==0,"timed jump clears low obstacle at each difficulty")
 for kind in [3,4]:
  sim.begin(0,9)
  sim.rows = [{"id":0,"at":100.0,"safe":0,"blocked":[1],"kind":kind,"collected":false}]
  sim.next_row = 1000000.0
  sim.jump()
  for i in range(75): sim.tick(1.0/60.0)
  check(sim.state=="over" and sim.collisions==1,"cars and elephants cannot be jumped")
 sim.begin(0,9)
 sim.rows = [{"id":0,"at":0.0,"safe":0,"blocked":[1],"kind":0,"collected":false}]
 sim.next_row = 1000000.0
 sim.tick(1.0/60.0)
 check(sim.state=="over","grounded collision unchanged")
 var game = load("res://scenes/main.tscn").instantiate()
 var path := "user://jump-ui-"+str(Time.get_ticks_usec())+".json"
 game.saves = Save.new(path)
 root.add_child(game)
 await process_frame
 game.preferences.music_on = false
 game.preferences.sfx_on = false
 game.sound.configure(game.preferences)
 for page in ["home","garage","settings","tutorial"]:
  game.show_page(page)
  var scroll: ScrollContainer = game.panel.get_parent()
  check(scroll.position.x>=0 and scroll.position.y>=0 and scroll.position.x+scroll.size.x<=1280 and scroll.position.y+scroll.size.y<=720,"menu fits landscape viewport")
 game.start_run()
 game._physics_process(1.0/60.0)
 check(InputMap.has_action("jump") and is_instance_valid(game.jump_button),"keyboard and touch jump controls")
 var rect: Rect2 = game.jump_button.get_global_rect()
 check(rect.position.x>=0 and rect.position.y>=0 and rect.end.x<=1280 and rect.end.y<=720,"jump control within landscape viewport")
 game.jump_button.pressed.emit()
 check(game.sim.jump_elapsed==0.0,"touch button starts jump")
 game._physics_process(1.0/60.0)
 check(game.jump_button.disabled,"jump button shows cooldown")
 game.queue_free()
 await process_frame
 await create_timer(0.15).timeout
 if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("JUMP/LANDSCAPE CHECKS: %d passed / %d checks" % [checks-failures,checks])
 quit(1 if failures else 0)
