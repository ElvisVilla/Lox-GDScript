extends Stmt 
class_name Function 

var name: Token
var params: Array[Parameter]
var body: Array[Stmt]

static func create(name: Token, params: Array[Parameter], body: Array[Stmt]):
	var instance = Function.new()
	instance.name = name
	instance.params = params
	instance.body = body
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitFunctionStmt(self)

func _to_string() -> String:
	return "%s %s %s" % [str(self.name), str(self.params), str(self.body)]
