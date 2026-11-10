extends RefCounted
var save_path: String

func _init(path: String = "user://market_rickshaw_v1.json") -> void:
 save_path = path
var recovered := false
var failed := false

func defaults() -> Dictionary:
 return {"version":1,"language":"en","reduce_effects":false,"scores":[0,0,0]}

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
 return {"version":1,"language":value.language,"reduce_effects":value.reduce_effects,"scores":[int(scores[0]),int(scores[1]),int(scores[2])]}

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
