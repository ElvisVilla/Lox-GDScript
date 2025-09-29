extends Expr 
class_name Binary 

var left: Expr
var operator: Token
var right: Expr

func create(left: Expr, operator: Token, right: Expr):
	self.left = left
	self.operator = operator
	self.right = right
	return self


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitBinaryExpr(self)

func _to_string() -> String:
	return "%s %s %s" % [str(self.left), str(self.operator), str(self.right)]
