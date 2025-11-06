extends Stmt
class_name If

var condition: Expr
var thenBranch: Stmt
var elifBranch: Dictionary # [Expr, Stmt]
var elseBranch: Stmt

static func create(condition: Expr, thenBranch: Stmt, elifBranch: Dictionary, elseBranch: Stmt):
	var instance = If.new()
	instance.condition = condition
	instance.thenBranch = thenBranch
	instance.elifBranch = elifBranch
	instance.elseBranch = elseBranch
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitIfStmt(self)

func _to_string() -> String:
	return "%s %s %s %s" % [str(self.condition), str(self.thenBranch), str(self.elifBranch), str(self.elseBranch)]
