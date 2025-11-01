extends LoxCallable
class_name LoxClass

var name: String
var superclass: LoxClass
var fields: Dictionary
var methods: Dictionary

func _init(name: String, superclass: LoxClass, fields: Dictionary, methods: Dictionary) -> void:
	self.name = name
	self.superclass = superclass
	self.fields = fields
	self.methods = methods

func findMethod(name: String) -> LoxFunction:
	if methods.has(name):
		return methods.get(name)

	if superclass != null:
		return superclass.findMethod(name)

	return null

func loxCall(interpreter: Interpreter, arguments: Array) -> Variant:
	var instance := LoxInstance.new(self)

	# This is giving error
	for fieldName in fields:
		var fieldDeclaration = fields[fieldName]
		var value = null
		if fieldDeclaration.initializer != null:
			value = interpreter.evaluate(fieldDeclaration.initializer)
		instance.fields.set(fieldName, value)

	var initializer: LoxFunction = findMethod("init")
	if initializer != null:
		initializer.bind(instance).loxCall(interpreter, arguments)

	return instance

func arity() -> int:
	var initializer := findMethod("init")
	if initializer == null: return 0
	return initializer.arity()

func minArity() -> int:
	var initializer := findMethod("init")
	
	if initializer == null:
		return 0

	var required = 0
	for param in initializer.declaration.params:
		if param.defaultValue == null:
			required += 1
	return required


func _to_string() -> String:
	return name
