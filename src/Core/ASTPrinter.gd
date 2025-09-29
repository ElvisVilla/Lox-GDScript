extends ExprVisitor
class_name ASTPrinter


func print(expr: Expr):
	return expr.accept(self)

func visitBinaryExpr(expr: Binary):
	return parenthesize(expr.operator.lexeme, expr.left, expr.right)

func visitGroupingExpr(expr: Grouping):
	return parenthesize("group", expr.expression)

func visitLiteralExpr(expr: Literal):
	if expr.value == null: return "nil"
	return expr.to_string()

func visitUnaryExpr(expr: Unary):
	return parenthesize(expr.operator.lexeme, expr.right)

func parenthesize(name: String, ...exprs: Array):
	var formatted: String = ""

	formatted += "(%s"%name
	for expr in exprs:
		formatted += " "
		formatted += expr.accept(self)
	
	formatted += ")"
	return formatted
