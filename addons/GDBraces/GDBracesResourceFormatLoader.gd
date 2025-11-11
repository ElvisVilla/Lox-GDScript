extends ResourceFormatLoader
class_name GDBracesResourceFormatLoader

func _handles_type(type: StringName) -> bool:
	print("type being passed is: ", str(type))
	return type == "GDBraceScript"
	
func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["braces"])
	
# func _recognize_path(path: String, type: StringName) -> bool:
# 	var fileExtension = path.get_extension()
# 	var validExtension = _get_recognized_extensions()
# 	for ext in validExtension:
# 		if fileExtension == ext:
# 			return true
	
# 	return false

func _get_resource_type(path: String) -> String:
	if path.get_extension() == "braces":
		return "GDBraceScript"

	return ""

func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open %s" % path)
		return null

	var source := file.get_as_text()
	file.close()

	var resource := GDBraceScript.new()
	resource.source_code = source
	resource.resource_path = path
	return resource
