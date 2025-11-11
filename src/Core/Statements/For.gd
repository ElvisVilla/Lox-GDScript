extends Stmt
class_name For

var index: Token
var iterable: Expr
var body: Stmt

static func create(index: Token, iterable: Expr, body: Stmt):
	var instance = For.new()
	instance.index = index
	instance.iterable = iterable
	instance.body = body
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitForStmt(self)

func _to_string() -> String:
	return "%s %s %s" % [str(self.index), str(self.iterable), str(self.body)]
