extends Resource
class_name GDBraceScript

var source_code: String = ""
var gd_script_path: String = ""

func get_source_code() -> String:
    return source_code

func set_source_code(value: String) -> void:
    source_code = value
    _transpile_and_save()

func _transpile_and_save() -> void:
    if resource_path.is_empty():
        return # Not saved yet

    # Generate the .gd path
    var filename = resource_path.get_file().get_basename()
    gd_script_path = "res://generated/%s.gd" % filename

    # Ensure the generated folder exists
    if not DirAccess.dir_exists_absolute("res://generated"):
        DirAccess.make_dir_absolute("res://generated")

    # Transpile (call your transpiler here)
    var transpiled_code = _transpile(source_code)

    # Save the .gd file
    var file = FileAccess.open(gd_script_path, FileAccess.WRITE)
    if file:
        file.store_string(transpiled_code)
        file.close()
        
        # Refresh the filesystem so Godot sees the new file
        EditorInterface.get_resource_filesystem().scan()
    else:
        push_error("Failed to save generated script: " + gd_script_path)

func _transpile(source: String) -> String:
    # TODO: Call your actual transpiler here
    # For now, placeholder:
    # var code : String = ""
    # code += "extends node"
    # code += ""
    return """
extends Node

# Transpiled from: %s
# TODO: Actual transpilation logic

func _ready():
    print("It does!")
    pass
""" % resource_path