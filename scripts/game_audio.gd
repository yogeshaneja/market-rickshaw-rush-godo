extends Node
# Original bundled synthesis only. Fixed player count: music, ambience and three SFX.
const MUSIC = preload("res://assets/audio/bazaar-loop.ogg")
const AIR = preload("res://assets/audio/market-air.ogg")
const SOUNDS = {"coin":preload("res://assets/audio/coin.ogg"),"bell":preload("res://assets/audio/rickshaw-bell.ogg"),"end":preload("res://assets/audio/run-end.ogg")}
var music := AudioStreamPlayer.new()
var air := AudioStreamPlayer.new()
var voices: Array[AudioStreamPlayer] = []
var prefs: Dictionary
var active := false
var focused := true
var started := false
var preview_left := 0.0
var loop_positions := [0.0,0.0]

func _ready() -> void:
 music.stream = MUSIC.duplicate()
 music.stream.loop = true
 air.stream = AIR.duplicate()
 air.stream.loop = true
 add_child(music)
 add_child(air)
 for i in range(3):
  var voice := AudioStreamPlayer.new()
  add_child(voice)
  voices.append(voice)

func configure(value: Dictionary) -> void:
 prefs = value.duplicate(true)
 music.volume_db = linear_to_db(maxf(0.0001,float(prefs.music_volume)))
 air.volume_db = linear_to_db(maxf(0.0001,float(prefs.sfx_volume)*0.5))
 for voice in voices:
  voice.volume_db = linear_to_db(maxf(0.0001,float(prefs.sfx_volume)))
  if not prefs.sfx_on or float(prefs.sfx_volume) == 0.0: voice.stop()
 sync()

func set_active(value: bool) -> void:
 active = value
 if active: started = true
 if not active:
  for voice in voices: voice.stop()
 sync()

func set_focused(value: bool) -> void:
 focused = value
 if not focused:
  preview_left = 0.0
  for voice in voices: voice.stop()
 sync()

func preview() -> void:
 if not focused: return
 started = true
 preview_left = 4.0
 sync()
 cue("bell",true)

func cancel_preview() -> void:
 preview_left = 0.0
 sync()

func _process(delta: float) -> void:
 if preview_left > 0.0:
  preview_left = maxf(0.0,preview_left-delta)
  if preview_left == 0.0: sync()

func sync() -> void:
 if prefs.is_empty(): return
 var permitted := started and focused and (active or preview_left > 0.0)
 var play_music: bool = permitted and prefs.music_on and float(prefs.music_volume)>0.0
 var play_air: bool = permitted and active and prefs.sfx_on and float(prefs.sfx_volume)>0.0
 for i in range(2):
  var player: AudioStreamPlayer = music if i == 0 else air
  var permitted_loop: bool = play_music if i == 0 else play_air
  if permitted_loop:
   if not player.playing: player.play(float(loop_positions[i]))
  elif player.playing:
   loop_positions[i] = player.get_playback_position()
   player.stop()

func cue(key: String, allow_preview: bool = false) -> void:
 if prefs.is_empty() or not focused or not prefs.sfx_on or float(prefs.sfx_volume)<=0.0: return
 if not active and not (allow_preview and preview_left>0.0) and not (key=="end" and started): return
 if not SOUNDS.has(key): return
 for voice in voices:
  if not voice.playing:
   voice.stream = SOUNDS[key]
   voice.play()
   return
 # Drop excess feedback instead of allocating an unbounded sound player.

func _exit_tree() -> void:
 # Unpause before stop so the mixer can release paused Ogg playback references.
 music.stream_paused = false
 air.stream_paused = false
 music.stop()
 air.stop()
 music.stream = null
 air.stream = null
 for voice in voices:
  voice.stop()
  voice.stream = null
