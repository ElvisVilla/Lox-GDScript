extends Expr 
class_name Unary 

var operator: Token
var right: Expr

func create(operator: Token, right: Expr):
	self.operator = operator
	self.right = right

func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitUnaryExpr(self)
