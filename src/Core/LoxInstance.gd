extends RefCounted
class_name LoxInstance

var klass: LoxClass
var fields: Dictionary[String, Variant]

func _init(klass: LoxClass) -> void:
    self.klass = klass

func getValue(name: Token):
    if fields.has(name.lexeme):
        return fields.get(name.lexeme)
    
    var method: LoxFunction = klass.findMethod(name.lexeme)
    if method != null: return method.bind(self)

    var error = RuntimeError.new(name, "Undefined property '" + name.lexeme + "'.")
    push_error(error)

func setValue(name: Token, value: Variant):
    fields.set(name.lexeme, value)

func _to_string() -> String:
    return klass.name + " instance"
