extends RefCounted
class_name Parameter

var name: Token
var typeHint: Token # can be null if type is not specified
var defaultValue: Expr # can be null if no default value

func _init(name: Token, typeHint: Token, initializer: Expr) -> void:
	self.name = name
	self.typeHint = typeHint
	self.defaultValue = initializer

func _to_string() -> String:
	return "%s %s %s" % [self.name, self.typeHint, self.defaultValue]
