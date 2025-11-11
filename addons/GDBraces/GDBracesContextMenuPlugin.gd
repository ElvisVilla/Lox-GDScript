extends EditorContextMenuPlugin
class_name GDBracesContextMenuPlugin

var icon: Texture2D = preload("res://icon.svg")

func _popup_menu(paths: PackedStringArray) -> void:
    if paths.is_empty():
        add_context_menu_item("New GDBraces", createGDBraceScript, icon)

    else:
        add_context_menu_item("GDBraces", createGDBraceScript, icon)

func createGDBraceScript(paths):
    var dialog = EditorFileDialog.new()
    dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
    dialog.add_filter("*.braces", "GDBraceScript")
    print(paths)
    dialog.file_selected.connect(_on_file_selected)
    EditorInterface.get_base_control().add_child(dialog)
    dialog.popup_centered_ratio(0.5)

func _on_file_selected(path: String):
    var resource = GDBraceScript.new()
    resource.source_code = "extends Node\n"
    resource.take_over_path(path)

    var err = ResourceSaver.save(resource, path)
    if err == OK:
        EditorInterface.get_resource_filesystem().scan()
        EditorInterface.edit_resource(resource)
    else:
        push_error("Failed to create GDBraceScript: " + str(err))

func editGDBraceScript():
    pass