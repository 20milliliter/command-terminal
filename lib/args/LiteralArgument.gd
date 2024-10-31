class_name LiteralArgument
extends Argument
## A [String] literal argument.
##
## A LiteralArgument is an argument represented by a [String] literal.

## The literal value of the argument.
var literal : StringName

func _init(_literal : StringName, _optional : bool = false) -> void:
	literal = _literal.to_lower()
	super(_optional)

func _to_string() -> String:
	return "%s" % [literal]

func _is_valid() -> bool:
	return literal != ""

func _is_equal(argument : Argument) -> bool:
	if not argument is LiteralArgument: return false
	if not argument.literal == self.literal: return false
	return true

func get_autocomplete_entries(_remaining_input : String) -> Array[String]:
	if literal.begins_with(_remaining_input):
		return [literal]
	return []

func get_satisfying_prefix(_remaining_input : String) -> String:
	if _remaining_input.begins_with(literal + " "):
		return literal
	return ""