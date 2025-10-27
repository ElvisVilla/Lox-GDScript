extends Stmt
class_name Field

var name: Token
var initializer: Expr

static func create(name: Token, initializer: Expr):
	var instance = Field.new()
	instance.name = name
	instance.initializer = initializer
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitFieldStmt(self)

func _to_string() -> String:
	return "%s %s" % [str(self.name), str(self.initializer)]
