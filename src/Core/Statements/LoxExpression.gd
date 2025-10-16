extends Stmt 
class_name LoxExpression 

var expression: Expr

static func create(expression: Expr):
	var instance = LoxExpression.new()
	instance.expression = expression
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitLoxExpressionStmt(self)

func _to_string() -> String:
	return "%s" % [str(self.expression)]
