extends Object
class_name Transpiler

var indentLevel: int = 1
var output: String = ""

func transpile(statements: Array[Stmt]) -> String:
	output = ""
	
	for stmt in statements:
		output += transpileStmt(stmt)
	
	return output

# ============ HELPERS ============

func getIndent() -> String:
	return "\t".repeat(indentLevel)

func increaseIndent():
	indentLevel += 1

func decreaseIndent():
	indentLevel -= 1

# ============ STATEMENTS ============

func transpileStmt(stmt: Stmt) -> String:
	if stmt is Class:
		return transpileClass(stmt)
	elif stmt is Function:
		return transpileFunction(stmt)
	elif stmt is Var:
		return transpileVar(stmt)
	elif stmt is Block:
		return transpileBlock(stmt)
	elif stmt is If:
		return transpileIf(stmt)
	elif stmt is While:
		return transpileWhile(stmt)
	# elif stmt is FOR:
	# 	return transpileFor(stmt)
	elif stmt is Return:
		return transpileReturn(stmt)
	elif stmt is LoxExpression:
		return transpileExpressionStmt(stmt)
	elif stmt is Print:
		return transpilePrint(stmt)
	else:
		push_error("Unknown statement type: " + str(stmt))
		return ""

func transpileClass(stmt: Class) -> String:
	var result = ""
	
	# Class name
	result += "class_name " + stmt.name.lexeme + "\n"
	
	# Superclass
	if stmt.superclass:
		result += "extends " + stmt.superclass.name.lexeme + "\n"
	
	result += "\n"
	
	# Fields
	for field in stmt.fields:
		result += transpileField(field) + "\n"
	
	if not stmt.fields.is_empty():
		result += "\n"
	
	# Methods
	for method in stmt.methods:
		result += transpileFunctionAsMethod(method) + "\n"
	
	return result

func transpileField(field: Field) -> String:
	var result = "var " + field.name.lexeme
	
	# Type hint
	if field.typeHint:
		result += ": " + field.typeHint.lexeme
	
	# Initializer
	if field.initializer:
		result += " = " + transpileExpr(field.initializer)
	
	# Getter/Setter
	if not field.getter.is_empty() or not field.setter.is_empty():
		result += ":\n"

		# Getter
		if not field.getter.is_empty():
			result += getIndent() + "get:\n"
			increaseIndent()
			
			# Check if it's a single expression (implicit return)
			if field.getter.size() == 1 and field.getter[0] is LoxExpression:
				var expr_stmt = field.getter[0] as LoxExpression
				result += getIndent() + "return " + transpileExpr(expr_stmt.expression) + "\n"

			else:
				# Multi-line getter
				for getter_stmt in field.getter:
					print_debug("MultiLine Block")
					result += getIndent() + transpileStmt(getter_stmt).strip_edges() + "\n"

			decreaseIndent()
		# Setter
		if not field.setter.is_empty():
			var param_name = field.valueParameter.lexeme if field.valueParameter else "value"
			# result += "\tset(" + param_name + "):\n"
			result += getIndent() + "set(" + param_name + "):\n"
			increaseIndent()
			
			for setter_stmt in field.setter:
				result += getIndent() + transpileStmt(setter_stmt).strip_edges()
			
		decreaseIndent()
	
	# decreaseIndent()
	
	return result

func transpileFunction(stmt: Function) -> String:
	var result = "func " + stmt.name.lexeme + "("
	
	# Parameters
	var params = []
	for param: Parameter in stmt.params:
		var param_str: String = param.name.lexeme
		
		if param.typeHint != null:
			param_str += ": " + param.typeHint.lexeme
			

		if param.defaultValue != null:
			param_str += " = " + transpileExpr(param.defaultValue)

		params.append(param_str)
	result += ", ".join(params) + ")"
	
	## Return type
	if stmt.returnType:
		result += " -> " + stmt.returnType.lexeme

	# var returnValue = hasReturnValue(stmt.body)
	# if returnValue: # &"NONE" was used to represent 'return' that doesnt return anything
	# 	if stmt.returnType:
	# 		result += " -> " + transpileExpr(returnValue.value)
	# 	else:
	# 		result += " -> void"
	
	result += ":\n"
	
	# Body
	# increaseIndent()
	for body_stmt in stmt.body:
		result += getIndent() + transpileStmt(body_stmt).strip_edges() + "\n"
	# decreaseIndent()
	
	return result

# func hasReturnValue(statements: Array) -> Variant:
# 	for stmt: Stmt in statements:
# 		if stmt is Return and stmt.value:
# 			return stmt
		
# 		elif stmt is If:
# 			if stmt.thenBranch != null:
# 				var thenReturns = hasReturnValue(stmt.thenBranch.statements)
# 				if thenReturns != null:
# 					return thenReturns
					
# 			elif stmt.elseBranch != null:
# 				var elseReturns = hasReturnValue(stmt.elseBranch.statements)
# 				if elseReturns != null:
# 					return elseReturns

		
# 		elif stmt is While:
# 			return hasReturnValue(stmt.body.statements)
		
# 	return &"NONE"
	
func transpileFunctionAsMethod(stmt: Function) -> String:
	# Same as transpileFunction but for methods inside classes
	return transpileFunction(stmt)

func transpileVar(stmt: Var) -> String:
	var result = "var " + stmt.name.lexeme
	
	# Type hint
	#if stmt.typeHint:
		#result += ": " + stmt.typeHint.lexeme
	
	# Initializer
	if stmt.initializer:
		result += " = " + transpileExpr(stmt.initializer)
	
	return result

func transpileBlock(stmt: Block) -> String:
	var result = ""

	increaseIndent()
	
	for block_stmt in stmt.statements:
		result += getIndent() + transpileStmt(block_stmt).strip_edges() + "\n"
	
	decreaseIndent()
	return result

func transpileIf(stmt: If) -> String:
	var result = "if " + transpileExpr(stmt.condition) + ":\n"

	if stmt.thenBranch is Block:
		result += transpileBlock(stmt.thenBranch)
	else:
		increaseIndent()
		result += getIndent() + transpileStmt(stmt.thenBranch).strip_edges() + "\n"
		decreaseIndent()
	
	if !stmt.elifBranch.is_empty(): # Dictionary[Expr, Stmt]
		for condition in stmt.elifBranch:
			result += getIndent() + "elif " + transpileExpr(condition) + ":\n"
			var statements = stmt.elifBranch[condition]
			if statements is Block:
				result += transpileBlock(statements)
			else:
				result += getIndent() + transpileStmt(statements).strip_edges() + "\n"

	# Else branch
	if stmt.elseBranch:
		result += getIndent() + "else:\n"

		if stmt.elseBranch is Block:
			result += transpileBlock(stmt.elseBranch)
		else:
			result += getIndent() + transpileStmt(stmt.elseBranch).strip_edges() + "\n"
	
	return result

func transpileWhile(stmt: While) -> String:
	var result = "while " + transpileExpr(stmt.condition) + ":\n"
	
	#indentLevel += 1
	if stmt.body is Block:
		result += transpileBlock(stmt.body)
	#else:
		#indentLevel += 1
		#result += getIndent() + transpileStmt(stmt.body).strip_edges() + "\n"
	#indentLevel -= 1
	
	return result

# func transpileFor(stmt: For) -> String:
# 	# For loops in your syntax need to be converted to GDScript for loops
# 	# This is a basic implementation - you might need to adjust based on your for loop syntax
# 	var result = ""
	
# 	# If you have C-style for loops, convert to while loop
# 	if stmt.initializer:
# 		result += transpileStmt(stmt.initializer).strip_edges() + "\n"
	
# 	result += getIndent() + "while " + transpileExpr(stmt.condition) + ":\n"
	
# 	indentLevel += 1
	
# 	# Body
# 	if stmt.body is Block:
# 		result += transpileBlock(stmt.body)
# 	else:
# 		result += getIndent() + transpileStmt(stmt.body).strip_edges() + "\n"
	
# 	# Increment
# 	if stmt.increment:
# 		result += getIndent() + transpileExpr(stmt.increment) + "\n"
	
# 	indentLevel -= 1
	
# 	return result

func transpileReturn(stmt: Return) -> String:
	var result = "return"
	
	if stmt.value:
		result += " " + transpileExpr(stmt.value)
	
	return result

func transpileExpressionStmt(stmt: LoxExpression) -> String:
	return transpileExpr(stmt.expression)

func transpilePrint(stmt: Print) -> String:
	return "print(" + transpileExpr(stmt.expression) + ")"

# ============ EXPRESSIONS ============

func transpileExpr(expr: Expr) -> String:
	if expr is Assign:
		return transpileAssign(expr)
	elif expr is Binary:
		return transpilebinary(expr)
	elif expr is Call:
		return transpileCall(expr)
	elif expr is Get:
		return transpileGet(expr)
	elif expr is Set:
		return transpileSet(expr)
	elif expr is Grouping:
		return transpileGrouping(expr)
	elif expr is Literal:
		return transpileLiteral(expr)
	elif expr is Logical:
		return transpileLogical(expr)
	elif expr is Unary:
		return transpileUnary(expr)
	elif expr is Variable:
		return transpileVariable(expr)
	elif expr is Self:
		return transpileSelf(expr)
	elif expr is Super:
		return transpileSuper(expr)
	else:
		push_error("Unknown expression type: " + str(expr))
		return ""

func transpileAssign(expr: Assign) -> String:
	return expr.name.lexeme + " = " + transpileExpr(expr.value)

func transpilebinary(expr: Binary) -> String:
	var left = transpileExpr(expr.left)
	var right = transpileExpr(expr.right)
	var op = expr.operator.lexeme
	
	# Convert operators if needed
	match expr.operator.type:
		Token.TokenType.BANG_EQUAL:
			op = "!="
		Token.TokenType.EQUAL_EQUAL:
			op = "=="
		Token.TokenType.GREATER:
			op = ">"
		Token.TokenType.GREATER_EQUAL:
			op = ">="
		Token.TokenType.LESS:
			op = "<"
		Token.TokenType.LESS_EQUAL:
			op = "<="
		Token.TokenType.PLUS:
			op = "+"
		Token.TokenType.MINUS:
			op = "-"
		Token.TokenType.STAR:
			op = "*"
		Token.TokenType.SLASH:
			op = "/"
		# Token.TokenType.PERCENT:
		# 	op = "%"
	
	return left + " " + op + " " + right

func transpileCall(expr: Call) -> String:
	var callee = transpileExpr(expr.callee)
	
	var args = []
	for arg in expr.arguments:
		args.append(transpileExpr(arg))
	
	return callee + "(" + ", ".join(args) + ")"

func transpileGet(expr: Get) -> String:
	return transpileExpr(expr.object) + "." + expr.name.lexeme

func transpileSet(expr: Set) -> String:
	return transpileExpr(expr.object) + "." + expr.name.lexeme + " = " + transpileExpr(expr.value)

func transpileGrouping(expr: Grouping) -> String:
	return "(" + transpileExpr(expr.expression) + ")"

func transpileLiteral(expr: Literal) -> String:
	if expr.value == null:
		return "null"
	elif expr.value is String:
		return '"' + expr.value + '"'
	elif expr.value is bool:
		return "true" if expr.value else "false"
	else:
		return str(expr.value)

func transpileLogical(expr: Logical) -> String:
	var left = transpileExpr(expr.left)
	var right = transpileExpr(expr.right)
	
	var op = "and" if expr.operator.type == Token.TokenType.AND else "or"
	
	return left + " " + op + " " + right

func transpileUnary(expr: Unary) -> String:
	var op = expr.operator.lexeme
	
	# Convert operators if needed
	if expr.operator.type == Token.TokenType.BANG:
		op = "not "
	elif expr.operator.type == Token.TokenType.MINUS:
		op = "-"
	
	return op + transpileExpr(expr.right)

func transpileVariable(expr: Variable) -> String:
	return expr.name.lexeme

func transpileSelf(expr: Self) -> String:
	return "self" # In GDScript, 'this' becomes 'self'

func transpileSuper(expr: Super) -> String:
	# super.method() stays as super.method()
	return "super." + expr.method.lexeme
