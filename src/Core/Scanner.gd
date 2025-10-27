extends RefCounted
class_name Scanner

var source: String
var tokens: Array[Token]

var start: int = 0
var current: int = 0
var line: int = 1

static var keywords: Dictionary = {
	"and": Token.TokenType.AND,
	"class": Token.TokenType.CLASS,
	"else": Token.TokenType.ELSE,
	"false": Token.TokenType.FALSE,
	"for": Token.TokenType.FOR,
	"func": Token.TokenType.FUNC,
	"if": Token.TokenType.IF,
	"nil": Token.TokenType.NIL,
	"or": Token.TokenType.OR,
	"print": Token.TokenType.PRINT,
	"return": Token.TokenType.RETURN,
	"super": Token.TokenType.SUPER,
	"self": Token.TokenType.SELF,
	"true": Token.TokenType.TRUE,
	"var": Token.TokenType.VAR,
	"const": Token.TokenType.CONST, # Added for my own sintax
	"get": Token.TokenType.GET, # Added for my own sintax
	"set": Token.TokenType.SET, # Added for my own sintax
	"while": Token.TokenType.WHILE,
}


func _init(source: String):
	self.source = source

func scanTokens() -> Array[Token]:
	while !isAtEnd():
		# We are at the beginning of the next lexeme
		start = current
		scanToken()

	tokens.append(Token.new(Token.TokenType.EOF, "", null, line))
	return tokens

func isAtEnd() -> bool:
	return current >= source.length()

func scanToken() -> void:
	var c = advance()
	match c:
		':': addToken(Token.TokenType.COLON)
		'(': addToken(Token.TokenType.LEFT_PAREN)
		')': addToken(Token.TokenType.RIGHT_PAREN)
		'{': addToken(Token.TokenType.LEFT_BRACE)
		'}': addToken(Token.TokenType.RIGHT_BRACE)
		',': addToken(Token.TokenType.COMMA)
		'.': addToken(Token.TokenType.DOT)
		'-': addToken(Token.TokenType.MINUS)
		'+': addToken(Token.TokenType.PLUS)
		';': addToken(Token.TokenType.SEMICOLON)
		'*': addToken(Token.TokenType.STAR)

		# This is Ugly but what can I do? this is GDscript D: 
		'!': addToken(Token.TokenType.BANG_EQUAL if isMatch('=') else Token.TokenType.BANG)
		'=': addToken(Token.TokenType.EQUAL_EQUAL if isMatch('=') else Token.TokenType.EQUAL)
		'<': addToken(Token.TokenType.LESS_EQUAL if isMatch('=') else Token.TokenType.LESS)
		'>': addToken(Token.TokenType.GREATER_EQUAL if isMatch('=') else Token.TokenType.GREATER)
		'/':
			if isMatch('/'):
				# a comment goes until the end of the line
				while (peek() != '\n' and !isAtEnd()):
					advance()
			else:
				addToken(Token.TokenType.SLASH)
		' ', '\r', '\t': pass # ignore white spaces
		'\n': line += 1
		'"': string()
		_:
			if isDigit(c):
				number()
			elif isAlpha(c):
				identifier()
			else:
				Lox.error(line, "Unexpected Character")

func identifier():
	while (isAlphaNumeric(peek())): advance()

	var text = source.substr(start, current - start) # Using substr like this migth be wrong, need to test
	var type = keywords.get(text)
	if type == null: type = Token.TokenType.IDENTIFIER
	addToken(type)

func number():
	while (isDigit(peek())): advance()

	# look for fractional part
	if peek() == '.' and isDigit(peekNext()):
		# consume the "."
		advance()

		while (isDigit(peek())): advance()

	addToken(Token.TokenType.NUMBER, source.substr(start, current - start).to_float())

func string():
	while (peek() != '"' and !isAtEnd()):
		if peek() == '\n': current += 1
		advance()

	if isAtEnd():
		Lox.error(line, "Unterminated string.")
		return
	# The closing "    
	advance()

	# use trim_prefix and trim_suffix instead of substr()
	var value = source.substr(start + 1, current - start - 2) # This might be wrong, should be substr(start + 1, current - start - 2)
	addToken(Token.TokenType.STRING, value)

func isMatch(expected: String) -> bool:
	if isAtEnd(): return false
	if source[current] != expected: return false

	current += 1
	return true

func peek() -> String:
	if isAtEnd():
		return char(0)
	return source[current]

func peekNext() -> String:
	if current + 1 >= source.length(): return char(0)
	return source[current + 1]

func isAlpha(c: String) -> bool:
	return \
	(c >= 'a' and c <= 'z') || \
	(c >= 'A' and c <= 'Z') || \
	c == '_'

func isAlphaNumeric(c: String) -> bool:
	return isAlpha(c) || isDigit(c)

func isDigit(c: String) -> bool:
	return c >= '0' and c <= '9'

func advance() -> String:
	var character = source[current]
	current += 1
	return character

func addToken(type: Token.TokenType, literal: Variant = null):
	var text = source.substr(start, current - start)
	tokens.append(Token.new(type, text, literal, line))
