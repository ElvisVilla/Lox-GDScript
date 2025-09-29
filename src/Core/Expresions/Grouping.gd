extends Expr 
class_name Grouping 

var expression: Expr

func create(expression: Expr):
	self.expression = expression

func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitGroupingExpr(self)
