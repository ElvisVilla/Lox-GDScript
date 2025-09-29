extends Expr 
class_name Literal 

var value: Variant

func create(value: Variant):
	self.value = value
	return self


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitLiteralExpr(self)

func _to_string() -> String:
	return "%s" % [str(self.value)]
