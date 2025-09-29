@tool
extends EditorScript
class_name GenerateAst

# 
# Automates the creation of generating all file classes for the tree-types
func _run() -> void:
	defineAst("res://src/Core/Expresions/", "Expr", [
		"Binary   : Expr left, Token operator, Expr right",
      	"Grouping : Expr expression",
      	"Literal  : Object value",
      	"Unary    : Token operator, Expr right"
	])


func defineType(outputDir: String, baseName: String, type: String):
	var className = type.split(":")[0].strip_edges()
	var fields = type.split(":")[1].strip_edges()
	var fieldArray = fields.split(",")

	var fieldsArrangedForGDScript: Array = []
	for field in fieldArray:
		var cleanField = field.strip_edges()
		var item = cleanField.split(" ")
		var order = [item[1], item[0]] # [name, type]
		fieldsArrangedForGDScript.append(order)

	# Builde the params string for create() function
	var paramStrings: Array = []
	for field in fieldsArrangedForGDScript:
		var argument = field[0] + ": " + field[1] # "name: Type"
		paramStrings.append(argument)
	
	var params = ", ".join(paramStrings) # Join with comma and space
	print("params: ", params) # Will show: "left: Expr, operator: Token, right: Expr"

	var file = newFile(outputDir, className)

	# class definition
	var code: String = ""
	code += "extends %s \n" % baseName
	code += "class_name %s \n\n" % className

	# fields
	for field in fieldsArrangedForGDScript:
		code += "var %s: %s\n" % [field[0], field[1]]

	# func create(params) serve as a constructor instead of _init()
	code += "\nfunc create(" + params + "):\n"
	for field in fieldsArrangedForGDScript:
		code += "\tself.%s = %s\n" % [field[0], field[0]]
	
	code += "\nfunc accept(visitor: ExprVisitor) -> Variant:\n"
	code += "\treturn visitor.visit%s%s(self)\n" % [className, baseName]

	file.store_string(code)
	file.close()
	
func defineAst(outputDir: String, baseName: String, types: Array[String]):
	var file = newFile(outputDir, baseName)

	# Write the base class
	file.store_line("@abstract")
	file.store_line("extends RefCounted")
	file.store_line("class_name " + baseName)
	file.store_line("")

	file.store_line("# Abstract method - should be overridden by subclasses")
	file.store_line("@abstract func accept(visitor: ExprVisitor) -> Variant\n")
	# file.store_line("\tpush_error(\"accept() must be implemented by subclass\")")
	# file.store_line("")

	file.close()

	defineVisitor(outputDir, baseName, types)

	# Generate each subtype of Expr or the type passed in baseName
	for type in types:
		defineType(outputDir, baseName, type)

func defineVisitor(outputDir: String, baseName: String, types: Array[String]):
		# Write the base class
	var file = newFile(outputDir, baseName + "Visitor")
	var code: String = ""

	code += "@abstract\n"
	code += "extends RefCounted\n"
	code += "class_name %sVisitor\n\n" % baseName

	for type: String in types:
		var typeName = type.split(":")[0].strip_edges()
		code += "@abstract func visit%s%s(%s: %s)\n" % [typeName, baseName, baseName.to_lower(), typeName]
		# code += "\tpass\n\n"

	file.store_string(code)
	file.close()


func formatPath(outputDir: String, className: String) -> String:
	return "%s/%s.gd" % [outputDir, className] # Makes this "res://example/ExampleClass.gd"

func newFile(outputDir: String, className: String) -> FileAccess:
	var path = formatPath(outputDir, className)
	var file = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("Failed to create file: " + path)
	
	return file
