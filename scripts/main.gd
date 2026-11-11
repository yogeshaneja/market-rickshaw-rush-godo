extends Node2D
const MarketLife = preload("res://scripts/market_life.gd")
var market_life = MarketLife.new()
const Sim = preload("res://scripts/runner_sim.gd")
const Save = preload("res://scripts/save_service.gd")
const StoreLink = preload("res://scripts/store_link.gd")
const RELEASE = preload("res://config/release.json")
const RICKSHAW_ART = preload("res://assets/art/rickshaw.svg")
const CAR_ART = preload("res://assets/art/car.svg")
const ANIMAL_ART = [preload("res://assets/art/elephant.svg"),preload("res://assets/art/monkey.svg"),preload("res://assets/art/snake.svg")]
const CART_ART = preload("res://assets/art/cart.svg")
const STALL_ART = [preload("res://assets/art/stall-0.svg"),preload("res://assets/art/stall-1.svg"),preload("res://assets/art/stall-2.svg"),preload("res://assets/art/stall-3.svg")]
const Words = preload("res://scripts/localization.gd")
var sim = Sim.new()
var saves = Save.new()
var preferences: Dictionary
var level := 0
var seed_value := 1729
var page := "home"
var layer: CanvasLayer
var ui: Control
var panel: VBoxContainer
var hud: Label
var speed_label: Label
var countdown_label: Label
var touch_start := Vector2.ZERO
var touch_index := -1
var effects_time := 0.0
var particle_time := 0.0
var reset_pending := false
var button_theme := Theme.new()
var licenses_open := false
var boxes: Dictionary = {}
var screen_tween: Tween
const GOLD = Color("f6bd4b")
const CORAL = Color("ee796b")
const MINT = Color("55b6a3")
const INK = Color("153443")
const PAPER = Color("fff5dc")

func word(key: String) -> String:
 return Words.text(key, preferences.language)

func _ready() -> void:
 preferences = saves.load_data()
 for action in ["move_left","move_right","pause","confirm"]:
  if not InputMap.has_action(action): InputMap.add_action(action)
 var mappings = {"move_left":[KEY_LEFT,KEY_A],"move_right":[KEY_RIGHT,KEY_D],"pause":[KEY_ESCAPE,KEY_P],"confirm":[KEY_ENTER]}
 for action in mappings:
  for code in mappings[action]:
   var event := InputEventKey.new()
   event.physical_keycode = code
   InputMap.action_add_event(action,event)
 button_theme.default_font = load("res://assets/fonts/NotoSansDevanagari-Regular.ttf")
 button_theme.default_font_size = 19
 layer = CanvasLayer.new()
 add_child(layer)
 show_page("home")
 get_tree().auto_accept_quit = false

func _notification(what: int) -> void:
 if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
  if sim.state in ["running","countdown"]:
   sim.pause()
   touch_index = -1
   if is_instance_valid(layer): show_page("pause")
 if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
  if page == "game": pause_run()
  elif page != "home": show_page("home")
  else: get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
 if event.is_action_pressed("pause") and not event.is_echo():
  if page == "game": pause_run()
  elif page == "pause": resume_run()
  return
 if page != "game" or sim.state != "running": return
 if event.is_action_pressed("move_left") and not event.is_echo(): sim.move(-1)
 elif event.is_action_pressed("move_right") and not event.is_echo(): sim.move(1)
 elif event is InputEventScreenTouch:
  if event.pressed and touch_index == -1:
   touch_index = event.index
   touch_start = event.position
  elif not event.pressed and event.index == touch_index:
   var gesture: Vector2 = event.position - touch_start
   touch_index = -1
   if absf(gesture.x) > 42.0 and absf(gesture.x) > absf(gesture.y) * 1.4: sim.move(1 if gesture.x > 0 else -1)

func _physics_process(delta: float) -> void:
 if page != "game": return
 var old_state: String = sim.state
 var old_tokens: int = sim.tokens
 sim.tick(delta)
 if sim.tokens > old_tokens: particle_time = 0.55
 if old_state == "running" and sim.state == "over":
  preferences.scores[level] = maxi(preferences.scores[level],sim.score())
  saves.save_data(preferences)
  show_page("results")
 if is_instance_valid(speed_label): speed_label.text = "%03d" % int(sim.speed / 5.0)
 if is_instance_valid(hud): hud.text = "%s  %d    ◆ %d    %s  %d" % [word("score"),sim.score(),sim.tokens,word("best"),preferences.scores[level]]
 if is_instance_valid(countdown_label): countdown_label.text = "%s\n%d" % [word("countdown"),ceili(sim.countdown)] if sim.state == "countdown" else ""

func _process(delta: float) -> void:
 # Freeze ambient motion on pause, countdown and results, including coin bursts.
 if not preferences.reduce_effects and (page == "home" or (page == "game" and sim.state == "running")):
  effects_time += delta
  particle_time = maxf(0.0,particle_time - delta)
 queue_redraw()

func _clear_ui() -> void:
 if screen_tween and screen_tween.is_valid(): screen_tween.kill()
 if is_instance_valid(ui):
  layer.remove_child(ui)
  ui.queue_free()
 ui = Control.new()
 ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
 ui.theme = button_theme
 layer.add_child(ui)
 hud = null
 speed_label = null
 countdown_label = null

func label(text: String, size: int = 19) -> Label:
 var item := Label.new()
 item.text = text
 item.add_theme_font_size_override("font_size",size)
 item.add_theme_color_override("font_color",PAPER)
 item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 item.mouse_filter = Control.MOUSE_FILTER_IGNORE
 panel.add_child(item)
 return item

func button(text: String, action: Callable, accent: bool = false) -> Button:
 var item := Button.new()
 item.text = text
 item.custom_minimum_size = Vector2(0,54)
 item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 item.add_theme_color_override("font_color",INK if accent else PAPER)
 var box := StyleBoxFlat.new()
 box.bg_color = GOLD if accent else Color("244c5c")
 box.set_corner_radius_all(16)
 box.border_width_bottom = 3
 box.border_color = Color("b78128") if accent else Color("102f40")
 box.content_margin_left = 14
 box.content_margin_right = 14
 item.add_theme_stylebox_override("normal",box)
 var hover := box.duplicate()
 hover.bg_color = MINT if accent else Color("356273")
 item.add_theme_stylebox_override("hover",hover)
 item.add_theme_stylebox_override("pressed",hover)
 item.pressed.connect(action)
 panel.add_child(item)
 return item

func make_panel() -> void:
 var background := Panel.new()
 background.position = Vector2(20,35)
 background.size = Vector2(440,815)
 var style := StyleBoxFlat.new()
 style.bg_color = Color(0.035,0.10,0.15,0.94)
 style.set_corner_radius_all(22)
 background.add_theme_stylebox_override("panel",style)
 ui.add_child(background)
 var scroll := ScrollContainer.new()
 scroll.position = Vector2(38,51)
 scroll.size = Vector2(404,779)
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 ui.add_child(scroll)
 panel = VBoxContainer.new()
 panel.custom_minimum_size.x = 390
 panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 panel.add_theme_constant_override("separation",12)
 scroll.add_child(panel)

func show_page(name: String) -> void:
 page = name
 touch_index = -1
 _clear_ui()
 if name == "game":
  hud = Label.new()
  hud.position = Vector2(12,14)
  hud.size = Vector2(456,64)
  hud.add_theme_color_override("font_color",INK)
  hud.add_theme_font_size_override("font_size",18)
  hud.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  ui.add_child(hud)
  panel = VBoxContainer.new()
  panel.position = Vector2(367,77)
  panel.size = Vector2(102,60)
  ui.add_child(panel)
  button(word("pause"),pause_run)
  panel = VBoxContainer.new()
  panel.position = Vector2(26,805)
  panel.size = Vector2(138,70)
  ui.add_child(panel)
  button("← " + word("left"),func(): sim.move(-1))
  panel = VBoxContainer.new()
  panel.position = Vector2(316,805)
  panel.size = Vector2(138,70)
  ui.add_child(panel)
  button(word("right") + " →",func(): sim.move(1))
  countdown_label = Label.new()
  countdown_label.position = Vector2(100,330)
  countdown_label.size = Vector2(280,150)
  countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  countdown_label.add_theme_font_size_override("font_size",40)
  countdown_label.add_theme_color_override("font_color",PAPER)
  ui.add_child(countdown_label)
  speed_label = Label.new()
  speed_label.position = Vector2(198,813)
  speed_label.size = Vector2(84,46)
  speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  speed_label.add_theme_font_size_override("font_size",30)
  speed_label.add_theme_color_override("font_color",GOLD)
  ui.add_child(speed_label)
  return
 make_panel()
 label(word("title"),30)
 if saves.failed: label(word("save_error"),17)
 if saves.recovered: label(word("recovered"),17)
 match name:
  "home":
   var hero := TextureRect.new()
   hero.texture = RICKSHAW_ART
   hero.custom_minimum_size = Vector2(0,142)
   hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
   hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
   hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
   panel.add_child(hero)
   label(word("tag"),16)
   label(word("intro"))
   label(word("difficulty"),17)
   for i in range(3):
    var choice: int = i
    button(("● " if level == i else "○ ") + word(["easy","normal","hard"][i]) + " · " + word("best") + " " + str(preferences.scores[i]),func(): level = choice; show_page("home"))
   button(word("play"),start_run,true)
   button(word("tutorial"),func(): show_page("tutorial"))
   button(word("settings"),func(): show_page("settings"))
   button(word("about"),func(): show_page("about"))
   label(word("updates"),16)
   if StoreLink.available(RELEASE.data): button(word("store"),open_store)
  "tutorial":
   label(word("tutorial"),25)
   label(word("tutorial_text"))
   label(word("tutorial_note"))
   label(word("animals"))
   button(word("play"),start_run,true)
   button(word("home"),func(): show_page("home"))
  "pause":
   label(word("paused"),27)
   button(word("resume"),resume_run,true)
   button(word("restart"),start_run)
   button(word("home"),func(): sim.state = "ready"; show_page("home"))
  "results":
   label(word("over"),28)
   label(word("score") + "  " + str(sim.score()),32)
   label(word("distance") + "  " + str(int(sim.distance)) + " · " + word("tokens") + "  " + str(sim.tokens))
   label(word("best") + "  " + str(preferences.scores[level]))
   label(word("seed") + "  " + str(seed_value),15)
   button(word("retry"),start_run,true)
   button(word("home"),func(): show_page("home"))
  "settings":
   label(word("language"),24)
   button("English" + (" ●" if preferences.language == "en" else ""),func(): set_language("en"))
   button("हिन्दी" + (" ●" if preferences.language == "hi" else ""),func(): set_language("hi"))
   button(word("effects") + ": " + word("on" if preferences.reduce_effects else "off"),func(): preferences.reduce_effects = not preferences.reduce_effects; saves.save_data(preferences); show_page("settings"))
   label(word("effects_help"),17)
   if reset_pending:
    label(word("reset_question"))
    button(word("confirm"),func(): preferences = saves.reset_scores(preferences); saves.save_data(preferences); reset_pending = false; show_page("settings"))
    button(word("cancel"),func(): reset_pending = false; show_page("settings"))
   else: button(word("reset"),func(): reset_pending = true; show_page("settings"))
   label(word("saved"),16)
   button(word("home"),func(): reset_pending = false; show_page("home"))
  "about":
   label(word("about_text"),18)
   label(word("privacy"),18)
   label(word("fiction"),17)
   if StoreLink.available(RELEASE.data): button(word("store"),open_store)
   button("Engine & font licenses" if preferences.language == "en" else "इंजन और फ़ॉन्ट लाइसेंस",func(): licenses_open = not licenses_open; show_page("about"))
   if licenses_open:
    var notices: String = Engine.get_license_text() + "\n\n" + JSON.stringify(Engine.get_copyright_info(),"  ") + "\n\n" + JSON.stringify(Engine.get_license_info(),"  ") + "\n\n" + FileAccess.get_file_as_string("res://assets/fonts/OFL.txt")
    var license_view := TextEdit.new()
    license_view.text = notices
    license_view.editable = false
    license_view.custom_minimum_size = Vector2(0,320)
    license_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    license_view.add_theme_font_size_override("font_size",14)
    panel.add_child(license_view)
   label(word("review"),16)
   label(word("updates"),16)
   button(word("home"),func(): show_page("home"))
 if not preferences.reduce_effects:
  ui.modulate.a = 0.0
  screen_tween = create_tween()
  screen_tween.tween_property(ui,"modulate:a",1.0,0.24)

func set_language(language: String) -> void:
 preferences.language = language
 saves.save_data(preferences)
 show_page("settings")

func start_run() -> void:
 sim.begin(level,seed_value)
 particle_time = 0.0
 reset_pending = false
 show_page("game")

func pause_run() -> void:
 sim.pause()
 show_page("pause")

func resume_run() -> void:
 sim.resume()
 show_page("game")

func lane_x(value: float) -> float:
 return 148.0 + value * 92.0

func _draw() -> void:
 draw_rect(Rect2(0,0,480,900),Color("d9b58b"))
 var travel: float = sim.distance if page in ["game","pause","results"] else 0.0
 draw_rect(Rect2(95,0,290,900),Color("283c49"))
 draw_rect(Rect2(105,0,270,900),Color("344955"))
 for edge in [95,377]:
  for i in range(-1,25):
   draw_rect(Rect2(edge,float(i*40)+fmod(travel,40.0),8,38),Color("f0ce86") if i%2==0 else Color("a76c54"))
 for line in [194,286]:
  for i in range(-1,12): draw_rect(Rect2(line,float(i*90)+fmod(travel,90.0),3,42),Color("b6c6bd"))
 for i in range(-1,6):
  var y := float(i*210)+fmod(travel,210.0)
  draw_stall(Vector2(-1,y),i)
  draw_stall(Vector2(386,y+95),i+2)
 market_life.draw_market(self,effects_time,travel,preferences.reduce_effects)
 # Overhead strings and pennants move with the road, kept above the collision zone.
 for i in range(-1,3):
  var y := float(i*620)+fmod(travel,620.0)
  draw_polyline(PackedVector2Array([Vector2(82,y),Vector2(240,y+30),Vector2(398,y)]),Color("1d3540"),2,true)
  for j in range(10):
   var x := 96.0+j*30.0
   var sag := 28.0*(1.0-absf(x-240.0)/158.0)
   draw_colored_polygon(PackedVector2Array([Vector2(x,y+sag),Vector2(x+18,y+sag),Vector2(x+9,y+sag+22)]),[GOLD,CORAL,MINT][j%3])
 market_life.draw_flying(self,effects_time,preferences.reduce_effects)
 if page in ["game","pause","results"]:
  for row in sim.rows:
   var y: float = 700.0 - (row.at - sim.distance)
   if y < -110 or y > 950: continue
   for blocked in row.blocked: draw_hazard(Vector2(lane_x(float(blocked)),y),row.kind)
   if not row.collected: draw_token(Vector2(lane_x(float(row.safe)),y))
 var bob: float = sin(effects_time*9.0)*1.5 if page == "game" and not preferences.reduce_effects and sim.state == "running" else 0.0
 if page == "game" and sim.state == "running" and not preferences.reduce_effects:
  market_life.draw_dust(self,Vector2(lane_x(sim.x),700),effects_time)
 draw_rickshaw(Vector2(lane_x(sim.x),700+bob))
 if particle_time > 0.0 and not preferences.reduce_effects:
  for i in range(12):
   var angle := float(i)*TAU/12.0
   draw_circle(Vector2(lane_x(sim.x),650)+Vector2(cos(angle),sin(angle))*(1.0-particle_time/0.55)*70,particle_time*7,GOLD)
 if page == "game":
  draw_style_box(round_box(PAPER,16),Rect2(7,7,466,67))
  draw_style_box(round_box(INK,18),Rect2(184,801,112,75))
  draw_arc(Vector2(240,853),42,PI+0.2,TAU-0.2,24,Color("356273"),3,true)
  var speed_fraction: float = clampf(sim.speed / float(Sim.CONFIG[level].cap),0.0,1.0)
  draw_arc(Vector2(240,853),42,PI+0.2,PI+0.2+speed_fraction*(PI-0.4),24,MINT,3,true)

func draw_stall(at: Vector2, index: int) -> void:
 draw_texture_rect(STALL_ART[posmod(index,4)],Rect2(at,Vector2(94,200)),false)

func draw_rickshaw(at: Vector2) -> void:
 # Art stays inside the existing obstacle/collision readability envelope.
 var lean: float = clampf((float(sim.lane)-sim.x)*0.12,-0.1,0.1) if page == "game" and not preferences.reduce_effects else 0.0
 draw_set_transform(at,lean)
 draw_texture_rect(RICKSHAW_ART,Rect2(Vector2(-36,-52),Vector2(72,106)),false)
 if page == "game" and sim.state == "running" and not preferences.reduce_effects:
  var wheel_offset: float = fmod(sim.distance*0.3,8.0)
  for side in [-26.0,26.0]:
   for i in range(2):
    draw_line(Vector2(side-3,25+i*8+wheel_offset),Vector2(side+3,25+i*8+wheel_offset),Color("617482"),1)
 draw_set_transform(Vector2.ZERO)

func round_box(color: Color, radius: int) -> StyleBoxFlat:
 var key := color.to_html() + str(radius)
 if boxes.has(key): return boxes[key]
 var box := StyleBoxFlat.new()
 box.bg_color = color
 box.set_corner_radius_all(radius)
 boxes[key] = box
 return box

func draw_hazard(at: Vector2, kind: int) -> void:
 if kind >= 4 and kind < Sim.HAZARD_COUNT:
  # An outlined footprint signals the blocked lane for smaller animals too.
  # Only ears/tails move inside this footprint, never the obstacle position.
  draw_set_transform(at,0,Vector2(1,0.6))
  draw_circle(Vector2(0,16),35,Color(0.08,0.18,0.23,0.32))
  draw_arc(Vector2(0,16),35,0,TAU,32,Color("f6bd4b"),2,true)
  draw_set_transform(Vector2.ZERO)
  var size := Vector2(68,104) if kind == 4 else Vector2(64,78)
  draw_texture_rect(ANIMAL_ART[kind-4],Rect2(at-size*0.5,size),false)
  if not preferences.reduce_effects:
   var twitch: float = sin(effects_time*4.0+kind)*3.0
   if kind == 4:
    draw_arc(at+Vector2(-21,-23),7,PI*0.5,PI*1.5,8,Color("b2c5cb"),2,true)
    draw_arc(at+Vector2(21,-23),7,-PI*0.5,PI*0.5,8,Color("b2c5cb"),2,true)
    draw_line(at+Vector2(-22,-29),at+Vector2(-25+twitch,-22),Color("718ca2"),3,true)
   elif kind == 5:
    draw_arc(at+Vector2(23,16),6+twitch*0.4,-PI*0.5,PI,12,Color("c18a57"),3,true)
   else:
    draw_line(at+Vector2(-3,-28),at+Vector2(-8+twitch,-33),Color("e77b75"),1.5,true)
  return
 match kind:
  0:
   draw_rect(Rect2(at-Vector2(25,30),Vector2(50,60)),Color("bd8050"))
   draw_line(at+Vector2(-20,-24),at+Vector2(20,24),GOLD,6)
   draw_line(at+Vector2(20,-24),at+Vector2(-20,24),GOLD,6)
  1:
   draw_set_transform(at,0,Vector2(1.0,0.55))
   draw_circle(Vector2.ZERO,30,Color("162c36"))
   draw_arc(Vector2.ZERO,29,0,PI,16,Color("768b8f"),4)
   draw_set_transform(Vector2.ZERO)
  2:
   draw_texture_rect(CART_ART,Rect2(at-Vector2(31,38),Vector2(62,76)),false)
  3:
   draw_texture_rect(CAR_ART,Rect2(at-Vector2(29,46),Vector2(58,92)),false)

func draw_token(at: Vector2) -> void:
 draw_circle(at+Vector2(2,4),18,Color(0.05,0.12,0.16,0.35))
 draw_circle(at,17,Color("d18b28"))
 draw_circle(at-Vector2(0,2),14,GOLD)
 draw_arc(at-Vector2(0,2),10,0,TAU,24,Color("ffe7a1"),2,true)
 draw_colored_polygon(PackedVector2Array([at+Vector2(0,-9),at+Vector2(6,-2),at+Vector2(0,5),at+Vector2(-6,-2)]),PAPER)

func open_store() -> void:
 if not StoreLink.open_listing(RELEASE.data,OS.shell_open,OS.has_feature("android")):
  var dialog := AcceptDialog.new()
  dialog.dialog_text = word("store_error")
  ui.add_child(dialog)
  dialog.popup_centered()
