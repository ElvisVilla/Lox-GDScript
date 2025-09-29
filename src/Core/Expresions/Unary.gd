extends Expr 
class_name Unary 

var operator: Token
var right: Expr

static func create(operator: Token, right: Expr):
	var instance = Unary.new()
	instance.operator = operator
	instance.right = right
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitUnaryExpr(self)

func _to_string() -> String:
	return "%s %s" % [str(self.operator), str(self.right)]
