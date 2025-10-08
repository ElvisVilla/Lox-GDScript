class_name RuntimeError extends RefCounted

var token: Token
var message: String

func _init(token: Token, message: String) -> void:
    self.token = token
    self.message = message

func _to_string() -> String:
    return "RuntimeError at line %d: %s" % [token.line, message]