extends RefCounted
class_name Lox

# A simplified entry point for the Lox interpreter in GDScript.
# This script handles command-line arguments to either execute a source file
# or start an interactive REPL (Read-Eval-Print Loop).

static var hadError: bool

#args: Array ?
# func main(args: Array):
static func main(args: String):
	if args.length() > 1:
		print("Usage: GDSwift [script_path]")
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

	# for now, just print the tokens.
	for token in tokens:
		print(token)

# For error reporting check other implementations of Lox
# In the book he recomends to move this to "ErrorReport" that gets passed to the scanner
# and parser so that we can swap out different reporting strategies  
static func error(line: int, message: String):
	report(line, "", message)

static func report(line: int, where: String, message: String):
	print("line %s error %s : %s" % [line, where, message])
	hadError = true
