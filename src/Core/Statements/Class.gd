extends Stmt 
class_name Class 

var name: Token
var methods: Array[Function]

static func create(name: Token, methods: Array[Function]):
	var instance = Class.new()
	instance.name = name
	instance.methods = methods
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitClassStmt(self)

func _to_string() -> String:
	return "%s %s" % [str(self.name), str(self.methods)]
