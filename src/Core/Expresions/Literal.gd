extends Expr 
class_name Literal 

var value: Object

func create(value: Object):
	self.value = value

func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitLiteralExpr(self)
