extends ResourceFormatSaver
class_name GDBracesResourceFormatSaver

func _recognize(resource: Resource) -> bool:
	return resource is GDBraceScript
	
func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return PackedStringArray(["braces"])
	
# func _recognize_path(resource: Resource, path: String) -> bool:
# 	var fileExtension = path.get_extension()
# 	var validExtension = _get_recognized_extensions(resource)
# 	for ext in validExtension:
# 		if fileExtension == ext:
# 			return true
	
# 	return false
	
func _save(resource: Resource, path: String, flags: int) -> Error:
	if resource is not GDBraceScript:
		push_error("Resource is not a valid GDBraceScript")
		return ERR_INVALID_PARAMETER

	if not path.ends_with(".braces"):
		path = path.get_basename() + ".braces"

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	file.store_string(resource.source_code)
	file.close()

	resource.take_over_path(path)
	resource._transpile_and_save()

	return OK
