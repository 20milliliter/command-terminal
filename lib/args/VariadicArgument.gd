class_name VariadicArgument
extends Argument

func _init():
	super()

func _to_string() -> String:
	return "..."

func is_equal(argument : Argument) -> bool:
	return argument is VariadicArgument

func is_valid(_input : String) -> bool:
	return true

func is_autofill_candidate(_input : String) -> bool:
	return false