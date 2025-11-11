extends Stmt 
class_name Var 

var name: Token
var typeHint: Token
var initializer: Expr

static func create(name: Token, typeHint: Token, initializer: Expr):
	var instance = Var.new()
	instance.name = name
	instance.typeHint = typeHint
	instance.initializer = initializer
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitVarStmt(self)

func _to_string() -> String:
	return "%s %s %s" % [str(self.name), str(self.typeHint), str(self.initializer)]
