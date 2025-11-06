extends RefCounted
class_name Lox

# A simplified entry point for the Lox interpreter in GDScript.
# This script handles command-line arguments to either execute a source file
# or start an interactive REPL (Read-Eval-Print Loop).

static var interpreter: Interpreter = Interpreter.new()
static var hadError: bool
static var hadRuntimeError: bool

#args: Array ?
# func main(args: Array):
static func main(args: String):
	if args.length() > 1:
		# print("Usage: GDSwift [script_path]")
	# elif args.length() == 1: # TODO: How do we check for File?
		run_file(args)
	# else:
	# run_prompt()

# Placeholder function for executing a script file.
static func run_file(path: String):
	print("Running file: " + path)

	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		run(text)

		# if hadError: System.exit(65)? what is this equivalent in GDScript

		
# Placeholder function for the interactive prompt.
static func run_prompt():
	# TODO: Implement the interactive REPL here.
	# The GDScript equivalent of the Java 'runPrompt' function.
	print("Starting interactive prompt...")
 
	# Implement a text editor or use a plugin for reading the console
	# Check again this code in the book, here is the Java code:

#    private static void runPrompt() throws IOException {
#     InputStreamReader input = new InputStreamReader(System.in);
#     BufferedReader reader = new BufferedReader(input);

#     for (;;) { 
#       System.out.print("> ");
#       String line = reader.readLine();
#       if (line == null) break;
#       run(line);
#       hadError = false
#     }
#   }


static func run(source: String):
	var scanner: Scanner = Scanner.new(source)
	var tokens: Array[Token] = scanner.scanTokens()

	#for token in tokens:
		#print(token)

	# AST = Asbtract Sintax Tree
	var parser = Parser.new(tokens)
	var statements: Array[Stmt] = parser.parse()

	if hadError:
		# print(hadError)
		return
	
	#RESOLVER
	var resolver := Resolver.new(interpreter)
	resolver.resolve(statements)

	if hadError: return

	# # INTERPRETER
	interpreter.interpret(statements)


	var secondTranspiler = Transpiler.new()
	var gdCode = secondTranspiler.transpile(statements)
	print(gdCode)

	# var file = newFile("res://src/Core/Transpiler/", "Weapon")

	# file.store_string(gdCode)
	# file.close()

	# print(ASTPrinter.new().print(expresion))

static func newFile(outputDir: String, className: String) -> FileAccess:
	var path = formatPath(outputDir, className)
	var file = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("Failed to create file: " + path)
	
	return file

static func formatPath(outputDir: String, className: String) -> String:
	return "%s/%s.gd" % [outputDir, className] # Makes this "res://example/ExampleClass.gd"

# For error reporting check other implementations of Lox
# In the book he recomends to move this to "ErrorReport" that gets passed to the scanner
# and parser so that we can swap out different reporting strategies  
static func error(line: int, message: String):
	report(line, "", message)

static func errorWith(token: Token, message: String):
	if token.type == token.TokenType.EOF:
		report(token.line, "at end", message)
	else:
		report(token.line, "at '%s'" % token.lexeme, message)

static func report(line: int, where: String, message: String):
	print("line %s error %s : %s" % [line, where, message])
	hadError = true

static func runtimeError(error: RuntimeError):
	print("%s \n[line: %d]" % [error.message, error.token.line])
	# print(error.message + "\n[line " + error.token.line + "]")
	hadRuntimeError = true
