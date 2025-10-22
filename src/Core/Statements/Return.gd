extends Stmt 
class_name Return 

var keyword: Token
var value: Expr

static func create(keyword: Token, value: Expr):
	var instance = Return.new()
	instance.keyword = keyword
	instance.value = value
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitReturnStmt(self)

func _to_string() -> String:
	return "%s %s" % [str(self.keyword), str(self.value)]
