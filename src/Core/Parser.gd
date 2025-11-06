extends RefCounted
class_name Parser

var tokens: Array[Token]
var current: int = 0

func _init(tokens: Array[Token]) -> void:
	self.tokens = tokens

func parse() -> Array[Stmt]:
	var statements: Array[Stmt]
	while !isAtEnd():
		statements.append(declaration())

	return statements
	

func expression() -> Expr:
	return assignment()

# The top Token we can find is considered a declaration [Class | function | Variable]
func declaration() -> Stmt:
	if isMatch(Token.TokenType.CLASS): return classDeclaration()
	if isMatch(Token.TokenType.FUNC): return function("function")
	if isMatch(Token.TokenType.VAR): return varDeclaration()
	return statement()

## structure the class Stmt as the main Node of this Stmt, will hold inside
## variables, methods, properties, etc.
func classDeclaration() -> Stmt:
	var name = consume(Token.TokenType.IDENTIFIER, "Expect class name.")

	var superclass: Variable = null
	if isMatch(Token.TokenType.COLON, Token.TokenType.EXTENDS):
		consume(Token.TokenType.IDENTIFIER, "Expect superclass name.")
		superclass = Variable.create(previous())

	consume(Token.TokenType.LEFT_BRACE, "Expect '{' before class body.")

	var fields: Array[Field]
	var methods: Array[Function]

	while !check(Token.TokenType.RIGHT_BRACE) and !isAtEnd():
		# @, signal, var or const
		if isMatch(Token.TokenType.AT, Token.TokenType.SIGNAL,
			Token.TokenType.VAR, Token.TokenType.CONST):
			fields.append(field())
		elif isMatch(Token.TokenType.FUNC):
			methods.append(function("method"))

	consume(Token.TokenType.RIGHT_BRACE, "Expect '}' after class body.")
	return Class.create(name, superclass, fields, methods)

func statement() -> Stmt:
	if isMatch(Token.TokenType.FOR): return forStatement()
	if isMatch(Token.TokenType.IF): return ifStatement()
	if isMatch(Token.TokenType.PRINT): return printStatement()
	if isMatch(Token.TokenType.RETURN): return returnStatement()
	if isMatch(Token.TokenType.WHILE): return whileStatement()
	if isMatch(Token.TokenType.LEFT_BRACE): return Block.create(block())
	return expressionStatement()

func forStatement() -> Stmt:
	consume(Token.TokenType.LEFT_PAREN, "Expect '(' after 'for'.")

	var initializer: Stmt = null
	if isMatch(Token.TokenType.SEMICOLON):
		initializer = null
	elif isMatch(Token.TokenType.VAR):
		initializer = varDeclaration()
		consume(Token.TokenType.SEMICOLON, "Expect ';' after variable declaration.")
	else:
		initializer = expressionStatement()

	var condition: Expr = null
	if !check(Token.TokenType.SEMICOLON):
		condition = expression()
	
	consume(Token.TokenType.SEMICOLON, "Expect ';' after loop condition.")

	var increment: Expr = null
	if !check(Token.TokenType.RIGHT_PAREN):
		increment = expression()
	
	consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after clauses.")
	var body: Stmt = statement()

	if increment != null:
		body = Block.create([body, LoxExpression.create(increment)])

	if condition == null:
		condition = Literal.create(true)
	
	body = While.create(condition, body)

	if initializer != null:
		body = Block.create([initializer, body])

	return body

func ifStatement() -> Stmt:
	var condition = expression()
	#consume(Token.TokenType.LEFT_BRACE, "Expect '{' after if condition")
	var thenBranch = statement()

	var elifBranches: Dictionary[Expr, Stmt]
	while isMatch(Token.TokenType.ELIF):
		var cond = expression()
		#consume(Token.TokenType.LEFT_BRACE, "Expect '{' after elif condition")
		var elif_block = statement()
		elifBranches.set(cond, elif_block)


	var elseBranch = null
	if isMatch(Token.TokenType.ELSE):
		#consume(Token.TokenType.LEFT_BRACE, "Expect '{' after else keyword")
		elseBranch = statement()
	
	return If.create(condition, thenBranch, elifBranches, elseBranch)

func printStatement() -> Stmt:
	var value = expression()
	return Print.create(value)

func returnStatement() -> Stmt:
	var keyword = previous()
	var value: Expr = null

	var next = peek().type
	if next != Token.TokenType.RIGHT_BRACE and \
	   next != Token.TokenType.PRINT and \
	   next != Token.TokenType.VAR and \
	   next != Token.TokenType.FOR and \
	   next != Token.TokenType.WHILE and \
	   next != Token.TokenType.IF and \
	   next != Token.TokenType.FUNC and \
	   next != Token.TokenType.RETURN and \
	   next != Token.TokenType.EOF:
		value = expression()

	return Return.create(keyword, value)

#TODO: Implement typeHint like on fields() declaration
func varDeclaration() -> Stmt:
	var name = consume(Token.TokenType.IDENTIFIER, "Expect variable name")

	var typeHint: Token
	var initializer: Expr = null
	# if isMatch(Token.TokenType.EQUAL):
	# 	initializer = expression()

	if isMatch(Token.TokenType.COLON): # var fieldName :    <---
		typeHint = previous() # store ':' this means is an inferred type
		if isMatch(Token.TokenType.EQUAL): # var fieldName :=      <---
			initializer = assignment() # var fieldName := assignment()     <---
		elif check(Token.TokenType.IDENTIFIER):
			if peekNext().type == Token.TokenType.LEFT_PAREN: # var fieldName: Timer() or class instances
				typeHint = previous()
				initializer = assignment()
			else:
				typeHint = consume(Token.TokenType.IDENTIFIER, "Expect type after ':'") # var fieldName : Type

				if isMatch(Token.TokenType.EQUAL): # var fieldName : typeHint =
					initializer = assignment() # var fieldName : typeHint = assignment()


		elif !check(Token.TokenType.IDENTIFIER): # var fieldName: value
			initializer = assignment()

	if isMatch(Token.TokenType.EQUAL) and initializer == null: # var fieldName := assignment()
		initializer = assignment()

	return Var.create(name, typeHint, initializer)

func whileStatement() -> Stmt:
	var condition = expression()
	var body = statement()

	return While.create(condition, body)

func expressionStatement() -> Stmt:
	var expr = expression()
	# consume(Token.TokenType.SEMICOLON, "Expect ';' after the expression")
	return LoxExpression.create(expr)

func field() -> Field:
	# # is signal a field?
	# var at: Token = null
	# if previous().type == Token.TokenType.AT:
	# 	at = previous()
	# 	#var requireParen = #Here I need to check if this specific annotation requires
	# 	# parameters
	# 	consume(Token.TokenType.RIGHT_PAREN, "Expect '(' after annotation %s" % token.lexeme)
	var fieldName = consume(Token.TokenType.IDENTIFIER, "Expected field name")

	var typeHint: Token = null
	var initializer: Expr = null

	if isMatch(Token.TokenType.COLON): # var fieldName :    <---
		typeHint = previous() # store ':' this means is an inferred type
		if isMatch(Token.TokenType.EQUAL): # var fieldName :=      <---
			initializer = assignment() # var fieldName := assignment()     <---
		elif check(Token.TokenType.IDENTIFIER):
			if peekNext().type == Token.TokenType.LEFT_PAREN: # var fieldName: Timer() or class instances
				typeHint = previous()
				initializer = assignment()
			else:
				typeHint = consume(Token.TokenType.IDENTIFIER, "Expect type after ':'") # var fieldName : Type

				if isMatch(Token.TokenType.EQUAL): # var fieldName : typeHint =
					initializer = assignment() # var fieldName : typeHint = assignment()


		elif !check(Token.TokenType.IDENTIFIER): # var fieldName: value
			initializer = assignment()

	if isMatch(Token.TokenType.EQUAL) and initializer == null: # var fieldName := assignment()
		initializer = assignment()

	#getter/setters
	# Implicit return recives Expr or Block for block Stmt
	var getter: Array[Stmt]
	var setter: Array[Stmt]
	var valueParam: Token

	if isMatch(Token.TokenType.LEFT_BRACE):
		while !check(Token.TokenType.RIGHT_BRACE) and !isAtEnd():
			if isMatch(Token.TokenType.GET):
				consume(Token.TokenType.LEFT_BRACE, "Expect '{' after 'get'")
				getter = block()

			elif isMatch(Token.TokenType.SET):
				consume(Token.TokenType.LEFT_PAREN, "Expect '(' after 'set'.")
				valueParam = consume(Token.TokenType.IDENTIFIER,
				"Expect parameter name") # This is newValue or value parameter for Set
				consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after parameter.")
				consume(Token.TokenType.LEFT_BRACE, "Expect '{' before 'set' body.")
				setter = block()
		
		consume(Token.TokenType.RIGHT_BRACE, "Expect '}' after getter/setter")
		
	return Field.create(fieldName, typeHint, initializer, getter, setter, valueParam)

func function(kind: String) -> Function:
	var name: Token = consume(Token.TokenType.IDENTIFIER, "Expect %s name." % kind)
	consume(Token.TokenType.LEFT_PAREN, "Expect '(' after %s name" % kind)
	
	var parameters: Array[Parameter]
	if !check(Token.TokenType.RIGHT_PAREN):
		while true:
			if parameters.size() >= 255:
				error(peek(), "Can't have more than 255 parameters")
			
			var paramName: Token = consume(Token.TokenType.IDENTIFIER, "Expect parameter name.")
			var typeHint: Token
			var initializer: Expr
			if isMatch(Token.TokenType.COLON):
				typeHint = consume(Token.TokenType.IDENTIFIER, "Expect parameter type")

			if isMatch(Token.TokenType.EQUAL):
				initializer = expression()

			parameters.append(Parameter.new(paramName, typeHint, initializer))
			if !isMatch(Token.TokenType.COMMA):
				break
	
	consume(Token.TokenType.RIGHT_PAREN, "Expected ')' after parameters.")

	var returnType: Token = null
	if isMatch(Token.TokenType.COLON):
		returnType = consume(Token.TokenType.IDENTIFIER, "Expect return type.")
	elif check(Token.TokenType.IDENTIFIER):
		returnType = consume(Token.TokenType.IDENTIFIER, "Expect return type.")
	elif check(Token.TokenType.ARROW):
		error(peek(), "Expect ':' before return type or directly return type")
		synchronize()
	
	consume(Token.TokenType.LEFT_BRACE, "Expected '{' before %s body." % kind)
	var body: Array[Stmt] = block()
	return Function.create(name, parameters, returnType, body)

func block() -> Array[Stmt]:
	var statements: Array[Stmt]
	while !check(Token.TokenType.RIGHT_BRACE) and !isAtEnd():
		statements.append(declaration())

	consume(Token.TokenType.RIGHT_BRACE, "Expect '}' after block.")
	return statements

func assignment() -> Expr:
	var expr = logicOr()

	if isMatch(Token.TokenType.EQUAL):
		var equals = previous()
		var value = assignment()

		if expr is Variable:
			var name = expr.name
			return Assign.create(name, value)
		elif expr is Get:
			return Set.create(expr.object, expr.name, value)


		error(equals, "Invalid assignment target.")

	return expr

func logicOr() -> Expr:
	var expr = logicAnd()

	while isMatch(Token.TokenType.OR):
		var operator = previous()
		var right = logicAnd()
		expr = Logical.create(expr, operator, right)
	
	return expr

func logicAnd() -> Expr:
	var expr = equality()

	while isMatch(Token.TokenType.AND):
		var operator = previous()
		var right = equality()
		expr = Logical.create(expr, operator, right)

	return expr

func equality() -> Expr:
	var expr = comparison()

	while isMatch(Token.TokenType.BANG_EQUAL, Token.TokenType.EQUAL_EQUAL):
		var operator = previous()
		var right = comparison()
		expr = Binary.create(expr, operator, right)

	return expr

func comparison() -> Expr:
	var expr = term()
	while isMatch(Token.TokenType.GREATER, Token.TokenType.GREATER_EQUAL,
	Token.TokenType.LESS, Token.TokenType.LESS_EQUAL):
		var operator = previous()
		var right = term()
		expr = Binary.create(expr, operator, right)
	
	return expr

func term() -> Expr:
	var expr = factor()

	while isMatch(Token.TokenType.MINUS, Token.TokenType.PLUS):
		var operator = previous()
		var right = factor()
		expr = Binary.create(expr, operator, right)

	return expr

func factor() -> Expr:
	var expr = unary()

	while isMatch(Token.TokenType.SLASH, Token.TokenType.STAR):
		var operator = previous()
		var right = unary()
		expr = Binary.create(expr, operator, right)
		
	return expr

func unary() -> Expr:
	if isMatch(Token.TokenType.BANG, Token.TokenType.MINUS):
		var operator = previous()
		var right = unary()
		return Unary.create(operator, right)
	
	return loxCall()

func finishCall(callee: Expr) -> Expr:
	var arguments: Array[Expr]
	if !check(Token.TokenType.RIGHT_PAREN):
		while true:
			if arguments.size() >= 255:
				error(peek(), "Cant't have more than 255 arguments.")
			arguments.append(expression())
			if !isMatch(Token.TokenType.COMMA): break
	
	var paren = consume(Token.TokenType.RIGHT_PAREN, "Expected ')' after arguments.")
	return Call.create(callee, paren, arguments)

# Godot already has a call method defined in Object
func loxCall() -> Expr:
	var expr = primary()

	while true:
		if isMatch(Token.TokenType.LEFT_PAREN):
			expr = finishCall(expr)
		elif isMatch(Token.TokenType.DOT):
			var name: Token = consume(Token.TokenType.IDENTIFIER,
			"Expect property name after '.'.")
			expr = Get.create(expr, name)
		else:
			break
	return expr

func primary() -> Expr:
	if isMatch(Token.TokenType.FALSE): return Literal.create(false)
	if isMatch(Token.TokenType.TRUE): return Literal.create(true)
	if isMatch(Token.TokenType.NIL): return Literal.create(null)

	if isMatch(Token.TokenType.NUMBER, Token.TokenType.STRING):
		return Literal.create(previous().literal)

	if isMatch(Token.TokenType.SUPER):
		var keyword = previous()
		consume(Token.TokenType.DOT, "Expect '.' after 'super'.")
		var method = consume(Token.TokenType.IDENTIFIER, "Expect superclass method name.")
		return Super.create(keyword, method)

	if isMatch(Token.TokenType.SELF): return Self.create(previous())
	
	if isMatch(Token.TokenType.IDENTIFIER):
		return Variable.create(previous())

	if isMatch(Token.TokenType.LEFT_PAREN):
		var expr = expression()
		consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after expression")
		return Grouping.create(expr)
	
	# If we did everything right, null should never be return
	# print_debug("Yeap, here is the error with")
	return error(peek(), "Expect expression.")

## Recives and array of Tokens and 'check' if any of them match the current token,
## advancing (Incrementing) current index as result, and returning bool if either of the Tokens Match
## Otherwise returns false.
func isMatch(...types: Array) -> bool:
	for type in types:
		if check(type):
			advance()
			return true

	return false

## This function is used consume the next token, is the expected Token by the grammar rules, returns it.
## otherwise set an error in the Lox Class.
func consume(type: Token.TokenType, message: String) -> Token:
	if check(type): return advance()
	error(peek(), message)
	synchronize() # to recover from errors, Node: This needs to be study more in depth
	return null

## Return true if the current Token is the same type as the received by parameter
func check(type: Token.TokenType) -> bool:
	if isAtEnd(): return false
	return peek().type == type

## Increment the current index and return the previous Token
func advance() -> Token:
	if !isAtEnd(): current += 1
	return previous()

## Check if the the current Token is the end of the file
func isAtEnd() -> bool:
	return peek().type == Token.TokenType.EOF

## Obtain the current token on the list of tokens using the current index
func peek() -> Token:
	return tokens[current]

## look ahead and returns the token, similar to do tokens[current + 1]
func peekNext() -> Token:
	if current + 1 >= tokens.size():
		return tokens.back()
	return tokens[current + 1]

## Return the previous processed Token, code:    return tokens[current -1]
func previous() -> Token:
	return tokens[current - 1]

## Set Lox.hadError as true and print the error in the console
func error(token: Token, message: String) -> Expr:
	Lox.errorWith(token, message)
	return null

func synchronize():
	advance()
	while (!isAtEnd()):
		#Note: This needs to be evaluated, GDBraces don't use ';' to terminate statements
		if previous().type == Token.TokenType.SEMICOLON: return

		match peek().type:
			Token.TokenType.CLASS, \
			Token.TokenType.FUNC, \
			Token.TokenType.VAR, \
			Token.TokenType.FOR, \
			Token.TokenType.IF, \
			Token.TokenType.WHILE, \
			Token.TokenType.PRINT, \
			Token.TokenType.RETURN:
				return
	
	advance()
