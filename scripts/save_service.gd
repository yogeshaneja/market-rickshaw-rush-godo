extends RefCounted
var save_path: String

func _init(path: String = "user://market_rickshaw_v1.json") -> void:
 save_path = path
var recovered := false
var failed := false

func defaults() -> Dictionary:
 return {"version":1,"language":"en","reduce_effects":false,"scores":[0,0,0],"route":0,"festival":0,"evening":false,"skin":0,"music_on":true,"sfx_on":true,"music_volume":0.25,"sfx_volume":0.4}

func validate(value: Variant) -> Dictionary:
 if not value is Dictionary or value.get("version") != 1 or value.get("language") not in ["en","hi"] or not value.get("reduce_effects") is bool:
  recovered = true
  return defaults()
 var scores: Variant = value.get("scores")
 if not scores is Array or scores.size() != 3:
  recovered = true
  return defaults()
 for score in scores:
  if not (score is int or score is float) or not is_finite(float(score)) or score < 0 or score > 100000000 or floorf(float(score)) != float(score):
   recovered = true
   return defaults()
 var result := defaults()
 result.language = value.language
 result.reduce_effects = value.reduce_effects
 result.scores = [int(scores[0]),int(scores[1]),int(scores[2])]
 # Migrate legacy v1 files by filling optional cosmetics/audio fields, preserving scores.
 for key in ["route","festival","skin"]:
  var number: Variant = value.get(key,0)
  if (number is int or number is float) and is_finite(float(number)) and floorf(float(number))==float(number) and number>=0 and number<=2:
   result[key] = int(number)
 for key in ["evening","music_on","sfx_on"]:
  if value.get(key) is bool: result[key] = value[key]
 for key in ["music_volume","sfx_volume"]:
  var number: Variant = value.get(key,result[key])
  if (number is int or number is float) and is_finite(float(number)) and number>=0 and number<=1:
   result[key] = float(number)
 if not skin_unlocked(result,result.skin): result.skin = 0
 return result

func load_data() -> Dictionary:
 if not FileAccess.file_exists(save_path):
  return defaults()
 var file := FileAccess.open(save_path, FileAccess.READ)
 if file == null:
  failed = true
  return defaults()
 return validate(JSON.parse_string(file.get_as_text()))

func save_data(data: Dictionary) -> bool:
 var path := save_path + ".tmp"
 var file := FileAccess.open(path, FileAccess.WRITE)
 if file == null:
  failed = true
  return false
 file.store_string(JSON.stringify(data))
 file.flush()
 var write_error := file.get_error()
 file.close()
 if write_error != OK:
  failed = true
  return false
 var err := DirAccess.rename_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(save_path))
 failed = err != OK
 return not failed

func reset_scores(data: Dictionary) -> Dictionary:
 var result := data.duplicate(true)
 result.scores = [0,0,0]
 return result

func skin_unlocked(data: Dictionary, skin: int) -> bool:
 if skin < 0 or skin > 2: return false
 return int(data.scores.max()) >= [0,300,800][skin]
