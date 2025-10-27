extends Node

var source = "Hello world"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Lox.main("res://code.txt")
