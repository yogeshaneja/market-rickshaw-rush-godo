extends SceneTree
const Save = preload("res://scripts/save_service.gd")
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
 checks += 1
 if not value: failures += 1; push_error(message)
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 var path := "user://presentation-test-"+str(Time.get_ticks_usec())+".json"
 var saves = Save.new(path)
 var legacy := {"version":1,"language":"hi","reduce_effects":true,"scores":[12,345,678]}
 var migrated: Dictionary = saves.validate(legacy)
 check(migrated.scores == legacy.scores and migrated.language == "hi","v1 migration retains scores and language")
 check(migrated.route == 0 and migrated.music_volume == 0.25,"legacy files get safe presentation/audio defaults")
 var invalid := migrated.duplicate(true)
 invalid.route = 99
 invalid.skin = 2
 invalid.music_volume = -1
 invalid.sfx_volume = "loud"
 var sanitized: Dictionary = saves.validate(invalid)
 check(sanitized.route == 0 and sanitized.skin == 0,"invalid or locked cosmetics fall back without erasing scores")
 check(sanitized.scores == legacy.scores and sanitized.music_volume == 0.25 and sanitized.sfx_volume == 0.4,"invalid volume never reaches audio players")
 for score in [0,299,300,799,800]:
  var data := saves.defaults()
  data.scores[0] = score
  check(saves.skin_unlocked(data,1) == (score>=300),"indigo score threshold")
  check(saves.skin_unlocked(data,2) == (score>=800),"coral score threshold")
 var game = load("res://scenes/main.tscn").instantiate()
 game.saves = saves
 root.add_child(game)
 await process_frame
 check(not game.sound.music.playing and not game.sound.air.playing,"launch does not autoplay audio")
 game.preferences.scores[0] = 800
 for route in range(3):
  game.set_choice("route",route)
  check(game.preferences.route == route and game.page == "garage","route selection updates garage")
 for festival in range(3):
  game.set_choice("festival",festival)
  check(game.preferences.festival == festival,"festival selection")
 game.set_choice("evening",true)
 game.set_choice("skin",2)
 game.set_audio("music_on",false)
 game.set_audio("sfx_on",true)
 game.preferences.music_volume = 0.15
 game.preferences.sfx_volume = 0.35
 saves.save_data(game.preferences)
 var loaded: Dictionary = saves.load_data()
 check(loaded.route == 2 and loaded.festival == 2 and loaded.evening and loaded.skin == 2,"cosmetics survive disk reload")
 check(not loaded.music_on and loaded.sfx_on and is_equal_approx(loaded.sfx_volume,0.35),"independent audio preferences persist")
 game.start_run()
 await create_timer(0.06).timeout
 check(game.sound.active and not game.sound.music.playing and game.sound.air.playing,"music mute does not mute ambience")
 check(game.sound.voices.size()==3 and game.sound.get_child_count()==5,"fixed player/voice budget")
 var rows: Array = game.sim.rows.duplicate(true)
 game.preferences.route = 0
 game.preferences.festival = 1
 game.preferences.evening = false
 check(game.sim.rows == rows,"presentation choices do not modify generated hazards")
 game.pause_run()
 check(not game.sound.music.playing and not game.sound.air.playing,"pause suspends loops")
 game.resume_run()
 check(not game.sound.active and not game.sound.air.playing,"countdown remains silent")
 game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
 check(not game.sound.focused and not game.sound.air.playing,"background suspends audio")
 game.sound.preview()
 check(game.sound.preview_left == 0.0,"background cannot start preview")
 game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
 game.show_page("settings")
 game.preferences.music_on = true
 game.preferences.sfx_on = false
 game.sound.configure(game.preferences)
 game.sound.preview()
 await create_timer(0.06).timeout
 check(game.sound.preview_left>0.0 and game.sound.music.playing,"explicit preview plays music with SFX muted")
 game.sound._process(4.1)
 check(game.sound.preview_left == 0.0 and not game.sound.music.playing,"preview ends and suspends loop")
 game.sound.set_active(true)
 await create_timer(0.06).timeout
 game.preferences.music_volume = 0.0
 game.preferences.sfx_volume = 0.0
 game.sound.configure(game.preferences)
 check(not game.sound.music.playing and not game.sound.air.playing,"zero volume mutes independently of enabled flags")
 for i in range(20): game.sound.cue("coin")
 check(game.sound.get_child_count()==5,"repeated cues never allocate extra players")
 game.queue_free()
 await process_frame
 await create_timer(0.15).timeout
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("PRESENTATION CHECKS: %d passed / %d checks" % [checks-failures,checks])
 quit(1 if failures else 0)
