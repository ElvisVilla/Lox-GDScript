@abstract
extends RefCounted
class_name LoxCallable


@abstract func arity() -> int
@abstract func loxCall(interpreter: Interpreter, arguments: Array) -> Variant
