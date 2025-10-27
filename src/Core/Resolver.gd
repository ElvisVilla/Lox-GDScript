extends ExprVisitor
class_name Resolver

enum ClassType {
	NONE,
	CLASS,
	SUBCLASS
}

enum FunctionType {
	NONE,
	FUNCTION,
	INITIALIZER,
	METHOD
}

var interpreter: Interpreter
var scopes: Array = []
var currentFunction: FunctionType = FunctionType.NONE
var currentClass: ClassType = ClassType.NONE

func _init(interpreter: Interpreter) -> void:
	self.interpreter = interpreter

func resolve(statements: Array[Stmt]):
	for stmt: Stmt in statements:
		stmtResolve(stmt)

# overload: resolve single stmt
func stmtResolve(stmt: Stmt):
	stmt.accept(self)

# overload: resolve single expr
func exprResolve(expr: Expr):
	expr.accept(self)

func beginScope():
	scopes.push_back(Dictionary())

func endScope():
	if scopes.size() > 0:
		scopes.pop_back()

func visitBlockStmt(stmt: Block):
	beginScope()
	resolve(stmt.statements)
	endScope()
	return null

func visitClassStmt(stmt: Class):
	var enclosingClass := currentClass
	currentClass = ClassType.CLASS

	declare(stmt.name)
	define(stmt.name)

	if stmt.superclass != null and stmt.name.lexeme == stmt.superclass.name.lexeme:
		Lox.errorWith(stmt.superclass.name, "A class can't inherit from itself.")

	if stmt.superclass != null:
		currentClass = ClassType.SUBCLASS
		exprResolve(stmt.superclass)

	if stmt.superclass != null:
		beginScope()
		scopes[scopes.size() - 1]["super"] = true

	beginScope()
	scopes[scopes.size() - 1]["self"] = true

	for method: Function in stmt.methods:
		var declaration := FunctionType.METHOD
		if method.name.lexeme == "init":
			declaration = FunctionType.INITIALIZER
		resolveFunction(method, declaration)

	endScope()

	if stmt.superclass != null: endScope()

	currentClass = enclosingClass
	return null

func visitVarStmt(stmt: Var):
	declare(stmt.name)
	if stmt.initializer != null:
		exprResolve(stmt.initializer)
	define(stmt.name)
	return null

func visitFunctionStmt(stmt: Function):
	declare(stmt.name)
	define(stmt.name)
	resolveFunction(stmt, FunctionType.FUNCTION)
	return null

func visitLoxExpressionStmt(stmt: LoxExpression):
	exprResolve(stmt.expression)
	return null

func visitIfStmt(stmt: If):
	exprResolve(stmt.condition)
	stmtResolve(stmt.thenBranch)
	if stmt.elseBranch != null:
		stmtResolve(stmt.elseBranch)
	return null

func visitPrintStmt(stmt: Print):
	exprResolve(stmt.expression)
	return null

func visitWhileStmt(stmt: While):
	exprResolve(stmt.condition)
	stmtResolve(stmt.body)
	return null

func visitReturnStmt(stmt: Return):
	if currentFunction == FunctionType.NONE:
		Lox.errorWith(stmt.keyword, "Cant't return from top-level code.")

	if stmt.value != null:
		if currentFunction == FunctionType.INITIALIZER:
			Lox.errorWith(stmt.keyword,
			"Can't return a value from anitializer")
		exprResolve(stmt.value)
	return null

# ------------- Expressions -------------
func visitAssignExpr(expr: Assign):
	# resolve the value first
	exprResolve(expr.value)
	# then resolve variable location depth
	resolveLocal(expr, expr.name)
	return null

func visitBinaryExpr(expr: Binary):
	exprResolve(expr.left)
	exprResolve(expr.right)
	return null

func visitCallExpr(expr: Call):
	# resolve callee and args
	exprResolve(expr.callee)
	for arg: Expr in expr.arguments:
		exprResolve(arg)
	return null

func visitGetExpr(expr: Get):
	exprResolve(expr.object)
	return null

func visitGroupingExpr(expr: Grouping):
	exprResolve(expr.expression)
	return null

func visitLiteralExpr(expr: Literal):
	return null

func visitLogicalExpr(expr: Logical):
	exprResolve(expr.left)
	exprResolve(expr.right)
	return null

func visitSetExpr(expr: Set):
	exprResolve(expr.value)
	exprResolve(expr.object)
	return null

func visitSuperExpr(expr: Super):
	if currentClass == ClassType.NONE:
		Lox.errorWith(expr.keyword, "Can't use 'super' outside of a class.")
	elif currentClass != ClassType.SUBCLASS:
		Lox.errorWith(expr.keyword,
		"Can't use 'super' in a class with not superclass.")

	resolveLocal(expr, expr.keyword)
	return null

func visitSelfExpr(expr: Self):
	if currentClass == ClassType.NONE:
		Lox.errorWith(expr.keyword, "can't use 'self' outside of a class.")

	resolveLocal(expr, expr.keyword)
	return null

func visitUnaryExpr(expr: Unary):
	exprResolve(expr.right)
	return null

func visitVariableExpr(expr: Variable):
	# If variable is being accessed during its own initializer
	if !scopes.is_empty():
		var scope: Dictionary = scopes[scopes.size() - 1]
		if scope.has(expr.name.lexeme) and scope[expr.name.lexeme] == false:
			Lox.error(expr.name.line, "Resolver: Can't read local variable in its own initializer.")
			# continue resolving (don't return early)
	# register variable usage distance
	resolveLocal(expr, expr.name)
	return null

# ------------- Helpers -------------
func declare(name: Token):
	if scopes.is_empty(): return

	var scope: Dictionary = scopes[scopes.size() - 1]
	if scope.has(name.lexeme):
		Lox.error(name.line, "Already a variable with this name in this scope." + name.lexeme)
	scope[name.lexeme] = false

func define(name: Token):
	if scopes.is_empty(): return
	var scope: Dictionary = scopes[scopes.size() - 1]
	scope[name.lexeme] = true

func resolveLocal(expr: Expr, name):
	# Walk scopes from innermost to outermost
	for i in range(scopes.size() - 1, -1, -1):
		var scope: Dictionary = scopes[i]
		if scope.has(name.lexeme):
			var depth: int = scopes.size() - 1 - i
			# Tell the interpreter how many scopes out this variable was found at
			# (Interpreter must implement resolve(expr, depth))
			interpreter.resolve(expr, depth)
			return

func resolveFunction(function: Function, type: FunctionType):
	var enclosingFunction: FunctionType = currentFunction
	currentFunction = type
	beginScope()
	for param: Token in function.params:
		declare(param)
		define(param)
	# Resolve the function body (array of statements)
	resolve(function.body)
	endScope()
	currentFunction = enclosingFunction
