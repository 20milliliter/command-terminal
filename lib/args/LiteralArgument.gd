class_name LiteralArgument
extends Argument

var literal : StringName

func _init(_literal : StringName, _optional = false):
	literal = _literal
	super(_optional)

func _to_string() -> String:
	return "LiteralArgument(%s)" % [literal]

func get_autofill_entry() -> String:
	return literal

func is_equal(argument : Argument) -> bool:
	if not argument is LiteralArgument: return false
	return argument.literal.to_lower() == self.literal.to_lower()

func is_valid(_input) -> bool: 
	return _input == literal

func is_autofill_candidate(_input) -> bool:
	return literal.begins_with(_input)
