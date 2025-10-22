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

func declaration() -> Stmt:
	if isMatch(Token.TokenType.FUNC): return function("function")
	if isMatch(Token.TokenType.VAR): return varDeclaration()
	return statement()

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
	# print("After consuming semicolon, current token: ", peek().type, " ", peek().lexeme)

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
	# consume(Token.TokenType.LEFT_PAREN, "Expect '(' after 'if'.")
	var condition = expression()
	# consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after if condition.")

	# Maybe to support Swift / Go style we could do this instead
	consume(Token.TokenType.LEFT_BRACE, "Expect '{' after if condition.")

	var thenBranch = statement()
	consume(Token.TokenType.RIGHT_BRACE, "Expect '}' after if condition.")
	var elseBranch = null
	if isMatch(Token.TokenType.ELSE):
		elseBranch = statement()

	return If.create(condition, thenBranch, elseBranch)


func printStatement() -> Stmt:
	var value = expression()
	# consume(Token.TokenType.SEMICOLON, "Expected ';' after value")
	return Print.create(value)

func returnStatement() -> Stmt:
	var keyword = previous()
	var value: Expr = null

	# Lox Sintax with ';'
	# if !check(Token.TokenType.SEMICOLON):
	# 	value = expression()
	# consume(Token.TokenType.SEMICOLON, "Expected ';' after return value.")

	# #My sintax, without ';'
	# if !check(Token.TokenType.RIGHT_BRACE) and !isAtEnd():
	# value = expression()
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

func varDeclaration() -> Stmt:
	var name = consume(Token.TokenType.IDENTIFIER, "Expect variable name")
	var initializer: Expr = null
	if isMatch(Token.TokenType.EQUAL):
		initializer = expression()

	# for Swift/GDScript sintax this needs to be commented 
	#consume(Token.TokenType.SEMICOLON, "Expect ';' after variable declaration.")
	return Var.create(name, initializer)

func whileStatement() -> Stmt:
	consume(Token.TokenType.LEFT_PAREN, "Expect '(' after 'while'.")
	var condition = expression()
	consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after condition")
	var body = statement()

	return While.create(condition, body)

func expressionStatement() -> Stmt:
	var expr = expression()
	# consume(Token.TokenType.SEMICOLON, "Expect ';' after the expression")
	return LoxExpression.create(expr)

func function(kind: String) -> Function:
	var name: Token = consume(Token.TokenType.IDENTIFIER, "Expect %s name." % kind)
	consume(Token.TokenType.LEFT_PAREN, "Expect '(' after %s name" % kind)
	
	var parameters: Array[Token]
	if !check(Token.TokenType.RIGHT_PAREN):
		while true:
			if parameters.size() >= 255:
				error(peek(), "Can't have more than 255 parameters")
			parameters.append(consume(Token.TokenType.IDENTIFIER, "Expect parameter name."))
			if !isMatch(Token.TokenType.COMMA):
				break
	
	consume(Token.TokenType.RIGHT_PAREN, "Expected ')' after parameters.")
	consume(Token.TokenType.LEFT_BRACE, "Expected '{' before %s body." % kind)
	var body: Array[Stmt] = block()
	return Function.create(name, parameters, body)

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
	while (isMatch(Token.TokenType.GREATER, Token.TokenType.GREATER_EQUAL,
	Token.TokenType.LESS, Token.TokenType.LESS_EQUAL)):
		var operator = previous()
		var right = term()
		expr = Binary.create(expr, operator, right)
	
	return expr

func term() -> Expr:
	var expr = factor()

	while (isMatch(Token.TokenType.MINUS, Token.TokenType.PLUS)):
		var operator = previous()
		var right = factor()
		expr = Binary.create(expr, operator, right)

	return expr

func factor() -> Expr:
	var expr = unary()

	while (isMatch(Token.TokenType.SLASH, Token.TokenType.STAR)):
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
		while true: # This is a do-while way of doing it in GDScript
			if arguments.size() >= 255:
				error(peek(), "Cant't have more than 255 arguments.")
			arguments.append(expression())
			if !isMatch(Token.TokenType.COMMA): break
	
	var paren = consume(Token.TokenType.RIGHT_PAREN, "Expected ')' after arguments.")
	return Call.create(callee, paren, arguments)

func loxCall() -> Expr: # Godot already has a call method defined in Object
	var expr = primary()

	while (true):
		if isMatch(Token.TokenType.LEFT_PAREN):
			expr = finishCall(expr)
		else:
			break
	return expr

func primary() -> Expr:
	# print_debug("primary() called, current token: ", peek().type, " ", peek().lexeme)
	if isMatch(Token.TokenType.FALSE): return Literal.create(false)
	if isMatch(Token.TokenType.TRUE): return Literal.create(true)
	if isMatch(Token.TokenType.NIL): return Literal.create(null)

	if isMatch(Token.TokenType.NUMBER, Token.TokenType.STRING):
		return Literal.create(previous().literal)
	
	if isMatch(Token.TokenType.IDENTIFIER):
		return Variable.create(previous())

	if isMatch(Token.TokenType.LEFT_PAREN):
		var expr = expression()
		consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after expression")
		return Grouping.create(expr)
	
	# If we did everything right, null should never be return
	# print_debug("Yeap, here is the error with")
	return error(peek(), "Expect expression.")

func isMatch(...types: Array) -> bool:
	for type in types:
		if check(type):
			advance()
			return true

	return false

func consume(type: Token.TokenType, message: String) -> Token:
	if check(type): return advance()
	error(peek(), message)
	synchronize() # to recover from errors
	return null

func check(type: Token.TokenType) -> bool:
	if isAtEnd(): return false
	return peek().type == type

func advance() -> Token:
	if !isAtEnd(): current += 1
	return previous()

func isAtEnd() -> bool:
	return peek().type == Token.TokenType.EOF

func peek() -> Token:
	return tokens[current]

func previous() -> Token:
	return tokens[current - 1]

func error(token: Token, message: String) -> Expr:
	Lox.errorWith(token, message)
	return null

func synchronize():
	advance()
	while (!isAtEnd()):
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
