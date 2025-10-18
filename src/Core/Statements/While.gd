extends Stmt 
class_name While 

var condition: Expr
var body: Stmt

static func create(condition: Expr, body: Stmt):
	var instance = While.new()
	instance.condition = condition
	instance.body = body
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitWhileStmt(self)

func _to_string() -> String:
	return "%s %s" % [str(self.condition), str(self.body)]
