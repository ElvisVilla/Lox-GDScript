extends Expr 
class_name Get 

var object: Expr
var name: Token

static func create(object: Expr, name: Token):
	var instance = Get.new()
	instance.object = object
	instance.name = name
	return instance


func accept(visitor: ExprVisitor) -> Variant:
	return visitor.visitGetExpr(self)

func _to_string() -> String:
	return "%s %s" % [str(self.object), str(self.name)]
