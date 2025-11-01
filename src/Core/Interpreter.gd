# Godot doesnt have interfaces and ExprVisitor is an abstract class, like StmtVisitor
# Todo: Find another solution, ducktyping could be the option here
class_name Interpreter extends ExprVisitor # , StmtVisitor

var globals := LoxEnvironment.new()
var environment := globals
var locals: Dictionary[Expr, int]

#Testing here
var return_value: Variant = null
var has_returned: bool = false

# implements LoxCallable to create a native function "clock"
class ClockCallable extends LoxCallable:
	func minArity() -> int: return arity()
	func arity() -> int: return 0
	func loxCall(interpreter: Interpreter, arguments: Array) -> Variant:
		return Time.get_ticks_msec() / 1000.0
	func _to_string() -> String:
		return "<native fn>"
	

func _init() -> void:
	globals.define("clock", ClockCallable.new())

func interpret(statements: Array[Stmt]):
	for stmt: Stmt in statements:
		execute(stmt)
	# runetime errors? Godot doesnt have try catch

func visitLoxExpressionStmt(stmt: LoxExpression):
	evaluate(stmt.expression)

# Missing visits i want to be on pair with the Parser:
	# fields support on classes now has get, set blocks
	# signals 
	# what else?

func visitFunctionStmt(stmt: Function):
	var function := LoxFunction.new(stmt, environment, false)
	environment.define(stmt.name.lexeme, function)
	return null

func visitIfStmt(stmt: If):
	if isTruthy(evaluate(stmt.condition)):
		for statement in stmt.thenBranch:
			execute(statement)
	elif stmt.elseBranch != null:
		for statement in stmt.elseBranch:
			execute(statement)
	
	return null

func visitPrintStmt(stmt: Print):
	var value = evaluate(stmt.expression)
	print(stringify(value))

func visitReturnStmt(stmt: Return):
	if stmt.value != null:
		return_value = evaluate(stmt.value)
	else:
		return_value = null
	has_returned = true
	return null

func visitVarStmt(stmt: Var):
	var value = null
	if stmt.initializer != null:
		value = evaluate(stmt.initializer)

	environment.define(stmt.name.lexeme, value)
	return null

func visitWhileStmt(stmt: While):
	while isTruthy(evaluate(stmt.condition)):
		execute(stmt.body)

	return null

func visitAssignExpr(expr: Assign):
	var value = evaluate(expr.value)

	var distance = locals.get(expr)
	if distance != null:
		environment.assignAt(distance, expr.name, value)
	else:
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

func visitCallExpr(expr: Call):
	var callee = evaluate(expr.callee)

	var arguments: Array
	for argument in expr.arguments:
		arguments.append(evaluate(argument))

	if callee is not LoxCallable:
		var error = RuntimeError.new(expr.paren, "Can only call functions and classes.")
		push_error(error.to_string())

	var function: LoxCallable = callee

	# This is currently being tested
	if arguments.size() < function.minArity():
		var error = RuntimeError.new(expr.paren, "Expected at least %d arguments but got %d." % [function.minArity(), arguments.size()])
		push_error(error.to_string())
		return null

	if arguments.size() > function.arity():
		var error = RuntimeError.new(expr.paren, "Expected at most %d arguments but got %d." % [function.arity(), arguments.size()])
		push_error(error.to_string())
		return null

	return function.loxCall(self, arguments)

func visitGetExpr(expr: Get):
	var object = evaluate(expr.object)
	if object is LoxInstance:
		return object.getValue(expr.name)

	var error = RuntimeError.new(expr.name,
	 "Only instances have properties.")
	push_error(error.to_string())

func visitGroupingExpr(expr: Grouping) -> Variant:
	return evaluate(expr.expression)

func visitLiteralExpr(expr: Literal) -> Variant:
	return expr.value

func visitLogicalExpr(expr: Logical) -> Variant:
	var left = evaluate(expr.left)

	if expr.operator.type == Token.TokenType.OR:
		if isTruthy(left): return left
	else:
		if !isTruthy(left): return left

	return evaluate(expr.right)

func visitSetExpr(expr: Set):
	var object = evaluate(expr.object)
	if !object is LoxInstance:
		var error = RuntimeError.new(expr.name, "Only instances have fields.")
		push_error(error.to_string())
	
	var value = evaluate(expr.value)
	object.setValue(expr.name, value)
	return value

func visitSuperExpr(expr: Super):
	var distance: int = locals.get(expr)
	var superclass: LoxClass = environment.getAt(distance, "super")
	var object: LoxInstance = environment.getAt(distance - 1, "this")
	var method: LoxFunction = superclass.findMethod(expr.method.lexeme)

	if method == null:
		var error = RuntimeError.new(expr.method,
		"Undefined property '" + expr.method.lexeme + "'.")
		push_error(error.to_string())

	return method.bind(object)

func visitSelfExpr(expr: Self):
	return lookUpVariable(expr.keyword, expr)

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
	return lookUpVariable(expr.name, expr)

func lookUpVariable(name: Token, expr: Expr) -> Variant:
	var distance = locals.get(expr)
	if distance != null:
		return environment.getAt(distance, name.lexeme)
	else:
		return globals.getValue(name)


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

func resolve(expr: Expr, depth: int):
	locals.set(expr, depth)

func executeBlock(statements: Array[Stmt], environment: LoxEnvironment):
	var previous = self.environment
	self.environment = environment

	for statement: Stmt in statements:
		execute(statement)
		
		if has_returned: # Check the flag
			break
		
		if Lox.hadRuntimeError:
			break

	self.environment = previous
	has_returned = false # ← Reset flag after exiting block

func visitBlockStmt(stmt: Block):
	executeBlock(stmt.statements, LoxEnvironment.new(environment))
	return null

func visitClassStmt(stmt: Class):
	var superclass = null
	if stmt.superclass != null:
		superclass = evaluate(stmt.superclass)
		if !superclass is LoxClass:
			var error = RuntimeError.new(stmt.superclass.name,
			"Superclass must be a class.")
			push_error(error)


	environment.define(stmt.name.lexeme, null)

	if stmt.superclass != null:
		environment = LoxEnvironment.new(environment)
		environment.define("super", superclass)

	var methods: Dictionary
	for method: Function in stmt.methods:
		var function := LoxFunction.new(
			method,
			environment,
			method.name.lexeme == "init" # set true if its init
		)
		methods.set(method.name.lexeme, function)

	var fields: Dictionary
	for field in stmt.fields:
		fields.set(field.name.lexeme, field)

	var klass = LoxClass.new(stmt.name.lexeme, superclass, fields, methods)

	if superclass != null:
		environment = environment.enclosing

	environment.assign(stmt.name, klass)
	return null
