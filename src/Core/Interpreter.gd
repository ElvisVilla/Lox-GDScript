# Godot doesnt have interfaces and ExprVisitor is an abstract class, like StmtVisitor
# Todo: Find another solution, ducktyping could be the option here
class_name Interpreter extends ExprVisitor # , StmtVisitor

var environment := LoxEnvironment.new()

func interpret(statements: Array[Stmt]):
	for stmt: Stmt in statements:
		execute(stmt)
	# runetime errors? Godot doesnt have try catch

func visitLoxExpressionStmt(stmt: LoxExpression):
	evaluate(stmt.expression)

func visitPrintStmt(stmt: Print):
	var value = evaluate(stmt.expression)
	print(stringify(value))

func visitVarStmt(stmt: Var):
	var value = null
	if stmt.initializer != null:
		value = evaluate(stmt.initializer)

	environment.define(stmt.name.lexeme, value)
	# return null

func visitAssignExpr(expr: Assign):
	var value = evaluate(expr.value)
	environment.assign(expr.name, value)
	return value

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

func visitVariableExpr(expr: Variable):
	var value = environment.getValue(expr.name)
	if value == null:
		var error = RuntimeError.new(expr.name, "variable '%s' has not been initialized" % expr.name.lexeme)
		push_error(error._to_string())
		# assert(false)
	return value

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


# In this part is where the ExprVisitor and StmtVisitor is required, since we are passing ourself
# and expr.accept() expects a visitor 

func evaluate(expr: Expr) -> Variant:
	return expr.accept(self) # Expects an ExpressionVisitor

func execute(stmt: Stmt):
	stmt.accept(self) # Expects an ExpressionVisitor

func executeBlock(statements: Array[Stmt], environment: LoxEnvironment):
	var previous = self.environment
	self.environment = environment

	for statement: Stmt in statements:
		execute(statement)

		# GDScript doesnt have a try/catch/finally like Java
		# This line is not in the book, but is added here to break / exit the loop and -> 
		if Lox.hadRuntimeError:
			break

	# -> restore the environment after the loop in case of runtimeError
	self.environment = previous

func visitBlockStmt(stmt: Block):
	executeBlock(stmt.statements, LoxEnvironment.new(environment))
	return null