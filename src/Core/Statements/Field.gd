extends Stmt 
class_name Field 

var name: Token
var typeHint: Token
var initializer: Expr
var getter: Array[Stmt]
var setter: Array[Stmt]
var valueParameter: Token

static func create(name: Token, typeHint: Token, initializer: Expr, getter: Array[Stmt], setter: Array[Stmt], valueParameter: Token):
	var instance = Field.new()
	instance.name = name
	instance.typeHint = typeHint
	instance.initializer = initializer
	instance.getter = getter
	instance.setter = setter
	instance.valueParameter = valueParameter
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitFieldStmt(self)

func _to_string() -> String:
	return "%s %s %s %s %s %s" % [str(self.name), str(self.typeHint), str(self.initializer), str(self.getter), str(self.setter), str(self.valueParameter)]
