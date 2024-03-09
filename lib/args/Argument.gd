class_name Argument
extends Object

var optional : bool

func _init(_optional : bool = false) -> void:
	optional = _optional

func _to_string() -> String: #virtual
	assert(false, "'_to_string()' called on Argument that does not implement it.")
	return ""

func _is_valid() -> bool: #virtual
	assert(false, "'_is_valid()' called on Argument that does not implement it.")
	return false

func _is_equal(_argument : Argument) -> bool: #virtual
	assert(false, "'_is_equal()' called on Argument that does not implement it.")
	return false

func get_autofill_entries(_remaining_input : String) -> Array[String]:
	assert(false, "'get_autofill_entries()' called on Argument that does not implement it.")
	return []

func get_satisfying_prefix(_remaining_input : String) -> String:
	assert(false, "'get_satisfying_prefix()' called on Argument that does not implement it.")
	return ""
