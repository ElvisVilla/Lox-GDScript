extends Expr
class_name Variable

var name: Token

static func create(name: Token):
	var instance = Variable.new()
	instance.name = name
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitVariableExpr(self)

func _to_string() -> String:
	return "%s" % [str(self.name)]
