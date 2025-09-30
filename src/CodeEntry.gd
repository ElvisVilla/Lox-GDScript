extends Node

var source = "Hello world"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Lox.main("res://code.txt")
    var expression = Binary.create(
        Unary.create(
            Token.new(Token.TokenType.MINUS, "-", null, 1),
            Literal.create(123)),
        Token.new(Token.TokenType.STAR, "*", null, 1),
        Grouping.create(Literal.create(45.67)))
#
    #var ast = ASTPrinter.new()
    #print(ast.print(expression))
    #
    #print(0.1 * (0.2 * 0.3))
    #print((0.1 * 0.2) * 0.3)
