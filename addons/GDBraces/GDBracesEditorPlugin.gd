#GDBracesEditorPlugin.gd
@tool
extends EditorPlugin


const GDBraceScript = preload("res://addons/GDBraces/GDBraceScript.gd")
var contextMenu = GDBracesContextMenuPlugin.new()
var addScriptInspectorPlugin = GDBracesInspectorPlugin.new()

var loader: GDBracesResourceFormatLoader = GDBracesResourceFormatLoader.new()
var saver: GDBracesResourceFormatSaver = GDBracesResourceFormatSaver.new()
var editor_instance: Control
var watched_resources = {}
var use_external: bool
var current_script: GDBraceScript:
	set(value):
		if current_script != value:
			current_script = value
			current_script_changed.emit()

signal current_script_changed

func _enter_tree():
	register_resource_formats()
	var file_system = EditorInterface.get_resource_filesystem()
	file_system.filesystem_changed.connect(_on_filesystem_changed)

	add_tool_menu_item("Create GDBraceScript", _create_new_script)

	add_context_menu_plugin(
		EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM_CREATE,
		contextMenu
	)

	add_inspector_plugin(addScriptInspectorPlugin)

func _exit_tree():
	ResourceLoader.remove_resource_format_loader(loader)
	ResourceSaver.remove_resource_format_saver(saver)

	if editor_instance:
		editor_instance.queue_free()
	
	remove_context_menu_plugin(contextMenu)
	remove_inspector_plugin(addScriptInspectorPlugin)

func _on_filesystem_changed():
	register_resource_formats()

func register_resource_formats():
	ResourceSaver.remove_resource_format_saver(saver)
	ResourceLoader.remove_resource_format_loader(loader)

	ResourceSaver.add_resource_format_saver(saver)
	ResourceLoader.add_resource_format_loader(loader)

func _handles(object) -> bool:
	return object is GDBraceScript

func _create_new_script():
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	dialog.add_filter("*.braces", "GDBraceScript")
	dialog.file_selected.connect(_on_file_selected)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.5)

func _on_file_selected(path: String):
	var resource = GDBraceScript.new()
	resource.source_code = "# New GDBraces script\n"
	# resource.take_over_path(path)

	var err = ResourceSaver.save(resource, path)
	if err == OK:
		EditorInterface.get_resource_filesystem().scan()
		# EditorInterface.edit_resource(resource)
	else:
		push_error("Failed to create script: " + str(err))

func _edit(object):
	if object is GDBraceScript:
		use_external = EditorInterface.get_editor_settings().get_setting("text_editor/external/use_external_editor")
		
		current_script = object
		var path = object.resource_path
		watched_resources
		
		_open_in_external_editor(object)
		_open_in_script_editor(object)

func _open_in_script_editor(resource: GDBraceScript):
	if not editor_instance:
		editor_instance = _create_editor()
		EditorInterface.get_editor_main_screen().add_child(editor_instance)
	
	_make_visible(true)
	
func _open_in_external_editor(resource: GDBraceScript):
	var path = ProjectSettings.globalize_path(resource.resource_path)
	OS.shell_open(path)

func _create_editor() -> Control:
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var code_edit = CodeEdit.new()
	code_edit.text = current_script.source_code
	code_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	code_edit.syntax_highlighter = GDScriptSyntaxHighlighter.new()
	
	code_edit.text_changed.connect(func():
		current_script.source_code = code_edit.text
	)

	current_script_changed.connect(func():
		code_edit.text = current_script.source_code
	)
	
	container.add_child(code_edit)
	return container

func _make_visible(visible: bool):
	if editor_instance:
		editor_instance.visible = visible

func _get_plugin_name() -> String:
	return "GDBraces"
