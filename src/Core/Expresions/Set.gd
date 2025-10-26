extends Expr 
class_name Set 

var object: Expr
var name: Token
var value: Expr

static func create(object: Expr, name: Token, value: Expr):
	var instance = Set.new()
	instance.object = object
	instance.name = name
	instance.value = value
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitSetExpr(self)

func _to_string() -> String:
	return "%s %s %s" % [str(self.object), str(self.name), str(self.value)]
