extends Expr 
class_name Grouping 

var expression: Expr

static func create(expression: Expr):
	var instance = Grouping.new()
	instance.expression = expression
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitGroupingExpr(self)

func _to_string() -> String:
	return "%s" % [str(self.expression)]
