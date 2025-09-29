extends Expr 
class_name Literal 

var value: Variant

static func create(value: Variant):
	var instance = Literal.new()
	instance.value = value
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitLiteralExpr(self)

func _to_string() -> String:
	return "%s" % [str(self.value)]
