extends Stmt 
class_name Class 

var name: Token
var superclass: Variable
var methods: Array[Function]

static func create(name: Token, superclass: Variable, methods: Array[Function]):
	var instance = Class.new()
	instance.name = name
	instance.superclass = superclass
	instance.methods = methods
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitClassStmt(self)

func _to_string() -> String:
	return "%s %s %s" % [str(self.name), str(self.superclass), str(self.methods)]
