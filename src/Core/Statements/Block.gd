extends Stmt 
class_name Block 

var statements: Array[Stmt]

static func create(statements: Array[Stmt]):
	var instance = Block.new()
	instance.statements = statements
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitBlockStmt(self)

func _to_string() -> String:
	return "%s" % [str(self.statements)]
