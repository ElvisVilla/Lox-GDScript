extends Expr 
class_name Binary 

var left: Expr
var operator: Token
var right: Expr

static func create(left: Expr, operator: Token, right: Expr):
	var instance = Binary.new()
	instance.left = left
	instance.operator = operator
	instance.right = right
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitBinaryExpr(self)

func _to_string() -> String:
	return "%s %s %s" % [str(self.left), str(self.operator), str(self.right)]
