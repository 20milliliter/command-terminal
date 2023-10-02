class_name LiteralArgument
extends Argument

var literal : StringName

func _init(_literal : StringName, _optional = false):
	literal = _literal
	super(_optional)

func is_equal(argument : Argument):
	if not argument is LiteralArgument: return false
	return argument.literal == self.literal

func is_valid(_input) -> bool: 
	return _input == literal

func is_autofill_candidate(_input) -> bool:
	return literal.begins_with(_input)