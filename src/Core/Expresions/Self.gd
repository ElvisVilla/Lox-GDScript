extends Expr 
class_name Self 

var keyword: Token

static func create(keyword: Token):
	var instance = Self.new()
	instance.keyword = keyword
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitSelfExpr(self)

func _to_string() -> String:
	return "%s" % [str(self.keyword)]
