extends Expr 
class_name Call 

var callee: Expr
var paren: Token
var arguments: Array[Expr]

static func create(callee: Expr, paren: Token, arguments: Array[Expr]):
	var instance = Call.new()
	instance.callee = callee
	instance.paren = paren
	instance.arguments = arguments
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitCallExpr(self)

func _to_string() -> String:
	return "%s %s %s" % [str(self.callee), str(self.paren), str(self.arguments)]
