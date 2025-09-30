extends RefCounted
class_name Parser

var tokens: Array[Token]
var current: int = 0

func _init(tokens: Array[Token]) -> void:
	self.tokens = tokens

func parse() -> Expr:
	return expresion()
	

func expresion() -> Expr:
	return equality()

func equality() -> Expr:
	var expr = comparison()

	while (isMatch(Token.TokenType.BANG_EQUAL, Token.TokenType.EQUAL_EQUAL)):
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
	
	return primary()

func primary() -> Expr:
	if isMatch(Token.TokenType.FALSE): return Literal.create(false)
	if isMatch(Token.TokenType.TRUE): return Literal.create(true)
	if isMatch(Token.TokenType.NIL): return Literal.create(null)

	if isMatch(Token.TokenType.NUMBER, Token.TokenType.STRING):
		return Literal.create(previous().literal)
	
	if isMatch(Token.TokenType.LEFT_PAREN):
		var expr = expresion()
		consume(Token.TokenType.RIGHT_PAREN, "Expect ')' after expresion")
		return Grouping.create(expr)
	
	# If we did everything right, null should never be return
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
