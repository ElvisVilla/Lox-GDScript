@tool
extends MarginContainer
class_name CreateScriptProperty

enum State {
	CREATE,
	ATTACHED_SCRIPT,
	REMOVE_SCRIPT,
	EXTENDS_SCRIPT,
}
signal StateChanged
@export var state: State:
	set(value):
		if state != value:
			state = value
			StateChanged.emit()

var icons: Dictionary = {
	State.CREATE: "res://addons/icons/ScriptCreate.svg",
	State.ATTACHED_SCRIPT: "res://addons/icons/Script.svg",
	State.REMOVE_SCRIPT: "res://addons/icons/ScriptRemove.svg",
	State.EXTENDS_SCRIPT: "res://addons/icons/ScriptExtend.svg",
}

@export var background: PanelContainer
@export var label: Label
@export var textureRect: TextureRect
@export var scrp: GDBraceScript

func _ready():
	state = State.EXTENDS_SCRIPT
	StateChanged.connect(UpdateState)

func UpdateState():
	match state:
		State.CREATE:
			showCreateScript()
		State.ATTACHED_SCRIPT:
			showAttachedScript()
		State.REMOVE_SCRIPT:
			showRemoveScript()
		State.EXTENDS_SCRIPT:
			showExtendsScript()

func showCreateScript():
	var stylebox = background.get("theme_override_styles/panel")
	stylebox.set("bg_color", Color('1a1a1a99'))
	# label.text = "Create Script"
	textureRect.texture = load(icons.get(State.CREATE))

func showAttachedScript():
	var stylebox = background.get("theme_override_styles/panel")
	stylebox.set("bg_color", Color('165450'))
	# label.text = "ScriptName"
	textureRect.texture = load(icons.get(State.ATTACHED_SCRIPT))

func showRemoveScript():
	var stylebox = background.get("theme_override_styles/panel")
	stylebox.set("bg_color", Color('165450'))
	# label.text = "ScriptName"
	textureRect.texture = load(icons.get(State.REMOVE_SCRIPT))

func showExtendsScript():
	var stylebox = background.get("theme_override_styles/panel")
	stylebox.set("bg_color", Color('165450'))

	# label.text = "With Script"
	textureRect.texture = load(icons.get(State.EXTENDS_SCRIPT))
