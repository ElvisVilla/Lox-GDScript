extends Stmt 
class_name Class 

var name: Token
var superclass: Variable
var fields: Array[Field]
var methods: Array[Function]

static func create(name: Token, superclass: Variable, fields: Array[Field], methods: Array[Function]):
	var instance = Class.new()
	instance.name = name
	instance.superclass = superclass
	instance.fields = fields
	instance.methods = methods
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitClassStmt(self)

func _to_string() -> String:
	return "%s %s %s %s" % [str(self.name), str(self.superclass), str(self.fields), str(self.methods)]
