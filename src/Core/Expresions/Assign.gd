extends Expr 
class_name Assign 

var name: Token
var value: Expr

static func create(name: Token, value: Expr):
	var instance = Assign.new()
	instance.name = name
	instance.value = value
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitAssignExpr(self)

func _to_string() -> String:
	return "%s %s" % [str(self.name), str(self.value)]
