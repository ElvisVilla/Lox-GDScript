extends Expr 
class_name Super 

var keyword: Token
var method: Token

static func create(keyword: Token, method: Token):
	var instance = Super.new()
	instance.keyword = keyword
	instance.method = method
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitSuperExpr(self)

func _to_string() -> String:
	return "%s %s" % [str(self.keyword), str(self.method)]
