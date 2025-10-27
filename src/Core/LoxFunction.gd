extends LoxCallable
class_name LoxFunction

var declaration: Function
var closure: LoxEnvironment
var isInitiazer: bool

func _init(declaration: Function, closure: LoxEnvironment, isInitiazer: bool) -> void:
	self.declaration = declaration
	self.closure = closure
	self.isInitiazer = isInitiazer

func bind(instance: LoxInstance):
	var environment := LoxEnvironment.new(closure)
	environment.define("self", instance)
	return LoxFunction.new(declaration, environment, isInitiazer)

func arity() -> int:
	return declaration.params.size()

func loxCall(interpreter: Interpreter, arguments: Array) -> Variant:
	var environment := LoxEnvironment.new(closure)
	for index in declaration.params.size():
		environment.define(declaration.params[index].lexeme, arguments[index])
	
	interpreter.has_returned = false
	interpreter.executeBlock(declaration.body, environment)

	if isInitiazer: return closure.getAt(0, "self")
	var result = interpreter.return_value
	interpreter.has_returned = false # Reset after getting value
	if isInitiazer: return closure.getAt(0, "self")
	return result

func _to_string() -> String:
	return "<fn %s>" % declaration.name.lexeme
