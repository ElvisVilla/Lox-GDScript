# extends LoxCallable
# class_name LoxFunction

# var declaration: Function

# func _init(declaration: Function) -> void:
# 	self.declaration = declaration

# func arity() -> int:
# 	return declaration.params.size()

# func loxCall(interpreter: Interpreter, arguments: Array) -> Variant:
# 	var environment := LoxEnvironment.new(interpreter.globals)
# 	for index in declaration.params.size():
# 		environment.define(declaration.params[index].lexeme, arguments[index])
# 	interpreter.executeBlock(declaration.body, environment)
		
# 	return null

# func _to_string() -> String:
# 	return "<fn %s>" % declaration.name.lexeme

# Testing this
extends LoxCallable
class_name LoxFunction

var declaration: Function
var closure: LoxEnvironment

func _init(declaration: Function, closure: LoxEnvironment) -> void:
	self.declaration = declaration
	self.closure = closure

func arity() -> int:
	return declaration.params.size()

func loxCall(interpreter: Interpreter, arguments: Array) -> Variant:
	var environment := LoxEnvironment.new(closure)
	for index in declaration.params.size():
		environment.define(declaration.params[index].lexeme, arguments[index])
	
	interpreter.has_returned = false
	interpreter.executeBlock(declaration.body, environment)

	var result = interpreter.return_value
	interpreter.has_returned = false # Reset after getting value
	return result

func _to_string() -> String:
	return "<fn %s>" % declaration.name.lexeme