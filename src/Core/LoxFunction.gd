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


func minArity() -> int:
	var required = 0
	for param in declaration.params:
		#Apply param as required if is null, other wise is count as optional
		if param.defaultValue == null:
			required += 1
	return required

func arity() -> int:
	return declaration.params.size()

func loxCall(interpreter: Interpreter, arguments: Array) -> Variant:
	var environment := LoxEnvironment.new(closure)
	var params = declaration.params

	for index in params.size():
		var param: Parameter = params[index]

		# To handle optional parameters
		if index < arguments.size():
			environment.define(param.name.lexeme, arguments[index])
		elif param.defaultValue != null:
			var defaultValue = interpreter.evaluate(param.defaultValue)
			environment.define(param.name.lexeme, defaultValue)
		else:
			var error = RuntimeError.new(param.name, "Missing required parameter: %s." % param.name.lexeme)
			push_error(error)


	interpreter.has_returned = false
	interpreter.executeBlock(declaration.body, environment)

	if isInitiazer: return closure.getAt(0, "self")
	var result = interpreter.return_value
	interpreter.has_returned = false # Reset after getting value
	if isInitiazer: return closure.getAt(0, "self")
	return result

func _to_string() -> String:
	return "<fn %s>" % declaration.name.lexeme
