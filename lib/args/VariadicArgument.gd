class_name VariadicArgument
extends PeculiarArgument
## An argument that represents extra arguments.
##
## A VariadicArgument is an argument that represents the command accepting any number of extra arguments at it's end.

func _init() -> void:
	super()

func _to_string() -> String:
	return "..."

func _is_valid() -> bool:
	return true

func _is_equal(argument : Argument) -> bool:
	return argument is VariadicArgument

func get_autocomplete_content() -> String:
	return ""

func get_autocomplete_entries(_remaining_input : String) -> Array[String]:
	return [str(self)]

func get_satisfying_prefix(_remaining_input : String) -> String:
	return ""