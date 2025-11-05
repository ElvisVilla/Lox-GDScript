extends Node

@export var node2D: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Lox.main("res://code.txt")
