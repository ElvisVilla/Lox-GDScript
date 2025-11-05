extends RefCounted
class_name LoxEnvironment

var enclosing: LoxEnvironment
var values: Dictionary[StringName, Variant]

func _init(enclosing: LoxEnvironment = null) -> void:
	self.enclosing = enclosing


func getValue(name: Token) -> Variant:
	if values.has(name.lexeme):
		return values.get(name.lexeme)

	# recursively looks up other enclosing Environment
	if enclosing != null: return enclosing.getValue(name)

	var error = RuntimeError.new(name, "'undefined variable ' " + name.lexeme + "'.") # here neither
	push_error(error.to_string())
	return null # This might not be necesary

func assign(name: Token, value):
	if values.has(name.lexeme):
		values.set(name.lexeme, value)
		return

	# recursively looks up other enclosing environment
	if enclosing != null: return enclosing.assign(name, value)

	var error = RuntimeError.new(name, "undefined variable '" + name.lexeme + "'.")
	push_error(error.to_string())
	
func define(name: StringName, value: Variant) -> void:
	values.set(name, value)

func ancestor(distance: int) -> LoxEnvironment:
	var environment = self
	for i in distance:
		environment = environment.enclosing
	
	return environment

func getAt(distance: int, name: String):
	return ancestor(distance).values.get(name)

func assignAt(distance: int, name: Token, value: Variant):
	ancestor(distance).values.set(name.lexeme, value)
