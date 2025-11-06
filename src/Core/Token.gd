extends RefCounted
class_name Token

## The TokenType that this Token represents
var type: TokenType

## The String representation of the Token
var lexeme: String

## Literal is the value of the Token, this value will be evaluated on the Interpreter
var literal: Variant # the Book uses Object but for Godot this is better

## The line where this Token belongs
var line: int

func _init(type: TokenType, lexeme: String, literal: Variant, line: int):
	self.type = type
	self.lexeme = lexeme
	self.literal = literal
	self.line = line

func _to_string() -> String:
	return "%s %s %s" % [type, lexeme, literal]

enum TokenType {
	# Single-character tokens
	LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE,
	COMMA, DOT, MINUS, PLUS, SEMICOLON, COLON, SLASH, STAR, AT,

	#One or two character tokens
	BANG, BANG_EQUAL,
	EQUAL, EQUAL_EQUAL,
	GREATER, GREATER_EQUAL,
	LESS, LESS_EQUAL, ARROW,

	#Literals
IDENTIFIER, STRING, NUMBER,

	#Keywords: for GDscript I keep [FUNC, Self, CONST]
	AND, CLASS, CLASS_NAME, EXTENDS, ELSE, FALSE, FUNC, FOR, IF, ELIF, NIL, OR,
	PRINT, RETURN, SUPER, SELF, TRUE, VAR, CONST, WHILE,
	SET, GET, SIGNAL, AWAIT, BREAK,

	EOF

}