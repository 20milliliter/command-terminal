class_name VariadicArgument
extends Argument

func _init():
	super()

func _to_string() -> String:
	return "VariadicArgument()"

func is_equal(argument : Argument) -> bool:
	return argument is VariadicArgument

func is_valid(_input) -> bool:
	return true

func is_autofill_candidate(_input) -> bool:
	return false