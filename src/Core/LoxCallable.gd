@abstract
extends RefCounted
class_name LoxCallable


## Count for optional parameters that doesnt contains default values
@abstract func minArity() -> int
@abstract func arity() -> int
@abstract func loxCall(interpreter: Interpreter, arguments: Array) -> Variant
