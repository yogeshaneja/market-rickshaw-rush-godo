extends SceneTree
func _initialize() -> void:
 var file := FileAccess.open("res://docs/licenses/GODOT.txt",FileAccess.WRITE)
 file.store_string(Engine.get_license_text())
 file.close()
 file = FileAccess.open("res://docs/licenses/THIRD-PARTY.json",FileAccess.WRITE)
 file.store_string(JSON.stringify({"copyright":Engine.get_copyright_info(),"licenses":Engine.get_license_info()},"  "))
 file.close()
 print("Engine license and third-party notices written")
 quit()
