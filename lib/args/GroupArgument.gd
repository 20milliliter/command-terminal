class_name GroupArgument
extends ValidatedArgument

var arguments : Array[Argument] = []

func _init(_key : StringName, arguments : Array[Argument] = [], _optional = false, _validator : Callable = Callable()):
	self.arguments = arguments
	super(_key, _optional, _validator)

func _to_string() -> String:
	var child_arg_strings = []
	for argument in arguments:
		child_arg_strings.append(argument._to_string())
	return "<%s: %s>" % [key, ", ".join(child_arg_strings)]

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
	
func is_valid(_input : String) -> bool:
	var args = _input.split(" ")
	if not super.is_valid(_input): return false
	for arg_idx in range(0, len(args)):
		if not arguments[arg_idx].is_valid(args[arg_idx]):
			return false
	return true

func is_autofill_candidate(_input) -> bool:
	var args = _input.split(" ")
	for arg_idx in range(args.size()):
		if not arguments[arg_idx].is_autofill_candidate(args[arg_idx]):
			return false
	return true

	
