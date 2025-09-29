extends Expr 
class_name Grouping 

var expression: Expr

func create(expression: Expr):
	self.expression = expression
	return self


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitGroupingExpr(self)

func _to_string() -> String:
	return "%s" % [str(self.expression)]
