extends RefCounted
class_name Token

var type: TokenType
var lexeme: String
var literal: Variant # the Book uses Object but for Godot this is better
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
	COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR,

	#One or two character tokens
	BANG, BANG_EQUAL,
	EQUAL, EQUAL_EQUAL,
	GREATER, GREATER_EQUAL,
	LESS, LESS_EQUAL,

	#Literals
	IDENTIFIER, STRING, NUMBER,

	#Keywords: for GDscript I keep [FUNC, Self,]
	AND, CLASS, ELSE, FALSE, FUNC, FOR, IF, NIL, OR,
	PRINT, RETURN, SUPER, SELF, TRUE, VAR, WHILE,

	EOF

}


# func isVariableName(exp):
# 	if exp is String:
# 		var regx: RegEx = RegEx.new()
# 		regx.compile("^[a-zA-Z][a-zA-Z0-9_]*$")
# 		return regx.search(exp) != null
