extends ExprVisitor
class_name GDScriptTranspiler

# The AST nodes (Expr, Stmt) must be available.
# Assuming you have the Lox architecture files:
# const Expr = preload("Expr.gd") 
# const Stmt = preload("Stmt.gd")
# const Token = preload("Token.gd")

var _indent_level = 0
const INDENT_STRING = "    " # 4 spaces for GDScript style

# Public method to start the transpilation process
func transpile(statements: Array) -> String:
	var output = ""
	for stmt in statements:
		output += visit(stmt) + "\n"
	return output

# Helper method for all visitors
func visit(node):
	if node is Stmt:
		return node.accept(self)
	if node is Expr:
		return node.accept(self)
	# Handle the case where a node might be 'null' (e.g., in a default initializer)
	return "null"

# --- Indentation Helpers ---

func _get_indent() -> String:
	return INDENT_STRING.repeat(_indent_level)

func _increase_indent():
	_indent_level += 1

func _decrease_indent():
	_indent_level -= 1

# =================================================================
# EXPRESSION VISITORS (Generate Code for Expressions)
# =================================================================

func visitBinaryExpr(expr) -> String:
	# (left_code operator right_code)
	var left_code = visit(expr.left)
	var right_code = visit(expr.right)
	var operator_lexeme = expr.operator.lexeme
	
	# GDScript doesn't use '!' for 'not', but 'not' is a keyword.
	# Lox usually maps '!=' to '!=' (which GDScript uses), but if your custom
	# language uses a different operator for not-equal, adjust here.
	# We will assume Lox operators map directly for now.
	return "(%s %s %s)" % [left_code, operator_lexeme, right_code]

func visitGroupingExpr(expr) -> String:
	# (code)
	return "(%s)" % visit(expr.expression)

func visitLiteralExpr(expr) -> String:
	# Literal values are converted to their string representation.
	if expr.value == null:
		return "null"
	if typeof(expr.value) == TYPE_STRING:
		# String literals need quotes around them in the output code
		return "\"%s\"" % expr.value
	# Numbers and Booleans (true/false) convert directly
	return str(expr.value)

func visitUnaryExpr(expr) -> String:
	var right_code = visit(expr.right)
	
	match expr.operator.type:
		Token.TokenType.MINUS:
			return "-%s" % right_code
		Token.TokenType.BANG: # Lox '!' is logical NOT
			# GDScript uses the keyword 'not'
			return "not %s" % right_code
	
	return "" # Should not happen

func visitVariableExpr(expr) -> String:
	# Variable access is just the variable name
	return expr.name.lexeme

func visitAssignExpr(expr) -> String:
	# Assignment code: name = value_code
	var value_code = visit(expr.value)
	# Assignments are often part of a statement, so we don't add indentation here,
	# but the calling statement visitor will.
	return "%s = %s" % [expr.name.lexeme, value_code]

# (Implement Call, Get, Set, This, Super, Logical, etc., if needed)
# Example for Function Calls:
func visitCallExpr(expr) -> String:
	var callee_code = visit(expr.callee)
	var arguments_code = []
	for arg in expr.arguments:
		arguments_code.append(visit(arg))
	
	return "%s(%s)" % [callee_code, ", ".join(arguments_code)]

# =================================================================
# STATEMENT VISITORS (Generate Code for Statements and Blocks)
# =================================================================

func visitExpressionStmt(stmt) -> String:
	# Just the expression code plus a newline (the transpiler adds the final newline)
	return _get_indent() + visit(stmt.expression) + "" # No semicolon in GDScript

func visitPrintStmt(stmt) -> String:
	# Lox 'print' transpiles to GDScript 'print'
	return _get_indent() + "print(%s)" % visit(stmt.expression)

# --- Swift-Like Variable Declarations ---
func visitVarStmt(stmt) -> String:
	var line = _get_indent() + "var %s" % stmt.name.lexeme
	
	# This is the key Swift-to-GDScript mapping:
	# Assuming Swift-like syntax uses `let` or `var` in the source, 
	# the Lox AST just uses a generic `VarStmt` with a token name.
	# We must **always** use 'var' in the GDScript output.
	
	if stmt.initializer:
		line += " = %s" % visit(stmt.initializer)
	else:
		# If no initializer, GDScript initializes to 'null' or default, but 
		# it's clearer to explicitly set to 'null' if the original language allowed it.
		# However, a simple `var a` is valid in GDScript.
		pass # `var a` is valid in GDScript
	
	return line

func visitBlockStmt(stmt) -> String:
	var code = ""
	_increase_indent()
	
	for statement in stmt.statements:
		# Adding the transpiled statement and a newline
		code += visit(statement) + "\n"
		
	_decrease_indent()
	
	# Blocks are used inside functions, classes, and control flow (if/loop).
	# FIX: Use rstrip(" \t\r\n") to remove the extra newline at the end.
	return code.rstrip(" \t\r\n")

func visitIfStmt(stmt: If) -> String:
	var code = _get_indent() + "if %s:\n" % visit(stmt.condition)
	
	# Transpile the 'then' branch block
	code += visit(stmt.thenBranch) + "\n"
	
	if stmt.elseBranch:
		# GDScript 'elif' logic
		# Assuming 'If' is defined as the class for If statements (e.g., const If = Stmt.If)
		if stmt.elseBranch is If:
			# Handle 'elif' by removing the block and using 'elif' syntax
			# FIX: Use lstrip(" \t\r\n") to remove leading whitespace
			code += _get_indent() + "el" + visit(stmt.elseBranch).lstrip(" \t\r\n")
		else:
			# Standard 'else'
			code += _get_indent() + "else:\n"
			code += visit(stmt.elseBranch)
	
	# FIX: Use rstrip(" \t\r\n") to remove trailing whitespace/newline
	return code.rstrip(" \t\r\n")

# Example for Function Declarations (Lox 'fun' to GDScript 'func')
func visitFunctionStmt(stmt) -> String:
	var code = _get_indent() + "func %s(%s):\n" % [stmt.name.lexeme, ", ".join(stmt.params.map(func(p): return p.lexeme))]
	
	# The block visitor will handle the body indentation
	code += visit(stmt.body)
	
	return code

# (Implement While, Return, Class, etc.)
# Example for Return:
func visitReturnStmt(stmt) -> String:
	var line = _get_indent() + "return"
	if stmt.value:
		line += " %s" % visit(stmt.value)
	return line


func visitLoxExpressionStmt(stmt: LoxExpression):
	var expresion_code = visit(stmt.expression)
	return _get_indent() + expresion_code

func visitLogicalExpr(expr: Logical):
	pass
