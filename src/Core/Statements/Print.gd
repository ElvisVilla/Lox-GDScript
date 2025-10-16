extends Stmt 
class_name Print 

var expression: Expr

static func create(expression: Expr):
	var instance = Print.new()
	instance.expression = expression
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitPrintStmt(self)

func _to_string() -> String:
	return "%s" % [str(self.expression)]
