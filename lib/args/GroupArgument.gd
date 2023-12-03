class_name GroupArgument
extends Argument

var arguments : Array[Argument] = []

func _init(arguments : Array[Argument], _optional : bool = false):
	self.arguments = arguments
	super(_optional)

func _to_string() -> String:
	var result = ""
	for argument in arguments:
		result += argument._to_string() + ", "
	return "<%s>" % [result]

func get_autofill_entry() -> String:
	var result = ""
	for argument in arguments:
		result += argument.get_autofill_entry() + ", "
	return "[%s]" % [result]

func is_equal(argument : Argument) -> bool:
	for arg_idx in range(arguments.size()):
		if not arguments[arg_idx].is_equal(argument.arguments[arg_idx]):
			return false
	return true
	
func is_valid(_input) -> bool:
	return arguments.size() == 0

func is_autofill_candidate(_input) -> bool:
	var args = _input.split(" ")
	for arg_idx in range(arguments.size()):
		if not arguments[arg_idx].is_autofill_candidate(args[arg_idx]):
			return false
	return true

	
