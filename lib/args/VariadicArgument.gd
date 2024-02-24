class_name VariadicArgument
extends Argument

func _init():
	super()

func _to_string() -> String:
	return "..."

func _is_valid() -> bool:
	return true

func _is_equal(argument : Argument) -> bool:
	return argument is VariadicArgument

func get_autofill_entries(_remaining_input : String) -> Array[String]:
	return [str(self)]

func get_satisfying_prefix(_remaining_input : String) -> String:
	return _remaining_input