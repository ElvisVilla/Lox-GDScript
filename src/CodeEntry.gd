extends Node

@export var area2D: Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Lox.main("res://code.txt")
