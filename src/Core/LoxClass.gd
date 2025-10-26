extends LoxCallable
class_name LoxClass

var name: String
var methods: Dictionary

func _init(name: String, methods: Dictionary) -> void:
    self.name = name
    self.methods = methods

func findMethod(name: String) -> LoxFunction:
    return methods.get(name)

func loxCall(interpreter: Interpreter, arguments: Array) -> Variant:
    var instance := LoxInstance.new(self)

    var initializer: LoxFunction = findMethod("init")
    if initializer != null:
        initializer.bind(instance).loxCall(interpreter, arguments)

    return instance

func arity() -> int:
    var initializer := findMethod("init")
    if initializer == null: return 0
    return initializer.arity()


func _to_string() -> String:
    return name
