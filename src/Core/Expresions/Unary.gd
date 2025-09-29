extends Expr 
class_name Unary 

var operator: Token
var right: Expr

func create(operator: Token, right: Expr):
	self.operator = operator
	self.right = right
	return self


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitUnaryExpr(self)

func _to_string() -> String:
	return "%s %s" % [str(self.operator), str(self.right)]
