extends LoxCallable
class_name LoxClass

var name: String
var methods: Dictionary
var superclass: LoxClass

func _init(name: String, superclass: LoxClass, methods: Dictionary) -> void:
    self.name = name
    self.superclass = superclass
    self.methods = methods

func findMethod(name: String) -> LoxFunction:
    if methods.has(name):
        return methods.get(name)

    if superclass != null:
        return superclass.findMethod(name)

    return null

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
