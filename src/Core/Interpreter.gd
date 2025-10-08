class_name Interpreter extends ExprVisitor


func interpret(expression: Expr):
	var value = evaluate(expression)
	print(value)
	# runetime errors? Godot doesnt have try catch

func visitBinaryExpr(expr: Binary) -> Variant:
	var left = evaluate(expr.left)
	var right = evaluate(expr.right)

	match expr.operator.type:
		Token.TokenType.GREATER:
			checkNumberOperands(expr.operator, left, right)
			return left > right

		Token.TokenType.GREATER_EQUAL:
			checkNumberOperands(expr.operator, left, right)
			return left >= right
		Token.TokenType.LESS:
			checkNumberOperands(expr.operator, left, right)
			return left < right
		Token.TokenType.LESS_EQUAL:
			checkNumberOperands(expr.operator, left, right)
			return left <= right
		Token.TokenType.MINUS:
			checkNumberOperands(expr.operator, left, right)
			return left - right

		Token.TokenType.PLUS:
			#here could be an issue
			if (left is float or left is int) and (right is float or right is int):
				return left + right

			if left is String and right is String:
				return left + right

			if left is String or right is String:
				return str(left) + str(right)

			var error = RuntimeError.new(expr.operator, "Operands must be two numbers or two strings")
			push_error(error.to_string())

		Token.TokenType.SLASH:
			checkNumberOperands(expr.operator, left, right)
			return left / right
		Token.TokenType.STAR:
			checkNumberOperands(expr.operator, left, right)
			return left * right
		Token.TokenType.BANG_EQUAL: return !isEqual(left, right)
		Token.TokenType.EQUAL_EQUAL: return isEqual(left, right)

	return null

func visitGroupingExpr(expr: Grouping) -> Variant:
	return evaluate(expr.expression)

func visitLiteralExpr(expr: Literal) -> Variant:
	return expr.value

func visitUnaryExpr(expr: Unary) -> Variant:
	var right = evaluate(expr.right)

	match expr.operator.type:
		Token.TokenType.BANG:
			return !isTruthy(right)
		Token.TokenType.MINUS:
			checkNumberOperand(expr.operator, right)
			return -float(right)

	return null

func checkNumberOperand(operator: Token, operand: Variant):
	if operand is float: return
	var error = RuntimeError.new(operator, "operand most be a number")
	push_error(error.to_string()) # Possibly RuntimeError class is not necessary

func checkNumberOperands(operator: Token, right: Variant, left: Variant):
	if left is float and right is float: return
	var error = RuntimeError.new(operator, "operands most be a numbers")
	push_error(error.to_string()) # Possibly RuntimeError class is not necessary


func isTruthy(item: Variant) -> bool:
	if item == null: return false
	if item is bool: return item
	return true

func isEqual(a, b) -> bool:
	if a == null and b == null: return true
	if a == null: return false

	return is_same(a, b)

func stringify(item: Variant) -> String:
	if item == null: return "nil"

	if item is float:
		var text = str(item)
		if text.ends_with(".0"):
			text = text.substr(0, text.length() - 2)

		return text

	return str(item)

func evaluate(expr: Expr) -> Variant:
	return expr.accept(self)
