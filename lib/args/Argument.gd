class_name Argument
extends Object

var optional : bool

func _init(_optional = false):
	optional = _optional

func _to_string() -> String: #virtual
	assert(false, "'_to_string()' called on Argument that does not implement it.")
	return ""

func is_equal(argument : Argument) -> bool: #virtual
	assert(false, "'is_equal()' called on Argument that does not implement it.")
	return false
	
func is_valid(_input : String) -> bool: #virtual
	assert(false, "'is_valid()' called on Argument that does not implement it.")
	return false
