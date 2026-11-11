extends SceneTree
const Save = preload("res://scripts/save_service.gd")
const Store = preload("res://scripts/store_link.gd")
var failures := 0
var checks := 0
func check(value: bool,message: String) -> void:
 checks += 1
 if not value: failures += 1; push_error(message)
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 var game = load("res://scenes/main.tscn").instantiate()
 var path := "user://ui-test-"+str(Time.get_ticks_usec())+".json"
 game.saves = Save.new(path)
 print("UI instantiate")
 root.add_child(game)
 await process_frame
 print("UI home ready")
 check(game.page == "home","home loaded")
 for page in ["tutorial","settings","about","home"]:
  game.show_page(page)
  check(is_instance_valid(game.ui),"UI page constructed")
 print("UI pages built")
 game.set_language("hi")
 check(game.preferences.language == "hi" and game.page == "settings","Hindi settings")
 var font: Font = game.button_theme.default_font
 check(font.has_char(0x0939) and font.has_char(0x094D),"bundled Hindi font coverage")
 print("UI start run")
 game.start_run()
 check(game.page == "game" and game.sim.state == "running","run starts")
 check(InputMap.has_action("move_left") and InputMap.has_action("pause"),"input mappings")
 game.pause_run()
 check(game.page == "pause" and game.sim.state == "paused","pause UI")
 game.resume_run()
 check(game.page == "game" and game.sim.state == "countdown","resume countdown UI")
 game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
 check(game.page == "pause" and game.sim.state == "paused","focus loss during countdown")
 print("UI start run")
 game.start_run()
 game.sim.rows = [{"at":0.0,"safe":0,"blocked":[1],"kind":0,"collected":false,"id":0}]
 game.sim.next_row = 1000000.0
 game._physics_process(1.0/60.0)
 check(game.page == "results" and game.sim.collisions == 1,"collision to results once")
 check(FileAccess.file_exists(path),"result saved")
 game.show_page("about")
 print("UI opening licenses")
 game.licenses_open = true
 game.show_page("about")
 check(is_instance_valid(game.panel),"offline licenses accessible")
 # Decorative motion must stop with game pause/results and the reduced-motion setting.
 game.preferences.reduce_effects = false
 game.start_run()
 var before: float = game.effects_time
 game._process(0.25)
 check(game.effects_time > before,"ambient motion runs during driving")
 game.particle_time = 0.4
 game.pause_run()
 before = game.effects_time
 game._process(0.25)
 check(game.effects_time == before and game.particle_time == 0.4,"pause freezes ambient motion and bursts")
 game.resume_run()
 game._process(0.25)
 check(game.effects_time == before,"countdown freezes ambient motion")
 game.start_run()
 game.preferences.reduce_effects = true
 before = game.effects_time
 game._process(0.25)
 check(game.effects_time == before,"reduced effects freeze decorative clock")
 game.preferences.reduce_effects = false
 game.show_page("results")
 before = game.effects_time
 game._process(0.25)
 check(game.effects_time == before,"results freeze ambient motion")
 print("UI store checks")
 var config := {"published":false,"listing_verified":false,"package_id":"com.example.racer"}
 var calls: Array = []
 var opener := func(url: String) -> int: calls.append(url); return ERR_CANT_OPEN if url.begins_with("market:") else OK
 check(not Store.open_listing(config,opener,true) and calls.is_empty(),"unpublished store never opens")
 config.published = true
 config.listing_verified = true
 check(Store.open_listing(config,opener,true) and calls.size() == 2,"native listing fallback")
 check(not Store.open_listing(config,func(_url: String) -> int: return ERR_CANT_OPEN,true),"store errors contained")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 game.queue_free()
 await process_frame
 print("UI/STORE CHECKS: %d passed / %d checks" % [checks-failures,checks])
 quit(1 if failures else 0)
