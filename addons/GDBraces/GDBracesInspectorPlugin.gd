extends EditorInspectorPlugin
class_name GDBracesInspectorPlugin

var createScriptProperty = load("/Users/bissash/Documents/Software Development/Godot Engine/GDBraces/addons/GDBraces/CreateScriptProperty.tscn")

func _can_handle(object: Object) -> bool:
    return object is Node

func _parse_begin(object: Object) -> void:
    # add_custom_control(createScriptProperty.instantiate())
    var editor = BraceScriptNodeEditor.new()
    editor.setup(object as Node)
    add_custom_control(editor)

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
    if type == TYPE_OBJECT and hint_string == "GDBraceScript":
        add_property_editor(name, BraceScriptPropertyEditor.new())
        return true
    return false


# Custom control for script assignment in Node
class BraceScriptNodeEditor extends HBoxContainer:
    var braceScript: StringName = &"script"
    var target_node: Node
    var current_braces_path: String
    var current_value: GDBraceScript
    var file_dialog: EditorFileDialog
    var save_dialog: EditorFileDialog
    var hbox: HBoxContainer
    var text: Label
    var load_button: Button
    var clear_button: Button
    var create_button: Button

    func setup(node: Node):
        target_node = node
        loadFromMeta()
        updateLabel()

    func _init():
        hbox = HBoxContainer.new()
        add_child(hbox)

        text = Label.new()
        text.text = "[empty]"
        text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        hbox.add_child(text)

        load_button = Button.new()
        load_button.text = "Load"
        load_button.pressed.connect(_on_load_pressed)
        hbox.add_child(load_button)

        create_button = Button.new()
        create_button.text = "Create"
        create_button.pressed.connect(_on_create_pressed)
        hbox.add_child(create_button)

        clear_button = Button.new()
        clear_button.text = "Clear"
        clear_button.pressed.connect(_on_clear_pressed)
        hbox.add_child(clear_button)

        file_dialog = EditorFileDialog.new()
        file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
        file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
        file_dialog.add_filter("*.braces", "GDBraceScripts")
        file_dialog.file_selected.connect(_on_file_selected)
        add_child(file_dialog)

        save_dialog = EditorFileDialog.new()
        save_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
        save_dialog.access = EditorFileDialog.ACCESS_RESOURCES
        save_dialog.add_filter("*.braces", "GDBraceScript")
        save_dialog.file_selected.connect(_on_create_file)
        add_child(save_dialog)

        set_drag_forwarding(Callable(), _can_drop_data_fw, _drop_data_fw)

    func _can_drop_data_fw(at_position: Vector2, data: Variant) -> bool:
        if typeof(data) == TYPE_DICTIONARY and data.has("files"):
            var files = data["files"]
            if files.size() == 1 and files[0].get_extension() == "braces":
                return true
        return false

    func _drop_data_fw(at_position: Vector2, data: Variant) -> void:
        if typeof(data) == TYPE_DICTIONARY and data.has("files"):
            var path = data["files"][0]
            assignBraceScript(path)
	

    func loadFromMeta():
        if target_node.has_meta(braceScript):
            current_braces_path = target_node.get_meta(braceScript, "")

    func updateLabel():
        if current_braces_path:
            text.text = current_braces_path.get_file()
        else:
            text.text = "[emptysh]"

    func _on_load_pressed():
        file_dialog.popup_centered_ratio(0.5)

    func _on_file_selected(path: String):
        assignBraceScript(path)

    func _on_clear_pressed():
        target_node.remove_meta(braceScript)
        current_braces_path = ""

        target_node.set_script(null)
        updateLabel()

    func _on_create_pressed():
        save_dialog.popup_centered_ratio(0.5)

    func _on_create_file(path: String):
        if not path.ends_with(".braces"):
            path += ".braces"
        
        var new_script = GDBraceScript.new()
        new_script.source_code = "" # or some template code
        
        var err = ResourceSaver.save(new_script, path)
        if err == OK:
            EditorInterface.get_resource_filesystem().scan()
            assignBraceScript(path)
        else:
            push_error("Failed to create .braces file with error: " + str(err))
    
    func assignBraceScript(path: String):
        target_node.set_meta(braceScript, path)
        current_braces_path = path

        var filename = path.get_file().get_basename()
        var gd_path = "res://generated/%s.gd" % filename

        if FileAccess.file_exists(gd_path):
            var gd_script = load(gd_path)
            print(gd_path)
            if gd_script:
                target_node.set_script(gd_script)
            else:
                push_error("Failed to load generated script %s" % gd_path)
        else:
            push_warning("Generated script doesn't exist yet %s" % gd_path)

        updateLabel()


# Custom property editor for GDBraceScript
class BraceScriptPropertyEditor extends EditorProperty:
    var braceScript: StringName = &"script"
    var target_node: Node
    var current_braces_path: String
    var current_value: GDBraceScript
    var file_dialog: EditorFileDialog
    var save_dialog: EditorFileDialog
    var hbox: HBoxContainer
    var text: Label
    var load_button: Button
    var clear_button: Button
    var create_button: Button

    func setup(node: Node):
        target_node = node
        loadFromMeta()
        updateLabel()

    func _init():
        hbox = HBoxContainer.new()
        add_child(hbox)

        text = Label.new()
        text.text = "[empty]"
        # text.custom_minimum_size.x = 150
        text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        hbox.add_child(text)

        load_button = Button.new()
        load_button.text = "Load"
        load_button.pressed.connect(_on_load_pressed)
        hbox.add_child(load_button)

        create_button = Button.new()
        create_button.text = "Create"
        create_button.pressed.connect(_on_create_pressed)
        hbox.add_child(create_button)

        clear_button = Button.new()
        clear_button.text = "Clear"
        clear_button.pressed.connect(_on_clear_pressed)
        hbox.add_child(clear_button)

        file_dialog = EditorFileDialog.new()
        file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
        file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
        file_dialog.add_filter("*.braces", "GDBraceScripts")
        file_dialog.file_selected.connect(_on_file_selected)
        add_child(file_dialog)

        save_dialog = EditorFileDialog.new()
        save_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
        save_dialog.access = EditorFileDialog.ACCESS_RESOURCES
        save_dialog.add_filter("*.braces", "GDBraceScript")
        save_dialog.file_selected.connect(_on_create_file)
        add_child(save_dialog)

        set_drag_forwarding(Callable(), _can_drop_data_fw, _drop_data_fw)

    func _can_drop_data_fw(at_position: Vector2, data: Variant) -> bool:
        if typeof(data) == TYPE_DICTIONARY and data.has("files"):
            var files = data["files"]
            if files.size() == 1 and files[0].get_extension() == "braces":
                return true
        return false

    func _drop_data_fw(at_position: Vector2, data: Variant) -> void:
        if typeof(data) == TYPE_DICTIONARY and data.has("files"):
            var path = data["files"][0]
            var resource = load(path)
            if resource is GDBraceScript:
                emit_changed(get_edited_property(), resource)
	
    func _update_property():
        var new_value = get_edited_object()[get_edited_property()]
        if new_value != current_value:
            current_value = new_value
            updateLabel()

    func loadFromMeta():
        current_braces_path = target_node.get_meta(braceScript)

    func updateLabel():
        if current_value:
            text.text = current_value.resource_path.get_file()
        else:
            text.text = "[empty]"

    func _on_load_pressed():
        file_dialog.popup_centered_ratio(0.5)

    func _on_file_selected(path: String):
        var resource = load(path)
        if resource is GDBraceScript:
            emit_changed(get_edited_property(), resource)

    func _on_clear_pressed():
        emit_changed(get_edited_property(), null)

    func _on_create_pressed():
        save_dialog.popup_centered_ratio(0.5)

    func _on_create_file(path: String):
        if not path.ends_with(".braces"):
            path += ".braces"
        
        var new_script = GDBraceScript.new()
        new_script.source_code = "" # or some template code
        
        var err = ResourceSaver.save(new_script, path)
        if err == OK:
            # Reload to get proper resource_path set
            var loaded = load(path)
            emit_changed(get_edited_property(), loaded)
            
            # Refresh filesystem
            EditorInterface.get_resource_filesystem().scan()
        else:
            push_error("Failed to create .braces file: " + str(err))


    # var background = PanelContainer.new()
    # # var stylebox = backgorund.get_theme_stylebox("panel", "normal") as StyleBoxFlat
    # var stylebox = StyleBoxFlat.new()
    # stylebox.set_corner_radius_all(8)
    # # stylebox.set_content_margin_all(8)
    # stylebox.set("bg_color", Color('165450'))
    # background.add_theme_stylebox_override("panel", stylebox)
    # background.set_anchors_preset(Control.PRESET_FULL_RECT)
    # background.custom_minimum_size = Vector2(0.0, 60)
    # var label = Label.new()
    # # label.bbcode_enabled
    # # label.scroll_active = false
    # label.text = "GDBraceScript"
    # label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    # # label.add_theme_font_override("font", BOLD_FONT)
    # label.set_anchors_preset(Control.PRESET_FULL_RECT)
    # background.add_child(label)
    # # # var addScriptButton = Button.new()
    # # # addScriptButton.icon = load("res://addons/create_script_icon.svg")
    # # # addScriptButton.text = "Add Script"
    # # # addScriptButton.expand_icon = true
    # # # var create_script = load("res://addons/GDBraces/CreateScriptProperty.tscn")
    # add_custom_control(background)


#     if object is Control:
# #         for modifier in uidefinition.definition.modifiers:
# #             var property = UIDefinitionProperty.new()
# #             add_property_editor(modifier, property, false, modifier)
